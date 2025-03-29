import asyncio
import logging
import os
import shutil
from pathlib import Path

import aiofiles
import aiohttp
from python_bootstrap import cmd_with_logs, install_neovim, install_stow, install_uctags
from python_bootstrap.defines import OS

TMP_DIR = Path(__file__).parent.resolve().joinpath("tmp")

ZSH_PATH = "/usr/bin/zsh"
LOCALE_GEN_PATH = Path("/etc/locale.gen")
TIMEZONE_PATH = Path("/etc/timezone")

LOCALE = "en_US.UTF-8"
LANGUAGE = "en_US:en"


def bootstrap_linux(
    os_type: OS, timezone: str, apt_file_path: Path, logger: logging.Logger
) -> None:
    """
    Bootstrap the Linux environment.

    This script does a bunch that TODO:

    Parameters
    ----------
    logger : logging.Logger
        The logger to use for logging output.

    """
    use_sudo = True
    os.environ["DEBIAN_FRONTEND"] = "noninteractive"

    if os.geteuid() == 0:
        logger.info("Detected root user.")
        use_sudo = False

    set_timezone(timezone, use_sudo, logger)
    update_apt_packages(use_sudo, logger)
    install_apt_packages(apt_file_path, use_sudo, logger)
    set_locale(LOCALE, LANGUAGE, use_sudo, logger)
    change_default_shell(ZSH_PATH, logger)

    # Download all install files at once
    download_urls = {
        "neovim": install_neovim.get_neovim_download_url(os_type, logger),
        "stow": install_stow.get_stow_download_url(),
        "uctags": install_uctags.get_uctags_download_url(),
    }

    TMP_DIR.mkdir(exist_ok=True)
    install_files = await download_all_files(download_urls)

    # neovim
    install_neovim.install_neovim(install_files["neovim"], None, use_sudo, logger)
    # stow
    install_stow.install_stow(install_files["stow"], logger)
    # uctags
    install_uctags.install_uctags(install_files["uctags"], logger)

    # treesitter

    # fzf

    # Now install packages
    shutil.rmtree(TMP_DIR)
    rebuild_font_cache(logger)


def set_timezone(timezone: str, use_sudo: bool, logger: logging.Logger) -> None:
    """
    Set the timezone for the environment.

    Parameters
    ----------
    logger : logging.Logger
        The logger to use for logging output.

    """
    cmd_with_logs.run_linux_cmd(
        ["timedatectl", "set-timezone", timezone], use_sudo, logger
    )
    cmd_with_logs.run_linux_cmd(
        ["echo", timezone, ">", TIMEZONE_PATH], use_sudo, logger
    )

    logger.info(f"Timezone set to {timezone}.")


def update_apt_packages(use_sudo: bool, logger: logging.Logger) -> None:
    """
    Update the apt packages.

    Parameters
    ----------
    use_sudo : bool
        Should the command be run with sudo?
    logger : logging.Logger
        The logger to use for logging output.

    """
    logger.info("Updating apt packages.")
    cmd_with_logs.run_linux_cmd(["apt-get", "update"], use_sudo, logger)
    cmd_with_logs.run_linux_cmd(["apt-get", "upgrade", "-y"], use_sudo, logger)
    logger.info("Finished updating apt packages.")


def install_apt_packages(
    apt_file_path: Path, use_sudo: bool, logger: logging.Logger
) -> None:
    """
    Install a list of apt packages.

    Parameters
    ----------
    apt_file_path : Path
        The path to the file containing the list of packages.
    use_sudo : bool
        Should the command be run with sudo?
    logger : logging.Logger
        The logger to use for logging output.

    """
    logger.info(f"Installing apt packages from file {apt_file_path.stem}.")
    logger.debug(f"Full apt package file path: {apt_file_path}")

    packages = read_apt_packages_from_file(apt_file_path)
    cmd_with_logs.run_linux_cmd(
        ["apt-get", "install", "-y"] + packages, use_sudo, logger
    )

    logger.info("Finished installing apt packages.")


