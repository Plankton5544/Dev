#!/bin/bash

## Author: Plankton5544
### Date Of Creation: August 15 2025
# Idea: ASCII Renderer Using Builtins
# Features:
# TGA Interpretation Using Bash BuiltiNs
# Brightness Interpretation Of RGB Values
# Nice CLI Interface
##


debug=0
debug_check() {
  if [ "$debug" -eq 0 ]; then
    printf "\033c"
  fi
}


# Check if we have at least one argument (Required String)
if [ $# -eq 0 ]; then
    echo "Usage: $0 <string> [options]"
    exit 1
fi

# Get the first argument (Required String)
input_string="$1"
input_tga="$1"
shift  # Remove the first argument so getopts only sees the options

# Now process the options
while getopts "::dh" opt; do
    case $opt in
        d)
          debug=1
          echo "Input string: $input_string"
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

debug_check


if [ "$input_tga" == "-h" ]; then
            echo "Usage: $0 <string> [options]"
            echo "Note: <string> is Needed even if invalid!"
            echo "Options: "
            echo "-h   Shows scripts usage"
            echo "-d   Shows minimal debug info"
            exit 1
fi



echo "#===WELCOME TO ASCIFY===#"
echo "!CURRENTLY TGA ONLY!"


if [ -z "$input_tga" ]; then
  echo "ERROR! FILE MISSING"
  exit 1
fi







#========== TGA HEADER ==========#
#==Bytes 0-2==#
# |_0: ID length
# |_1: Color map type
# |_Byte 2: Image type
#==ID=Length==#
ID_length=$(dd if=$input_tga bs=1 count=1 2>/dev/null | od -An -t u1 | tr -d ' ')
#==Color=Map=Type==#
color_map_type=$(dd if=$input_tga bs=1 count=1 skip=1 2>/dev/null | od -An -t u1 | tr -d ' ')
#==Image=Type==#
image_type=$(dd if=$input_tga bs=1 count=1 skip=2 2>/dev/null | od -An -t u1 | tr -d ' ')


#==Bytes 3-7: Color map specification==#
# |==Color Map Specification==|
# |__3-4  Color Map Origin
# |__5-6  Color Map Length
# |_7     Color Map Entry Size
#==Origin==#
color_map_origin_1=$(dd if=$input_tga bs=1 count=1 skip=3 2>/dev/null | od -An -t u1 | tr -d ' ')
color_map_origin_2=$(dd if=$input_tga bs=1 count=1 skip=4 2>/dev/null | od -An -t u1 | tr -d ' ')
color_map_origin=$((color_map_origin_1 + color_map_origin_2 * 256)) #<--Combine little endian
#==Length==#
color_map_length_1=$(dd if=$input_tga bs=1 count=1 skip=5 2>/dev/null | od -An -t u1 | tr -d ' ')
color_map_length_2=$(dd if=$input_tga bs=1 count=1 skip=6 2>/dev/null | od -An -t u1 | tr -d ' ')
color_map_length=$((color_map_length_1 + color_map_length_2 * 256)) #<--Combine little endian
#==Entry=Size==#
color_map_entry_size=$(dd if=$input_tga bs=1 count=1 skip=7 2>/dev/null | od -An -t u1 | tr -d ' ')

#==Bytes 8-17: Image Specification==#
# |==Image Specification==|
# |__8-9    X Origin
# |__10-11  Y Origin
# |__12-13  Width
# |__14-15  Height
# |_16      Pixel Depth
# |_17      Image Descriptor
#==X=Origin==#
x_origin_1=$(dd if=$input_tga bs=1 count=1 skip=8 2>/dev/null | od -An -t u1 | tr -d ' ')
x_origin_2=$(dd if=$input_tga bs=1 count=1 skip=9 2>/dev/null | od -An -t u1 | tr -d ' ')
x_origin=$((x_origin_1 + x_origin_2 * 256)) #<--Combine little endian
#==Y=Origin==#
y_origin_1=$(dd if=$input_tga bs=1 count=1 skip=10 2>/dev/null | od -An -t u1 | tr -d ' ')
y_origin_2=$(dd if=$input_tga bs=1 count=1 skip=11 2>/dev/null | od -An -t u1 | tr -d ' ')
y_origin=$((y_origin_1 + y_origin_2 * 256)) #<--Combine little endian
#==Width==#
width_1=$(dd if=$input_tga bs=1 count=1 skip=12 2>/dev/null | od -An -t u1 | tr -d ' ')
width_2=$(dd if=$input_tga bs=1 count=1 skip=13 2>/dev/null | od -An -t u1 | tr -d ' ')
width=$((width_1 + width_2 * 256)) #<--combine little endian
#==Height==#
height_1=$(dd if=$input_tga bs=1 count=1 skip=14 2>/dev/null | od -An -t u1 | tr -d ' ')
height_2=$(dd if=$input_tga bs=1 count=1 skip=15 2>/dev/null | od -An -t u1 | tr -d ' ')
height=$((height_1 + height_2 * 256)) #<--combine little endian
#==Pixel=Depth==#
pixel_depth=$(dd if=$input_tga bs=1 count=1 skip=16 2>/dev/null | od -An -t u1 | tr -d ' ')
#==Image=Descriptor==#
image_descriptor=$(dd if=$input_tga bs=1 count=1 skip=17 2>/dev/null | od -An -t u1 | tr -d ' ')
#================================#


