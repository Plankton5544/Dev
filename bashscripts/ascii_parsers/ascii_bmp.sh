#!/bin/bash

## Author: Plankton5544
### Date Of Creation: August 15 2025
# Idea: ASCII Renderer Using Builtins
# Features:
# BMP Stuff
# Restructure & Polish
#
##
# Check if we have at least one argument (Required String)
if [ $# -eq 0 ]; then
    echo "Usage: $0 <string> [options]"
    exit 1
fi
debug=0
string="$1"
shift
while getopts "::dh" opt; do
    case $opt in
        d)
          debug=1
          echo "Input string: $1"
          echo "Debug Info: $debug"
            ;;
        h)
          echo "Usage: $0 <string> [options]"
          echo "Note: <string> is Needed even if invalid!"
          echo "Options: "
          echo "-h   Shows scripts usage"
          echo "-d   Shows minimal debug info"
          exit 1
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            echo "Usage: $0 <string> [options]"
            echo "Note: <string> is Needed even if invalid!"
            echo "Options: "
            echo "-h   Shows scripts usage"
            echo "-d   Shows minimal debug info"
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            echo "Usage: $0 <string> [options]"
            echo "Note: <string> is Needed even if invalid!"
            echo "Options: "
            echo "-h   Shows scripts usage"
            echo "-d   Shows minimal debug info"
            exit 1
            ;;
    esac
done

w="$string"
read_le_4() {
  local bytes hex_string

  bytes=$(dd if="$w" bs=1 count=4 skip="$2" 2>/dev/null | od -An -t x1 | tr -d ' ')

    # Reverse byte order manually (little-endian to big-endian)
    # bytes = "ab cd ef 12" becomes "12efcdab"
    hex_string="${bytes:6:2}${bytes:4:2}${bytes:2:2}${bytes:0:2}"

    # Convert to decimal
    echo $((0x$hex_string))
}
read_le_3() {
  local bytes hex_string

  bytes=$(dd if="$w" bs=1 count=3 skip="$2" 2>/dev/null | od -An -t x1 | tr -d ' ')

    # Reverse byte order manually (little-endian to big-endian)
    # bytes = "ab cd ef 12" becomes "12efcdab"
    hex_string="${bytes:6:2}${bytes:4:2}${bytes:2:2}${bytes:0:2}"

    # Convert to decimal
    echo $((0x$hex_string))
}
read_le_2() {
    local bytes hex_string

    bytes=$(dd if="$w" bs=1 count=2 skip="$2" 2>/dev/null | od -An -tx1 | tr -d ' ')
    hex_string="${bytes:2:2}${bytes:0:2}"
    echo $((0x$hex_string))
}






#|.BMP
#|-|==BITMAP=FILE=HEADER==| (14 bytes - ALWAYS present)
#| |-Signature (2 bytes: "BM")
#| |-File-Size (4 bytes)
#| |-Reserved1 (2 bytes)
#| |-Reserved2 (2 bytes)
#| |-File-Offset-To-PixelArray (4 bytes)
#|
#|-|==DIB=HEADER==| (Variable size - ALWAYS present)
#| |-Header-Size (4 bytes - tells you which DIB version)
#| |
#| |--[IF Header-Size = 40 (BITMAPINFOHEADER)]--
#| |-Image-W (4 bytes)
#| |-Image-H (4 bytes)
#| |-Planes (2 bytes - always 1)
#| |-Bits/Pixel (2 bytes)
#| |-Compression (4 bytes)
#| |-Image-Size (4 bytes)
#| |-X-Pixels/Meter (4 bytes)
#| |-Y-Pixels/Meter (4 bytes)
#| |-Colors-In-Color-Table (4 bytes)
#| |-Important-Color-Count (4 bytes)

#|==HEADER==|#

#==Signature==#
signature=$(dd if="$w" bs=1 count=2 2>/dev/null)
if [[ "$signature" == "BM" ]]; then
  echo "Valid BMP Signature"
else
  echo "Invalid BMP Signature!"
  echo $signature
  exit 1
fi

#==File=Size==#
file_size=$(read_le_4 "$w" 2)
#==Reserved1==#
reserved_1=$(read_le_2 "$w" 6)
#==Reserved2==#
reserved_2=$(read_le_2 "$w" 8)
#==File=Offset=To=PixelArray==#
file_offset_to_pixelarray=$(read_le_4 "$w" 10)

#|==DIB=HEADER==|#

#==Header=Size==#
header_size=$(read_le_4 "$w" 14)
if [ $header_size -eq 40 ]; then
  #==Width==#
  width=$(read_le_4 "$w" 18)
  #==Height==#
  height=$(read_le_4 "$w" 22)
  #==Planes==#
  planes=$(read_le_2 "$w" 26)
  #==Bits/Pixel==#
  bits_per_pixel=$(read_le_2 "$w" 28)
  #==Compression==#
  compression=$(read_le_4 "$w" 30)
  #==Image=Size=+#
  image_size=$(read_le_4 "$w" 34)
  #==X-Pixels/Meter==#
  x_pixels_per_meter=$(read_le_4 "$w" 38)
  #==Y-Pixels/Meter==#
  y_pixels_per_meter=$(read_le_4 "$w" 42)
  #==Colors=In=Color=Table==#
  colors_in_table=$(read_le_4 "$w" 46)
  #==Important=Color=Count==#
  important_colors=$(read_le_4 "$w" 50)
#elif [ $header_size -eq 124 ]; then

