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
    LINUX_x64 = auto()
    LINUX_arm64 = auto()
    MACOS_arm64 = auto()
    UNSUPPORTED = auto()


def run_cmd(
    cmd: list[str],
    use_sudo: bool,
    logger: logging.Logger,
    cwd: Path = None,
    env: dict = None,
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

    if env is None:
        env = os.environ.copy()

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
            env=env,
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

        with (
            open(target_path, "wb") as file,
            Progress(
                TextColumn("[bold blue]{task.description}"),
                BarColumn(),
                DownloadColumn(),
                TransferSpeedColumn(),
                TimeRemainingColumn(),
                transient=True,  # removes the progress bar once finished
            ) as progress,
        ):
            task = progress.add_task(f"Downloading {name}", total=total)
            for chunk in response.iter_content(chunk_size=1024):
                if chunk:
                    file.write(chunk)
                    progress.update(task, advance=len(chunk))
    logger.debug(f"Downloaded {name} to {target_path}")


def get_os_type() -> OS:
    if platform.system() == "Linux" and platform.machine() == "x86_64":
        return OS.LINUX_x64
    elif platform.system() == "Linux" and platform.machine() == "aarch64":
        return OS.LINUX_arm64
    elif platform.system() == "Darwin" and platform.machine() == "arm64":
        return OS.MACOS_arm64
    else:
        return OS.UNSUPPORTED


def get_use_sudo(logger: logging.Logger) -> bool:
    if os.geteuid() == 0:
        logger.info("Detected root user.")
        return False

    username = os.getlogin()
    subprocess.run(["sudo", "-u", username, "-v"], text=True, check=True)
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


def get_git_root() -> Path:
    """Return the root directory of the current Git repo as a Path object."""
    try:
        git_root = subprocess.check_output(
            ["git", "rev-parse", "--show-toplevel"], text=True
        ).strip()
        return Path(git_root)
    except subprocess.CalledProcessError:
        raise RuntimeError("Not inside a Git repository.")


def get_github_tarball_url(url: str) -> str:
    response = requests.get(url)
    response.raise_for_status()
    data = response.json()

    for asset in data["assets"]:
        if asset["name"].endswith(".tar.gz"):
            return asset["browser_download_url"]

    raise RuntimeError("No tar.gz asset found.")
