#!/bin/bash -e

rm -rf FreeImage

if ! [ -e freeimage.zip ]
then
	curl -o freeimage.zip -L 'http://downloads.sourceforge.net/project/freeimage/Source%20Distribution/3.15.4/FreeImage3154.zip?r=http%3A%2F%2Ffreeimage.sourceforge.net%2Fdownload.html&ts=1362172561&use_mirror=switch'
fi

unzip -o freeimage.zip
