import logging
import platform

from rich.logging import RichHandler

logger = logging.getLogger("bootstrap_logger")
logger.setLevel(logging.DEBUG)

console_handler = RichHandler(level=logging.INFO, rich_tracebacks=True)

file_handler = logging.FileHandler("bootstrap.log", mode="w")
file_handler.setLevel(logging.DEBUG)
formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
file_handler.setFormatter(formatter)

logger.addHandler(console_handler)
logger.addHandler(file_handler)


def main() -> None:

    if platform.system() == "Linux":
        logger.info("Detected Linux. Proceeding with Linux-specific setup.")
    if platform.system() == "Darwin":
        logger.info("Detected macOS. Proceeding with macOS-specific setup.")
    else:
        logger.warning("This script is not supported on this operating system.")
        return


if __name__ == "__main__":
    main()
