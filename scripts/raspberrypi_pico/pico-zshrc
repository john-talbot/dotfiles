########################################################################################
# RASPBERRY PI PICO
########################################################################################
function pico_flash() {
    openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg -c "adapter speed 5000" -c "program $1 verify reset exit"
}

function pico_ocd_server() {
    openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg -c "adapter speed 5000"
}

function pico_minicom() {
    minicom -D /dev/ttyACM0 -b 115200
}

# Custom completion function for pico_flash
_pico_flash_completion() {
    local selected_file
    selected_file=$(rg --files --no-ignore -g '*.elf' -g '!*sdk*' 2> /dev/null | fzf --select-1 --exit-0)
    if [[ -n $selected_file ]]; then
        compadd "$selected_file"
    fi
}

# Register the custom completion function
compdef _pico_flash_completion pico_flash


