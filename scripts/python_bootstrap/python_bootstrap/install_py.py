import argparse
import logging
import sys
from pathlib import Path

from python_bootstrap import utilities
from python_bootstrap.utilities import OS

_PKGS = ["black", "flake8", "isort", "pytest", "ruff"]


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
    logger.info("Installing essential python packages.")

    utilities.run_cmd(
        ["/usr/bin/python3", "-m", "pip", "install"] + _PKGS, True, logger
    )

    logger.info("Finished installing python packages.")
