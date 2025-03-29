import logging
import shutil
import sys
from pathlib import Path

from python_bootstrap.utilities import OS

from python_bootstrap import utilities

_STOW_URL = "https://ftp.gnu.org/gnu/stow/stow-latest.tar.gz"
_STOW_INSTALL_DIR = Path.home().joinpath(".local")

_MY_DIR = Path(__file__).parent.resolve()
_TMP_DIR = _MY_DIR.joinpath("tmp")
_LOG_PATH = _MY_DIR.joinpath("bootstrap.log")


def main() -> None:
    logger = utilities.setup_logging("neovim_logger", _LOG_PATH)
    os_type = utilities.get_os_type()

    if os_type == OS.UNSUPPORTED:
        logger.error("This script is not supported on this operating system.")
        sys.exit(1)

    _TMP_DIR.mkdir(exist_ok=True)

    install(_TMP_DIR, logger)

    shutil.rmtree(_TMP_DIR)
    sys.exit(0)


def install(tmp_dir: Path, logger: logging.Logger) -> None:
    logger.info("Installing stow from source.")

    down_path = tmp_dir.joinpath("stow.tar.gz")
    out_path = tmp_dir.joinpath("stow_install")
    utilities.download_archive(_STOW_URL, down_path, logger)
    utilities.run_cmd(["tar", "-C", f"{out_path}", "-xzf", down_path], False, logger)
    utilities.run_cmd(
        ["./configure", f"--prefix={_STOW_INSTALL_DIR}"], False, logger, cwd=out_path
    )
    utilities.run_cmd(["make", "-j$(nproc)"], False, logger, cwd=out_path)
    utilities.run_cmd(["make", "install"], False, logger, cwd=out_path)

    logger.info("Finished installing stow.")
