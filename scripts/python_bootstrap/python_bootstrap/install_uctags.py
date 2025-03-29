from python_bootstrap import cmd_with_logs

UCTAGS_INSTALL_DIR = Path.home().joinpath(".local")


def get_uctags_download_url() -> tuple[str, str]:
    return (
        "uctags",
        "https://github.com/universal-ctags/ctags/archive/refs/heads/master.zip",
    )


def install_uctags(file_path: Path, logger: logging.Logger) -> None:
    logger.info("Installing uctags.")

    out_path = file_path.parent.joinpath("uctags_install")
    cmd_with_logs.run_cmd(["unzip", file_path, "-d", out_path], False, logger)
    cmd_with_logs.run_cmd(["./autogen.sh"], False, logger, cwd=out_path)
    cmd_with_logs.run_cmd(
        ["./configure", f"--prefix={UCTAGS_INSTALL_DIR}"], False, logger, cwd=out_path
    )
    cmd_with_logs.run_cmd(["make", "-j$(nproc)"], False, logger, cwd=out_path)
    cmd_with_logs.run_cmd(["make", "install"], False, logger, cwd=out_path)

    logger.info("Finished installing uctags.")
