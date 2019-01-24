#!/bin/bash
# Prints a facsimile of whatever picture you give it 
# Requires true color support and imagemagick

# variable reference
col=0            # column count
curRow=0           # row count
maxRow=0         # height of image
fileName=""      # location of image
tempFile=""      # location of the temporary image
rgba=""         # image transparency indicator
seethru=""       # pixel transparency indicator
pixelclr=""      # rgb value of pixel color

# determines whether or not the row is complete
CheckSize()
{
  if [ "$col" -eq "$width" ]; then
    # resets column count and increases row count
    col=0
    curRow=$((curRow + 1))
    printf "\\n"
                                 
    if [ "$curRow" -eq "$maxRow" ]; then
      # complements the user and removes the temporary file
      printf "Truly a masterpeice!\\n"
      rm $tempFile
      exit
    fi
  fi
  PrintRow
}

# does it what it says
PrintRow() 
{
  pixelclr=$(convert $tempFile -colorspace RGB -format '%[pixel:p{'$col','$curRow'}]' info:-)

  # checks for image transparency
  if [ "$rgba" = 'y' ]; then
    # checks for pixel transparency
    if [ "$pixelclr" = "rgba(0,0,0,0)" ]; then
      # prints space to simulate transparency
      printf "  "
    else
      # alters rgb output to suit printf and prints a block
      pixelclr=$(echo "$pixelclr" | cut -c 6- | rev | cut -c 2- | rev | tr ',' ';')
      pixelclr=$(echo "$pixelclr" | awk -F ';' '{print $1 ";" $2 ";" $3}')
      printf "\x1b[38;2;${pixelclr}m\u25A0 \x1b[0m"
    fi
  else
    # alters rgb output to suit printf and prints a block
    pixelclr=$(echo "$pixelclr" | cut -c 5- | rev | cut -c 2- | rev | tr ',' ';')
    printf "\x1b[38;2;${pixelclr}m\u25A0 \x1b[0m"
  fi

  col=$((col + 1))
  CheckSize
}

# determines whether or not the image contains transparency information
CheckTransp()
{
  rgba=$(convert $tempFile -colorspace RGB -format '%[pixel:p{'1','1'}]' info:- | tr -cd , | wc -c)
  if [ "$rgba" -eq 3 ]; then
    rgba="y"
  else
    rgba="n"
  fi
}

# creates a temporary (usually smaller) version of the image
MakeTemp()
{
  convert "$fileName"[0] -filter point -resize "$width" rsz.png
  tempFile=rsz.png
}

# defines maximum width of output
GetWidth()
{
  while true; do
    read -r -p "Enter the width of the output (32 / 64 are recommended): " width
    if [[ "$width" =~ ^[0-9]+$ ]]; then
      break
    else
      printf "Enter a number.\\n" 
    fi
  done
}

# defines source image
GetFile()
{
  while true; do
    read -r -p "Enter the location of your image: " fileName
    if [ "$(identify "$fileName" 2> /dev/null)" = "" ]; then
      printf "Invalid file.\\n"
    else
      break
    fi
  done
}

Commence()
{
  GetFile
  GetWidth
  MakeTemp
  CheckTransp

  # sets maxRow according to height of the temporary file
  maxRow=$(convert $tempFile -format "%h" info:-)

  PrintRow
}

Commence