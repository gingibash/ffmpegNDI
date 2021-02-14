# Compile ffmpeg with selected libraries
* libx264
* libx265
* libfdk_aac
* libndi_newtek

NDI SDK
* http://new.tk/NDISDKAPPLE

```
cp /Library/NDI\ SDK\ for\ Apple/include/*.* ffmpeg_build/include
cp /Library/NDI\ SDK\ for\ Apple/lib/x64/libndi.4.dylib ffmpeg_build/libndi.dylib
```

```
./run-macos.sh
```

FIX post compilation

```
install_name_tool -change @rpath/libndi.4.dylib /Library/NDI\ SDK\ for\ Apple/lib/x64/libndi.4.dylib ffmpeg
install_name_tool -change @rpath/libndi.4.dylib /Library/NDI\ SDK\ for\ Apple/lib/x64/libndi.4.dylib ffprobe
install_name_tool -change @rpath/libndi.4.dylib /Library/NDI\ SDK\ for\ Apple/lib/x64/libndi.4.dylib ffplay
```

Stream a test pattern in NDI, with a source named 'test'

```
ffmpeg -re -f lavfi -i smptebars -crf 18 -s 1280x720 -r 25 -pix_fmt uyvy422 -f libndi_newtek 'test'
```

List NDI sources found on the local network:

```
ffmpeg -f libndi_newtek -find_sources 1 -i dummy

[libndi_newtek @ 0x7fccb6808200] Found 1 NDI sources:
[libndi_newtek @ 0x7fccb6808200] 	'MAC.LOCAL (test)'	'127.0.0.1:5961'
```

Play NDI source:
```
ffplay -f libndi_newtek -i 'test'
```

NDI Resources:
* <http://haytech.blogspot.com/2018/03/ndi-and-ffmpeg-streaming-commands.html> useful commands
* <https://slepin.fr/obs-ndi/> Newtek binaires
