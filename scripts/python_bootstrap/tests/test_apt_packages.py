import logging
import shutil
from pathlib import Path

import pytest

from python_bootstrap import linux_bootstrap

TMP_PATH = Path(__file__).parent.joinpath("tmp")


logger = logging.getLogger("python_bootstrap")
logging.basicConfig(level=logging.ERROR)


@pytest.fixture()
def package_file() -> Path:
    file_path = TMP_PATH.joinpath("test_packages.txt")

    yield file_path

    if file_path.exists():
        file_path.unlink()


@pytest.fixture
def locale_file() -> Path:
    orig = TMP_PATH.joinpath("locale.gen.original")
    tmp_path = TMP_PATH.joinpath("locale.gen")
    shutil.copy(orig, tmp_path)

    yield tmp_path

    if tmp_path.exists():
        tmp_path.unlink()


def test_read_packages_normal(package_file: Path) -> None:
    content = "vim\nnano\ncurl\n"
    package_file.write_text(content)
    expected = ["vim", "nano", "curl"]

    result = linux_bootstrap.read_apt_packages_from_file(package_file, logger)

    assert result == expected


def test_read_packages_empty_lines(package_file: Path) -> None:
    content = "  vim  \n\nnano\n  curl\n"
    package_file.write_text(content)
    # Note: The function strips whitespace, so empty lines remain as empty strings.
    expected = ["vim", "nano", "curl"]

    result = linux_bootstrap.read_apt_packages_from_file(package_file, logger)

    assert result == expected


def test_read_packages_empty_file(package_file: Path) -> None:
    package_file.write_text("")
    expected = []

    result = linux_bootstrap.read_apt_packages_from_file(package_file, logger)

    assert result == expected


def test_locale_file_original_state(locale_file: Path) -> None:
    with open(locale_file, "r") as file:
        for line in file:
            if "en_GB.UTF-8 UTF-8" in line:
                assert line.strip() == "en_GB.UTF-8 UTF-8"
            else:
                assert line.startswith("#") or line.strip() == ""


def test_locale_file_final_state(locale_file: Path) -> None:
    locale = "en_US.UTF-8"
    linux_bootstrap.update_locale_file(False, locale_file, locale, logger)

    with open(locale_file, "r") as f:
        for line in f:
            if locale in line:
                assert line.strip() == f"{locale} UTF-8"
