#!/bin/bash

## Author: Plankton5544
### Date Of Creation: August 15 2025
# Idea: ASCII Renderer Using Builtins
# Features:
# TGA Interpretation Using Bash BuiltiNs
# Brightness Interpretation Of RGB Values
# Nice CLI Interface
##





echo "#===WELCOME TO ASCIFY===#"
echo "!CURRENTLY TGA ONLY!"
echo "DEBUG INFO (N/y)"
read -p "=>" debug
echo ""
echo "Please Enter File To Ascify:"
read -p "=>" input_tga

#input_tga="input2.tga"






#========== TGA HEADER ==========#
#==Bytes 0-2==#
# |_0: ID length
# |_1: Color map type
# |_Byte 2: Image type
#==ID=Length==#
ID_length=$(dd if=$input_tga bs=1 count=1 2>/dev/null | od -An -t u1)
#==Color=Map=Type==#
color_map_type=$(dd if=$input_tga bs=1 count=1 skip=1 2>/dev/null | od -An -t u1)
#==Image=Type==#
image_type=$(dd if=$input_tga bs=1 count=1 skip=2 2>/dev/null | od -An -t u1)


#==Bytes 3-7: Color map specification==#
# |==Color Map Specification==|
# |__3-4  Color Map Origin
# |__5-6  Color Map Length
# |_7     Color Map Entry Size
#==Origin==#
color_map_origin_1=$(dd if=$input_tga bs=1 count=1 skip=3 2>/dev/null | od -An -t u1)
color_map_origin_2=$(dd if=$input_tga bs=1 count=1 skip=4 2>/dev/null | od -An -t u1)
color_map_origin=$((color_map_origin_1 + color_map_origin_2 * 256)) #<--Combine little endian
#==Length==#
color_map_length_1=$(dd if=$input_tga bs=1 count=1 skip=5 2>/dev/null | od -An -t u1)
color_map_length_2=$(dd if=$input_tga bs=1 count=1 skip=6 2>/dev/null | od -An -t u1)
color_map_length=$((color_map_length_1 + color_map_length_2 * 256)) #<--Combine little endian
#==Entry=Size==#
color_map_entry_size=$(dd if=$input_tga bs=1 count=1 skip=7 2>/dev/null | od -An -t u1)

#==Bytes 8-17: Image Specification==#
# |==Image Specification==|
# |__8-9    X Origin
# |__10-11  Y Origin
# |__12-13  Width
# |__14-15  Height
# |_16      Pixel Depth
# |_17      Image Descriptor
#==X=Origin==#
x_origin_1=$(dd if=$input_tga bs=1 count=1 skip=8 2>/dev/null | od -An -t u1)
x_origin_2=$(dd if=$input_tga bs=1 count=1 skip=9 2>/dev/null | od -An -t u1)
x_origin=$((x_origin_1 + x_origin_2 * 256)) #<--Combine little endian
#==Y=Origin==#
y_origin_1=$(dd if=$input_tga bs=1 count=1 skip=10 2>/dev/null | od -An -t u1)
y_origin_2=$(dd if=$input_tga bs=1 count=1 skip=11 2>/dev/null | od -An -t u1)
y_origin=$((y_origin_1 + y_origin_2 * 256)) #<--Combine little endian
#==Width==#
width_1=$(dd if=$input_tga bs=1 count=1 skip=12 2>/dev/null | od -An -t u1)
width_2=$(dd if=$input_tga bs=1 count=1 skip=13 2>/dev/null | od -An -t u1)
width=$((width_1 + width_2 * 256)) #<--combine little endian
#==Height==#
height_1=$(dd if=$input_tga bs=1 count=1 skip=14 2>/dev/null | od -An -t u1)
height_2=$(dd if=$input_tga bs=1 count=1 skip=15 2>/dev/null | od -An -t u1)
height=$((height_1 + height_2 * 256)) #<--combine little endian
#==Pixel=Depth==#
pixel_depth=$(dd if=$input_tga bs=1 count=1 skip=16 2>/dev/null | od -An -t u1)
#==Image=Descriptor==#
image_descriptor=$(dd if=$input_tga bs=1 count=1 skip=17 2>/dev/null | od -An -t u1)
#================================#


#========== IMAGE AND COLOR MAP DATA ==========#
current_position=18
if [ $ID_length -gt 0 ]; then current_position=$((current_position + ID_length)); fi
if [ $color_map_type -eq 1 ]; then
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
if [[ "$debug" == "y" ]] || [[ "$debug" == "Y" ]]; then
  echo "|--TGA HEADER--|"
  echo $ID_length
  echo $color_map_type
  echo $image_type
  echo "----------------"
  echo $color_map_origin
  echo $color_map_length
  echo $color_map_entry_size
  echo "----------------"
  echo $x_origin
  echo $y_origin
  echo $width
  echo $height
  echo $pixel_depth
  echo $image_descriptor
  echo "----------------"

  echo "|--IMAGE & COLOR MAP DATA--|"
  echo "Pixel data starts at byte: $pixel_data_start"
  echo "Bytes per pixel: $bytes_per_pixel"
  echo "Total pixels: $total_pixels"
  echo "Total pixel data: $total_pixel_bytes bytes" Calculate pixel info
  echo "|--------------------------|"
  echo "Pixel data starts at byte: $pixel_data_start"
  echo "Bytes per pixel: $bytes_per_pixel"
  echo "Total pixels: $total_pixels"
  echo "Total pixel data: $total_pixel_bytes bytes"
  echo "|--------------------------|"
fi
#======================#





#======ASCII=CONVERSIONS======#
brightness_scale=" .,;?&$%#@"
brightness_levels=10

echo "|--ASCII OUTPUT--|"

#loops through pixels
for ((pixel=0; pixel<total_pixels; pixel++)); do
    #Handles Indexing
    pixel_offset=$((pixel_data_start + pixel * bytes_per_pixel))

    # Read RGB values
    # NOTE TGA stores as BGR
    if [ $bytes_per_pixel -gt 2 ]; then  # 24-bit RGB
        b=$(dd if=$input_tga bs=1 count=1 skip=$pixel_offset 2>/dev/null | od -An -t u1)
        g=$(dd if=$input_tga bs=1 count=1 skip=$((pixel_offset + 1)) 2>/dev/null | od -An -t u1)
        r=$(dd if=$input_tga bs=1 count=1 skip=$((pixel_offset + 2)) 2>/dev/null | od -An -t u1)

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









