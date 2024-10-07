function rossrc() {
    source /opt/ros/humble/setup.zsh

    if [[ -n "$1" ]]; then  # Check if $1 is not empty
        if [[ -e "$1/install/setup.zsh" ]]; then
            source "$1/install/setup.zsh"
        else
            echo "No such workspace: $1"
        fi
    fi

    eval "$(register-python-argcomplete3 ros2)"
    eval "$(register-python-argcomplete3 colcon)"
}

function cb() {
    colcon build --symlink-install
}

function ccl() {
    local target_dir=${1:-$PWD}  # Default to current directory if no argument is provided

    if [ -d "$target_dir/build" ]; then
        rm -r "$target_dir/build"
    fi
    if [ -d "$target_dir/log" ]; then
        rm -r "$target_dir/log"
    fi
    if [ -d "$target_dir/install" ]; then
        rm -r "$target_dir/install"
    fi
}

function rl() {
    ros2 launch $1 $2
}
