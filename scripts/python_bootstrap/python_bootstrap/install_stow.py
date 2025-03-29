import logging
from pathlib import Path

from python_bootstrap import utilities

_STOW_INSTALL_DIR = Path.home().joinpath(".local")


def get_download_url() -> str:
    return "https://ftp.gnu.org/gnu/stow/stow-latest.tar.gz"


def install(file_path: Path, logger: logging.Logger) -> None:
    logger.info("Installing stow from source.")

    out_path = file_path.parent.joinpath("stow_install")
    utilities.run_cmd(["tar", "-C", f"{out_path}", "-xzf", file_path], False, logger)
    utilities.run_cmd(
        ["./configure", f"--prefix={_STOW_INSTALL_DIR}"],
        False,
        logger,
        cwd=out_path,
    )
    utilities.run_cmd(["make", "-j$(nproc)"], False, logger, cwd=out_path)
    utilities.run_cmd(["make", "install"], False, logger, cwd=out_path)

    logger.info("Finished installing stow.")