## FIGURED OUT ITS A WASTE OF TIME BUT IDK?
#  #==Width==#
#  width=$(read_le_4 "$w" 18)
#  #==Height==#
#  height=$(read_le_4 "$w" 22)
#  #==Planes==#
#  planes=$(read_le_2 "$w" 26)
#  #==Bits/Pixel==#
#  bits_per_pixel=$(read_le_2 "$w" 28)
#  #==Compression==#
#  compression=$(read_le_4 "$w" 30)
#  #==Image=Size=+#
#  image_size=$(read_le_4 "$w" 34)
#  #==X-Pixels/Meter==#
#  x_pixels_per_meter=$(read_le_4 "$w" 38)
#  #==Y-Pixels/Meter==#
#  y_pixels_per_meter=$(read_le_4 "$w" 42)
#  #==Colors=In=Color=Table==#
#  colors_in_table=$(read_le_4 "$w" 46)
#  #==Important=Color=Count==#
#  important_colors=$(read_le_4 "$w" 50)
#
#  #==Red=Mask==#
#  red_mask=$(read_le_4 "$w" 54)
#  #==Green=Mask==#
#  green_mask=$(read_le_4 "$w" 58)
#  #==Blue=Mask==#
#  blue_mask=$(read_le_4 "$w" 62)
#  #==Alpha=Mask==#
#  alpha_mask=$(read_le_4 "$w" 66)
#  #==Color=Space=Type==#
#  color_space_type=$(read_le_4 "$w" 70)
#  #==Endpoints==#
#  red_endpoint=$(read_le_4 "$w" 74)
#  green_endpoint=$(read_le_4 "$w" 78)
#  blue_endpoint=$(read_le_4 "$w" 82)
#
#  #==Gamma=Red==#
#  gamma_red=$(read_le_4 "$w" 86)
#  #==Gamma=Green==#
#  gamma_green=$(read_le_4 "$w" 90)
#  #==Gamma=Blue==#
#  gamma_blue=$(read_le_4 "$w" 94)
#  #==Intent==#
#  intent=$(read_le_4 "$w" 98)
#  #==Profile=Size==#
#  profile_size=$(read_le_4 "$w" 102)
#  #==Profile=Data==#
#  if [ "$profile_size" -gt 0 ]; then
#    profile_data=$(read_le_4 "$w" 106)
#  fi

else
  echo "NON-STANDERED HEADER-SIZE ERRORS MAY APPLY"
  echo "Header-Size: $header_size-byte"
  echo "STANDERED: 40-byte"
  #==Width==#
  width=$(read_le_4 "$w" 18)
  #==Height==#
  height=$(read_le_4 "$w" 22)
  #==Planes==#
  planes=$(read_le_2 "$w" 26)
  #==Bits/Pixel==#
  bits_per_pixel=$(read_le_2 "$w" 28)
  #==Compression==#
  compression=$(read_le_4 "$w" 30)
  if [ $compression -gt 0 ]; then
    echo "COMPRESSION ERROR!"
    exit 2
  fi
  #==Image=Size=+#
  Image_size=$(read_le_4 "$w" 34)
  #==X-Pixels/Meter==#
  x_pixles_per_meter=$(read_le_4 "$w" 38)
  #==Y-Pixels/Meter==#
  y_pixels_per_meter=$(read_le_4 "$w" 42)
  #==Colors=In=Color=Table==#
  colors_in_table=$(read_le_4 "$w" 46)
  #==Important=Color=Count==#
  important_colors=$(read_le_4 "$w" 50)
fi

# Add validation after parsing headers:
if [ $bits_per_pixel -ne 24 ]; then
    echo "Only 24-bit BMPs supported for now"
    exit 1
fi

bytes_per_pixel=3  # Since I only support 24-bit
raw_scanline_width=$((width * bytes_per_pixel))
padded_scanline_width=$(((raw_scanline_width + 3) / 4 * 4))
padding_bytes=$((padded_scanline_width - raw_scanline_width))



# Storage arrays
declare -a pixel_data

current_offset=$file_offset_to_pixelarray
#bottom to top


for ((row = height - 1; row >= 0; row--)); do
  for ((col = 0; col < width; col++)); do
    blue=$(dd if="$w" bs=1 count=1 skip=$current_offset 2>/dev/null | od -An -tu1 | tr -d ' ')
    green=$(dd if="$w" bs=1 count=1 skip=$((current_offset + 1)) 2>/dev/null | od -An -tu1 | tr -d ' ')
    red=$(dd if="$w" bs=1 count=1 skip=$((current_offset + 2)) 2>/dev/null | od -An -tu1 | tr -d ' ')

    pixel_data[$((row * width + col))]="$red,$green,$blue"
    current_offset=$((current_offset + 3))
  done
  current_offset=$((current_offset + padding_bytes))
done


brightness_scale=" .,;?&$%#@"
brightness_levels=10

for ((row=0; row < height; row++)); do
  for ((col=0; col < width; col++)); do

    i=$((row * width + col))
    pixel_rgb="${pixel_data[i]}"

    # Extract RGB and calculate brightness
    r="${pixel_rgb%%,*}"
    temp="${pixel_rgb#*,}"
    g="${temp%%,*}"
    b="${temp#*,}"

    brightness=$(( (b + g + r) / 3 ))

    # Convert to ASCII character
  char_index=$(( brightness * (brightness_levels - 1) / 255 ))

  ascii_char=${brightness_scale:char_index:1}

  echo -n $ascii_char
  echo -n $ascii_char

  done
  echo ""
done

if [[ $debug -eq 1 ]]; then
  echo "Width: $width, Height: $height"
  echo "Total pixels stored: ${#pixel_data[@]}"
  echo "First few pixels: ${pixel_data[0]} ${pixel_data[1]} ${pixel_data[2]}"
fi
