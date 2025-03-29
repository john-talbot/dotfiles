import argparse
import logging
import platform
from pathlib import Path

from python_bootstrap.os_type import OS
from rich.logging import RichHandler

from python_bootstrap import linux_bootstrap

CONF_PATH = Path(__file__).parent.resolve().joinpath("conf")
PROC_PATH = Path("/proc/cpuinfo")

APT_PACKAGE_PATH = CONF_PATH.joinpath("apt_packages.txt")


def main(timezone: str) -> None:
    logger = setup_logging()
    os_type = get_os_type()

    if os_type == OS.LINUX:
        logger.info("Detected Linux. Proceeding with Linux-specific setup.")
        linux_bootstrap.bootstrap(os_type, timezone, APT_PACKAGE_PATH, logger)
    elif os_type == OS.RASPIOS:
        logger.info("Detected Raspberry Pi OS. Proceeding with Linux (raspi) setup.")
        linux_bootstrap.bootstrap(os_type, timezone, APT_PACKAGE_PATH, logger)
    elif platform.system() == "Darwin":
        logger.info("Detected macOS. Proceeding with macOS-specific setup.")
    else:
        logger.warning("This script is not supported on this operating system.")
        return


def setup_logging() -> logging.Logger:
    logger = logging.getLogger("bootstrap_logger")
    logger.setLevel(logging.DEBUG)

    console_handler = RichHandler(level=logging.INFO, rich_tracebacks=True)

    file_handler = logging.FileHandler("bootstrap.log", mode="w")
    file_handler.setLevel(logging.DEBUG)
    formatter = logging.Formatter(
        "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    )
    file_handler.setFormatter(formatter)

    logger.addHandler(console_handler)
    logger.addHandler(file_handler)

    return logger


def get_os_type() -> OS:
    if platform.system() == "Linux" and is_raspberry_pi():
        return OS.RASPIOS
    elif platform.system() == "Linux":
        return OS.LINUX
    elif platform.system() == "Darwin":
        return OS.MACOS
    else:
        return OS.UNSUPPORTED


def is_raspberry_pi():
    try:
        with open("/proc/cpuinfo") as f:
            return "Raspberry" in f.read()
    except FileNotFoundError:
        return False


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Bootstrapping script to setup a fresh environment."
    )
    parser.add_argument(
        "--timezone",
        type=str,
        default="America/New_York",
        help="The timezone to set for the environment.",
    )
    args = parser.parse_args()
    main(args.timezone)