def set_locale(locale: str, lang: str, use_sudo: bool, logger: logging.Logger) -> None:
    """
    Set the locale for the environment.

    Parameters
    ----------
    locale : str
        The locale to set.
    lang : str
        The language to set.
    use_sudo : bool
        Should the command be run with sudo?
    logger : logging.Logger
        The logger to use for logging output.

    """
    logger.info(f"Setting locale to {locale} and language to {lang}.")
    update_locale_file(LOCALE_GEN_PATH, locale, use_sudo, logger)

    cmd_with_logs.run_linux_cmd(["locale-gen", locale], use_sudo, logger)
    cmd_with_logs.run_linux_cmd(
        ["update-locale", f"LANG={locale}", f"LC_ALL={locale}", f"LANGUAGE={lang}"],
        use_sudo,
        logger,
    )

    logger.info("Finished setting locale.")


def rebuild_font_cache(logger: logging.Logger) -> None:
    """
    Rebuild the font cache.

    Parameters
    ----------
    use_sudo : bool
        Should the command be run with sudo?
    logger : logging.Logger
        The logger to use for logging output.

    """
    logger.info("Rebuilding font cache.")
    cmd_with_logs.run_linux_cmd(["fc-cache", "-f", "-v"], False, logger)
    logger.info("Finished rebuilding font cache.")


def change_default_shell(shell: str, logger: logging.Logger) -> None:
    """
    Change the default shell for the current user.

    Parameters
    ----------
    shell : str
        The shell to set as default.
    logger : logging.Logger
        The logger to use for logging output.

    """
    logger.info(f"Changing default shell to {shell}.")
    cmd_with_logs.run_linux_cmd(["chsh", "-s", shell], False, logger)
    logger.info("Finished changing default shell.")


def read_apt_packages_from_file(file_path: Path, logger: logging.Logger) -> list[str]:
    """
    Read a list of apt packages from a file, excluding blank lines.

    Parameters
    ----------
    file_path : Path
        The path to the file containing the list of packages.

    Returns
    -------
    list[str]
        A list of package names.

    """
    logger.debug(f"Reading apt packages from file: {file_path}")
    with open(file_path, "r") as f:
        packages = [line.strip() for line in f if line.strip()]
    return packages
    logger.debug("Finished reading apt packages from file.")


def update_locale_file(
    file_path: Path, locale: str, use_sudo: bool, logger: logging.Logger
) -> None:
    """
    Update the locale file by uncommenting the specified locale.

    If the locale is already uncommented, or the locale file does not
    exist do nothing.

    Parameters
    ----------
    file_path : Path
        The path to the locale file.
    locale : str
        The locale to uncomment.
    use_sudo : bool
        Should the command be run with sudo?
    logger : logging.Logger
        The logger to use for logging output.

    """
    logger.debug(f"Uncommenting locale {locale} in file: {file_path}")

    if not file_path.exists() and not file_path.is_file():
        logger.debug("No locale file found. Skipping.")
        return

    sed_command = ["sed", "-i", "''", f"s/^#.*{locale}/{locale}/", str(file_path)]
    cmd_with_logs.run_linux_cmd(sed_command, use_sudo, logger)

    logger.debug("Finished uncommenting locale")


async def download_file(session, name, url, logger: logging.Logger):
    """Download a file from a URL."""
    download_path = TMP_DIR.joinpath(name)
    logger.debug(f"Downloading {name} from {url} to {download_path}")
    async with session.get(url) as response:
        async with aiofiles.open(download_path, "wb") as f:
            data = await response.read()
            await f.write(data)

    logger.debug(f"Finished downloading {name}.")
    return name, download_path


async def download_all_files(named_urls: dict[str, str], logger: logging.Logger):
    """Download all files from a list of URLs."""
    logger.info("Downloading all manually installed files.")

    async with aiohttp.ClientSession() as session:
        tasks = [
            asyncio.create_task(download_file(session, name, url, logger))
            for name, url in named_urls.items()
        ]
        results = await asyncio.gather(*tasks)

    logger.info("Finished downloading files.")
    return dict(results)
