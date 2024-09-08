# Function to flash a PIC microcontroller using ipecmd.sh
flash_pic() {
    local pic_part_number
    local hex_file

    # Parse command-line options
    while getopts "P:" opt; do
        case $opt in
            P) pic_part_number=$OPTARG ;;
            *) echo "Usage: program_pic -P <pic-part-number> <hex-file>" && return 1 ;;
        esac
    done
    shift $((OPTIND -1)) # Shift off the processed options

    # The remaining argument should be the HEX file
    hex_file=$1

    # Check if both the PIC part number and the HEX file are provided
    if [[ -z "$pic_part_number" || -z "$hex_file" ]]; then
        echo "Usage: program_pic -P <pic-part-number> <hex-file>"
        return 1
    fi

    # Expand the absolute path of the HEX file
    hex_file=$(realpath "$hex_file")

    # Define the IPECMD command with the PIC part number and the full path to the HEX file
    /Applications/microchip/mplabx/v6.20/mplab_platform/mplab_ipe/bin/ipecmd.sh -P"$pic_part_number" -TPPK3 -F"$hex_file" -M -OL
}

# Define the completion function for program_pic
_program_pic_completion() {
    local files
    # Define the list of files ending in .hex
    files=($(compgen -G "*.hex"))

    # Use _arguments to specify the options and their completions
    _arguments \
        '-P[Specify the PIC part number]' \
        '*::HEX file:_files -g "*.hex"'
}

# Register the completion function for program_pic
compdef _program_pic_completion program_pic
