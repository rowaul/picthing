#!/bin/bash
# Prints a facsimile of whatever picture you give it 
# Requires true color support and imagemagick

# variable reference
col=0                # column count
prow=0               # row count
maxrow=0	     # height of image
filename=""	     # location of image
rgba=""		     # image transparency indicator
seethru="n"	     # pixel transparency indicator
pixelco=""	     # rgb value of pixel color
filecheck=""	     # uses magick to check the file

# creates the picture
addline() {
        # loops until prow reaches maxrow
        while true; do

		# transparency defaults to n
		seethru="n"

		# reads pixel color information
		pixelco=$(convert $filename -colorspace RGB -format '%[pixel:p{'$col','$prow'}]' info:-)
		
		# checks for image transparency
		if [ $rgba = 'y' ]; then
			# checks for pixel transparency
			if [ $pixelco = "rgba(0,0,0,0)" ]; then
				seethru="y"
			fi
			# alters rgb output to suit printf
			pixelco=$(echo $pixelco | cut -c 6- | rev | cut -c 2- | rev | tr ',' ';')
			pixelco=$(echo $pixelco | awk -F ';' '{print $1 ";" $2 ";" $3}')
		else
			# alters rgb output to suit printf
			pixelco=$(echo $pixelco | cut -c 5- | rev | cut -c 2- | rev | tr ',' ';')
		fi

                # creates row from "picture" information
		if [ $seethru = "y" ]; then
			# prints nothing to simulate transparency
			printf "  "
		else
			# prints a block of whatever color it was given
			printf "\x1b[38;2;${pixelco}m\u25A0 \x1b[0m"
		fi

		#increases column count
             	col=$((col + 1))

                # determines whether the row should end
                if [ $col -eq $width ]; then
                        # resets column count and increases row count
			col=0
                        prow=$((prow + 1))
                        printf "\n"
                             
		       	# chooses between exiting and looping
                        if [ $prow -eq $maxrow ]; then
				# complements the user and removes the temporary file
                       	        printf "Truly a masterpeice!\n"
				rm $filename
                                exit
                        fi
                fi
        done
}

# requests filename
while true; do
	read -p "Enter the location of your image: " filename
	filecheck=$(identify "$filename" 2> /dev/null)
	if [ "$filecheck" = "" ]; then
		printf "Invalid file.\n"
	else
		break
	fi
done

# requests width
while true; do
	read -p "Enter the width of the output (32 or 64 is recommended): " width
	if [[ "$width" =~ ^[0-9]+$ ]]; then
		break
	else
		printf "Enter a number.\n"	
	fi
done

# requests transparency boolean
while true; do
	read -p "Does the image contain transparency? (y/n): " rgba
	if [ "$rgba" == "y" ] || [ "$rgba" == "n" ]; then
		break
	else
		printf "Invalid entry.\n"
	fi
done

# requests resampling type
while true; do
	read -p "Pick a resampling filter. (point/box/triangle): " filter
	case $filter in
		point )
			break;;
		box )
			break;;
     	        triangle )
			break;;
		*)
			printf "Invalid entry.\n"
	esac
done
printf "\n"

# creates a temporary smaller version of the image
convert $filename -filter $filter -resize "$width" rsz
filename=rsz

# sets the max number of rows according to image height
maxrow=$(convert $filename -format "%h" info:-)
addline
