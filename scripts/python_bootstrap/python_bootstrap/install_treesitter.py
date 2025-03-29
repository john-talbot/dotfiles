import gzip
import logging
import platform
import shutil
from pathlib import Path

_INSTALL_PATH = Path.home().joinpath(".local/bin/tree-sitter")
_BASE_URL = (
    "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-"
)

_ARCH_MAP = {"x86_64": "linux-x64", "aarch64": "linux-arm64", "armv7l": "linux-arm"}


def get_download_url(logger: logging.Logger) -> tuple[str, str]:
    try:
        download_type = _ARCH_MAP[platform.machine()]
    except KeyError:
        logger.error(
            f"Unsupported tresitter install architecture: {platform.machine()}"
        )
        return

    return ("tree-sitter", f"{_BASE_URL}{download_type}.gz")


def install(file_path: Path, logger: logging.Logger) -> None:
    logger.info("Installing treesitter.")

    with gzip.open(file_path, "rb") as f_in:
        with open(_INSTALL_PATH, "wb") as f_out:
            shutil.copyfileobj(f_in, f_out)

    logger.info("Finished installing treesitter.")
