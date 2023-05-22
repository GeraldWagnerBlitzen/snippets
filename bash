#
#  Filename: downscale-breakpoints-webp.sh
#

#!/bin/bash

# Ask the user to select an image file using the macOS file dialog
file=$(osascript -e 'tell application "Finder" to POSIX path of (choose file)')

# Get the file extension
extension="${file##*.}"

# Get the filename without extension
filename="${file%.*}"

# Replace underscores with dashes in the filename
filename="${filename//_/ -}"

# Get the width of the image file
init_width=$(sips -g pixelWidth $file | awk '/pixelWidth/ {print $2}')

# Specify the breakpoints for downscaled image widths
width_breakpoints=(375 480 720 1024 1440 1920 2560 2800)

# Downscale the image for each width breakpoint and save the downscaled images in the same directory with the new width at the end of the filename
for width in ${width_breakpoints[@]}
do

    # Skip the width breakpoint if it is larger than the initial width of the image
    if [[ $init_width -le $width ]]; then
        continue
    fi

    # Downscale the image
    sips --resampleWidth $width $file --out "${filename}-${width}.${extension}"

    # Convert the downscaled image to WebP format
    cwebp -q 90 "${filename}-${width}.${extension}" -o "${filename}-${width}.webp"

    # Remove the downscaled image
    rm "${filename}-${width}.${extension}"
    
done

# Downscale the first image for the default src attribute
sips --resampleWidth $width_breakpoints[0] $file --out "${filename}-${width_breakpoints[0]}.${extension}"
