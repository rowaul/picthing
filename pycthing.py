from PIL import Image
import imghdr
import os
import readline

readline.set_completer_delims(' \t\n=')
readline.parse_and_bind("tab: complete")
imgLoc = input("Enter an image location: ")

if not os.path.exists(imgLoc):
  print("Invalid file location.")
  exit()
if not imghdr.what(imgLoc):
  print("Unsupported file type.")
  exit()

usrImg = Image.open(imgLoc)
oldW, oldH = usrImg.size

custom = input("Custom width? Y/N: ")
if custom == "n" or custom == "N":
  rows, cols = os.popen('stty size', 'r').read().split()
else:
  cols = input("Enter a width: ")

width = int(cols)
height = int(oldH/(2*oldW/width))

nuImg = usrImg.convert('RGBA').resize((width,height),resample=Image.LANCZOS)

for y in range(height):
  for x in range(width):
    rgba = nuImg.getpixel((x,y))
    if rgba[3] == 0:
      print(" ", end="")
    else:
      print("\x1b[38;2;" + str(rgba[0]) + ";" + str(rgba[1]) + ";" + str(rgba[2]) + "m\u2588", end="")
  print("")
print("Truly a masterpiece!")
