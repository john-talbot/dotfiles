import argparse
import logging
import sys
from pathlib import Path

from python_bootstrap import utilities
from python_bootstrap.utilities import OS

_GIT_URL = "https://github.com/junegunn/fzf.git"
_CMD_STRINGS = ["--bin", "--no-key-bindings", "--no-completion", "--no-update-rc"]

_INSTALL_DIR = Path.home().joinpath(".fzf")

_LOG_NAME = "install_fzf.log"


def main() -> None:
    parser = argparse.ArgumentParser(description="Install node from source")
    parser.add_argument(
        "--temp",
        type=Path,
        help="The temporary directory to use for the script.",
    )
    parser.add_argument(
        "--log",
        type=Path,
        help="The directory to store the log files.",
    )
    args = parser.parse_args()

    log_dir = args.log

    logger = utilities.setup_logging("fzf", log_dir.joinpath(_LOG_NAME))
    os_type = utilities.get_os_type()

    if os_type == OS.UNSUPPORTED:
        logger.error("This script is not supported on this operating system.")
        sys.exit(1)

    install(logger)

    sys.exit(0)


def install(logger: logging.Logger) -> None:
    logger.info("Installing fzf.")

    utilities.run_cmd(["rm", "-rf", str(_INSTALL_DIR)], False, logger)
    utilities.run_cmd(
        ["git", "clone", "--depth", "1", _GIT_URL, str(_INSTALL_DIR.name)],
        False,
        logger,
        cwd=Path.home(),
    )
    utilities.run_cmd(["./install"] + _CMD_STRINGS, False, logger, cwd=_INSTALL_DIR)

    logger.info("Finished installing fzf.")
