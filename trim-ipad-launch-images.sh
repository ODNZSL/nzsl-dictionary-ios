#!/bin/sh -e

mogrify -crop 1024x748+0+20 Default-Landscape~ipad.png
mogrify -crop 768x1004+0+20 Default-Portrait~ipad.png
mogrify -crop 2048x1496+0+40 Default-Landscape@2x~ipad.png
mogrify -crop 1536x2008+0+40 Default-Portrait@2x~ipad.png
