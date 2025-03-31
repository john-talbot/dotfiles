import argparse
import logging
import os
import sys
from pathlib import Path

import requests

from python_bootstrap import utilities
from python_bootstrap.utilities import OS

_URL = "https://api.github.com/repos/nvm-sh/nvm/releases/latest"
_DWN_URL = "https://raw.githubusercontent.com/nvm-sh/nvm/"

_INSTALL_DIR = Path.home().joinpath(".fzf")

_TMP_NAME = "node"
_LOG_NAME = "install_node.log"


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

    logger = utilities.setup_logging("node_logger", log_dir.joinpath(_LOG_NAME))
    os_type = utilities.get_os_type()

    if os_type == OS.UNSUPPORTED:
        logger.error("This script is not supported on this operating system.")
        sys.exit(1)

    install(temp_dir.joinpath(_TMP_NAME), logger)


def install(tmp_dir: Path, logger: logging.Logger) -> None:
    logger.info("Installing node.")

    response = requests.get(_URL)
    response.raise_for_status()
    tag_name = response.json()["tag_name"]
    url = f"{_DWN_URL}{tag_name}/install.sh"

    dwn_path = tmp_dir.joinpath("install.sh")
    utilities.download_archive(url, dwn_path, logger, "nvm")

    logger.debug("Running nvm installer script")
    utilities.run_cmd(["bash", str(dwn_path)], False, logger)

    nvm_dir = Path.home().joinpath(".nvm")
    env = os.environ.copy()
    env["NVM_DIR"] = str(nvm_dir)

    bash_commands = """
    [ -s "$NVM_DIR/nvm.sh" ] && \\. "$NVM_DIR/nvm.sh";
    nvm install node
    """

    logger.debug("Installing node using nvm")
    utilities.run_cmd(["bash", "-c", bash_commands], False, logger, env=env)

    logger.info("Finished installing node.")
