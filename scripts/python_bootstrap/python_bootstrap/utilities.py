import logging
import os
import platform
import subprocess
import sys
from enum import Enum, auto
from pathlib import Path

import requests
from rich.logging import RichHandler
from rich.progress import (
    BarColumn,
    DownloadColumn,
    Progress,
    TextColumn,
    TimeRemainingColumn,
    TransferSpeedColumn,
)


class OS(Enum):
    LINUX = auto()
    MACOS = auto()
    RASPIOS = auto()
    UNSUPPORTED = auto()


def run_cmd(
    cmd: list[str], use_sudo: bool, logger: logging.Logger, cwd: Path = None
) -> None:
    """
    Run a shell command and log its output.

    Parameters
    ----------
    cmd : list[str]
        The command to run, as a list of strings.
    use_sudo : bool
        Whether to use sudo to run the command.
    logger : logging.Logger
        The logger to use for logging output.

    """
    cmd = [str(item) for item in cmd]
    logger.debug(f"Running command: {' '.join(cmd)}")

    if cwd is None:
        cwd = Path.cwd()

    if use_sudo:
        cmd = ["sudo"] + cmd

    try:
        result = subprocess.run(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            check=True,
            text=True,
            cwd=cwd,
        )

    except subprocess.CalledProcessError as e:
        logger.error(f"Command {' '.join(cmd)} failed with exit code {e.returncode}")
        logger.error(e.output)
        sys.exit(e.returncode)

    if result.stdout:
        logger.debug(result.stdout)
    logger.debug(f"Command {' '.join(cmd)} completed successfully.")


def download_archive(
    url: str, target_path: str, logger: logging.Logger, name: str = None
) -> None:
    """
    Download an archive file from the given URL to the target_path,
    displaying a progress bar during the download.
    """

    if name is None:
        name = "archive"

    logger.debug(f"Downloading {name} from {url} to {target_path}")
    with requests.get(url, stream=True) as response:
        response.raise_for_status()
        total = int(response.headers.get("Content-Length", 0))

        with open(target_path, "wb") as file, Progress(
            TextColumn("[bold blue]{task.description}"),
            BarColumn(),
            DownloadColumn(),
            TransferSpeedColumn(),
            TimeRemainingColumn(),
            transient=True,  # removes the progress bar once finished
        ) as progress:
            task = progress.add_task(f"Downloading {name}", total=total)
            for chunk in response.iter_content(chunk_size=1024):
                if chunk:
                    file.write(chunk)
                    progress.update(task, advance=len(chunk))
    logger.debug(f"Downloaded {name} to {target_path}")


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


def get_use_sudo(logger: logging.Logger) -> bool:
    if os.geteuid() == 0:
        logger.info("Detected root user.")
        return False

    subprocess.run(["sudo", "-v"], text=True, check=True)
    return True


def setup_logging(name: str, log_path: Path) -> logging.Logger:
    logger = logging.getLogger(name)
    logger.setLevel(logging.DEBUG)

    console_handler = RichHandler(level=logging.INFO, rich_tracebacks=True)

    file_handler = logging.FileHandler(log_path, mode="w")
    file_handler.setLevel(logging.DEBUG)
    formatter = logging.Formatter(
        "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    )
    file_handler.setFormatter(formatter)

    logger.addHandler(console_handler)
    logger.addHandler(file_handler)

    logger.info(f"Logging to file {log_path}")

    return logger
