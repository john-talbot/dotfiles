#!/usr/bin/env python3

import argparse
import platform
import shutil
import sys
from pathlib import Path

MY_DIR = Path(__file__).parent.resolve()

BOOTSTRAP_PATH = MY_DIR.joinpath("python_bootstrap")
sys.path.insert(0, str(BOOTSTRAP_PATH))
from python_bootstrap.utilities import OS  # noqa E402

from python_bootstrap import linux_bootstrap  # noqa E402
from python_bootstrap import utilities  # noqa E402

TMP_DIR = MY_DIR.joinpath("tmp")
LOG_PATH = MY_DIR.joinpath("bootstrap.log")

CONF_PATH = MY_DIR.joinpath("conf")
APT_PACKAGE_PATH = CONF_PATH.joinpath("apt_packages.txt")

PROC_PATH = Path("/proc/cpuinfo")


def main(timezone: str) -> None:
    logger = utilities.setup_logging("bootstrap_logger", LOG_PATH)
    use_sudo = utilities.check_sudo(logger)
    os_type = utilities.get_os_type()

    TMP_DIR.mkdir(exist_ok=True)

    out_code = 0

    if os_type == OS.LINUX:
        logger.info("Detected Linux. Proceeding with Linux-specific setup.")
        linux_bootstrap.bootstrap(
            os_type, TMP_DIR, timezone, APT_PACKAGE_PATH, use_sudo, logger
        )
    elif os_type == OS.RASPIOS:
        logger.info("Detected Raspberry Pi OS. Proceeding with Linux (raspi) setup.")
        linux_bootstrap.bootstrap(
            os_type, TMP_DIR, timezone, APT_PACKAGE_PATH, use_sudo, logger
        )
    elif platform.system() == "Darwin":
        logger.info("Detected macOS. Proceeding with macOS-specific setup.")
    else:
        logger.error("This script is not supported on this operating system.")
        out_code = 1

    shutil.rmtree(TMP_DIR)
    sys.exit(out_code)


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
