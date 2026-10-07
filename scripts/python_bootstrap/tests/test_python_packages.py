from pathlib import Path

from python_bootstrap import install_py

PACKAGE_FILE = Path(__file__).parents[2].joinpath("conf/python_packages.txt")


def test_read_packages_skips_blank_lines_and_comments(tmp_path: Path) -> None:
    package_file = tmp_path.joinpath("packages.txt")
    package_file.write_text("pytest\n\n# a comment\n  ruff  \n")

    assert install_py.read_packages(package_file) == ["pytest", "ruff"]


def test_repo_package_list_uses_ruff_not_black_flake8_isort() -> None:
    packages = install_py.read_packages(PACKAGE_FILE)

    assert "ruff" in packages
    assert not {"black", "flake8", "isort", "pep8-naming"} & set(packages)
