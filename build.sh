#!/bin/sh
MXE=/tmp/mxe
TARGET=x86_64-w64-mingw32.shared
DLL_DIR=$MXE/DLLs
PORTAUDIO_NAME=portaudio_x64
if [ "`pwd`" != $MXE ] ; then
	echo Please clone this repository to /tmp/mxe for reproducible builds >&2
	exit 1
fi
touch src/ffmpeg.mk src/dav1d.mk src/freetype-bootstrap.mk src/libjpeg-turbo.mk src/libpng.mk src/portaudio.mk src/sqlite.mk src/lua.mk src/sdl2.mk src/sdl2_image.mk src/zlib.mk src/libwebp.mk src/tiff.mk
export SOURCE_DATE_EPOCH=0
# Prefer system tools over a possibly broken venv shim (e.g., mako-render).
export PATH=/usr/bin:$PATH
# Force DWARF debug info and assume .loc support to avoid stabs on x86_64.
make -j 24 JOBS=24 MXE_TARGETS=$TARGET \
	CFLAGS_FOR_TARGET='-O2 -gdwarf-2 -gas-loc-support' \
	CXXFLAGS_FOR_TARGET='-O2 -gdwarf-2 -gas-loc-support' \
	ffmpeg sdl2_image freetype-bootstrap portaudio sqlite lua \
	projectm
mkdir -p $DLL_DIR
for i in avcodec-61 avformat-61 avutil-59 swresample-5 swscale-8 libdav1d libjpeg-8 libpng16-16 libtiff-6 libwebp-7 SDL2 SDL2_image zlib1 lua54:lua libsqlite3-0:sqlite3 libfreetype-6:freetype6 libportaudio-2:$PORTAUDIO_NAME ; do
	j=${i##*:}
	i=${i%%:*}
	$MXE/usr/bin/$TARGET-objcopy --only-keep-debug $MXE/usr/$TARGET/bin/$i.dll $DLL_DIR/$j.debug
	(
		cd $DLL_DIR
		set -- `md5sum $j.debug`
		k=$j-$1
		mv $j.debug $k.debug
		$MXE/usr/bin/$TARGET-objcopy -S --add-gnu-debuglink=$k.debug $MXE/usr/$TARGET/bin/$i.dll $j.dll
		chmod a-x $j.dll $k.debug
	)
done

# Add projectM DLL(s) if present.
for dll in "$MXE/usr/$TARGET/bin"/libprojectM*.dll ; do
	[ -e "$dll" ] || continue
	base=$(basename "$dll" .dll)
	$MXE/usr/bin/$TARGET-objcopy --only-keep-debug "$dll" "$DLL_DIR/$base.debug"
	(
		cd "$DLL_DIR"
		set -- `md5sum "$base.debug"`
		k=$base-$1
		mv "$base.debug" "$k.debug"
		$MXE/usr/bin/$TARGET-objcopy -S --add-gnu-debuglink="$k.debug" "$dll" "$base.dll"
		chmod a-x "$base.dll" "$k.debug"
	)
done
