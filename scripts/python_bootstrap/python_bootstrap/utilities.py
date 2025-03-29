import logging
import subprocess
import sys
from enum import Enum, auto
from pathlib import Path

import requests
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
