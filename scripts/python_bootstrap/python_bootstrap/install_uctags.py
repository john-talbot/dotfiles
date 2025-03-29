import logging
from pathlib import Path

from python_bootstrap import utilities

UCTAGS_INSTALL_DIR = Path.home().joinpath(".local")


def get_download_url() -> str:
    return "https://github.com/universal-ctags/ctags/archive/refs/heads/master.zip"


def install(file_path: Path, logger: logging.Logger) -> None:
    logger.info("Installing uctags.")

    out_path = file_path.parent.joinpath("uctags_install")
    utilities.run_cmd(
        ["unzip", "-u", "-q", "-j", file_path, "-d", out_path], False, logger
    )
    utilities.run_cmd(["./autogen.sh"], False, logger, cwd=out_path)
    utilities.run_cmd(
        ["./configure", f"--prefix={UCTAGS_INSTALL_DIR}"], False, logger, cwd=out_path
    )
    utilities.run_cmd(["make", "-j$(nproc)"], False, logger, cwd=out_path)
    utilities.run_cmd(["make", "install"], False, logger, cwd=out_path)

    logger.info("Finished installing uctags.")
