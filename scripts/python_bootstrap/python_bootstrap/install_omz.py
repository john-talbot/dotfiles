import argparse
import logging
import os
import shutil
import sys
from pathlib import Path

import requests

from python_bootstrap import utilities
from python_bootstrap.utilities import OS

_URL = "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

_TMP_NAME = "omz"
_LOG_NAME = "install_omz.log"


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

    temp_dir = args.temp
    log_dir = args.log

    logger = utilities.setup_logging("omz_logger", log_dir.joinpath(_LOG_NAME))
    os_type = utilities.get_os_type()

    if os_type == OS.UNSUPPORTED:
        logger.error("This script is not supported on this operating system.")
        sys.exit(1)

    install(temp_dir.joinpath(_TMP_NAME), logger)


def install(tmp_dir: Path, logger: logging.Logger) -> None:
    if Path.home().joinpath(".oh-my-zsh/oh-my-zsh.sh").exists():
        logger.info("oh-my-zsh is already installed... Skipping.")
        return

    logger.info("Installing oh-my-zsh.")

    logger.debug(f"Downloading oh-my installer script")
    dwn_path = tmp_dir.joinpath("install.sh")
    utilities.download_archive(_URL, dwn_path, logger, "oh-my-zsh")
    utilities.run_cmd(["chmod", "a+x", str(dwn_path)], False, logger)

    logger.debug(f"Running oh-my installer script")
    utilities.run_cmd(
        ["sh", str(dwn_path.name), "--unattended"], False, logger, cwd=tmp_dir
    )

    logger.debug(f"Removing existing zshrc")
    zshrc_path = Path.home().joinpath(".zshrc")
    if zshrc_path.exists():
        zshrc_path.unlink()

    logger.info("Finished installing oh-my-zsh.")