#========== IMAGE AND COLOR MAP DATA ==========#
current_position=18
if [ "$ID_length" -gt 0 ]; then current_position=$((current_position + ID_length)); fi
if [ "$color_map_type" -eq 1 ]; then
    color_map_bytes=$(( (color_map_length * color_map_entry_size) / 8 ))
    current_position=$((current_position + color_map_bytes))
fi
pixel_data_start=$current_position
#==============================================#

#==CALCULATE=PIXEL=INFO==#
bytes_per_pixel=$((pixel_depth / 8))
total_pixels=$((width * height))
total_pixel_bytes=$((total_pixels * bytes_per_pixel))
#========================#

#==ECHOED=INFORMATION==#

if [ "$debug" -gt 0 ]; then
  echo "|--TGA HEADER--|"
  echo "ID Length:      $ID_length"
  echo "Color Map Type: $color_map_type"
  echo "Image Type:     $image_type"
  echo "----------------"
  echo " |-Color--Map-| "
  echo "ID Length:      $ID_length"
  echo "Origin:            $color_map_origin"
  echo "Length:            $color_map_length"
  echo "Entry Size:     $color_map_entry_size"
  echo "----------------"
  echo " |-Image-Spec-| "
  echo "X Origin:          $x_origin"
  echo "Y Origin:          $y_origin"
  echo "Width:             $width"
  echo "Height:            $height"
  echo "Pixel Depth:     $pixel_depth"
  echo "Image Desc:      $image_descriptor"
  echo "----------------"

  echo "|--IMAGE & COLOR MAP DATA--|"
  echo "Pixel data starts at byte:  $pixel_data_start"
  echo "Bytes per pixel:            $bytes_per_pixel"
  echo "Total pixels:               $total_pixels"
  echo "Total pixel data:           $total_pixel_bytes bytes"
  echo "|--------------------------|"
fi
#======================#





#======ASCII=CONVERSIONS======#
debug_check
brightness_scale=" .,;?&$%#@"
brightness_levels=10

echo "|--ASCII OUTPUT--|"

#loops through pixels
for ((pixel=0; pixel<total_pixels; pixel++)); do
    #Handles Indexing
    pixel_offset=$((pixel_data_start + pixel * bytes_per_pixel))

    # Read RGB values
    # NOTE TGA stores as BGR
    if [ "$bytes_per_pixel" -gt 2 ]; then  # 24-bit RGB
#        b=$(dd if=$input_tga bs=1 count=1 skip=$pixel_offset 2>/dev/null | od -An -t u1)
#        g=$(dd if=$input_tga bs=1 count=1 skip=$((pixel_offset + 1)) 2>/dev/null | od -An -t u1)
#        r=$(dd if=$input_tga bs=1 count=1 skip=$((pixel_offset + 2)) 2>/dev/null | od -An -t u1)


         b=$(dd if=$input_tga bs=1 count=1 skip=$pixel_offset 2>/dev/null | od -An -t u1 | tr -d ' ')
         g=$(dd if=$input_tga bs=1 count=1 skip=$((pixel_offset + 1)) 2>/dev/null | od -An -t u1 | tr -d ' ')
         r=$(dd if=$input_tga bs=1 count=1 skip=$((pixel_offset + 2)) 2>/dev/null | od -An -t u1 | tr -d ' ')

         # Set defaults if empty:
         b=${b:-0}
         g=${g:-0}
         r=${r:-0}


         B=$(( b / 255))
         G=$(( g / 255))
         R=$(( r / 255))




        # Brightness calculations
        #
          brightness=$(( (r + g + b) / 3 ))
          # Maps to 0-9 index
          char_index=$(( brightness * (brightness_levels - 1) / 255 ))

        # Get the character from the brightness scale using string slicing
        ascii_char=${brightness_scale:char_index:1}

        echo -n "$ascii_char"

        # Add newline at end of each row
        if [ $(((pixel + 1) % width)) -eq 0 ]; then
          echo ""
        fi
    fi
  done

      #=============================#



echo "|----------------|"









