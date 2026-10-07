import argparse
import logging
import sys
from pathlib import Path

from python_bootstrap import utilities
from python_bootstrap.utilities import OS

_PKG_FILE_NAME = "scripts/conf/python_packages.txt"

_LOG_NAME = "install_py.log"


def main() -> None:
    parser = argparse.ArgumentParser(description="Install essential python packages")
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

    logger = utilities.setup_logging("python_logger", log_dir.joinpath(_LOG_NAME))
    os_type = utilities.get_os_type()

    if os_type == OS.UNSUPPORTED:
        logger.error("This script is not supported on this operating system.")
        sys.exit(1)

    install(logger)

    sys.exit(0)


def read_packages(file_path: Path) -> list[str]:
    """Read pip package names from a file, skipping blank lines and comments."""
    with open(file_path, "r") as f:
        lines = [line.strip() for line in f]
    return [line for line in lines if line and not line.startswith("#")]


def install(logger: logging.Logger) -> None:
    logger.info("Installing essential python packages.")

    packages = read_packages(utilities.get_git_root().joinpath(_PKG_FILE_NAME))
    utilities.run_cmd(
        ["/usr/bin/python3", "-m", "pip", "install"] + packages, True, logger
    )

    logger.info("Finished installing python packages.")
