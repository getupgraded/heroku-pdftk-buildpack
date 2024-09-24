#!/bin/bash

set -e

BUILD_DIR=$1
CACHE_DIR=$2

tarball_url=https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/pdftk-2.02-src.zip
temp_dir=$(mktemp -d /tmp/compile.XXXXXXXXXX)

echo "Serving files from /tmp on $PORT"
cd /tmp
python3 -m http.server $PORT &

cd $temp_dir
echo "Temp dir: $temp_dir"

echo "Downloading $tarball_url"
curl -L $tarball_url > t.zip
unzip t.zip 

echo "Patching GCJ to work"
cp /app/.apt/usr/bin/gcj-13 /app/.apt/usr/bin/gcj-13-orig 
sed -i.bak s/\\/usr\\/share\\/java\\/libgcj-13.0.0.jar/~usr\\/share\\/java\\/libgcj-13.0.0.jar/g /app/.apt/usr/bin/gcj-13

cp /app/.apt/usr/lib/gcc/x86_64-linux-gnu/13/ecj1 /app/.apt/usr/lib/gcc/x86_64-linux-gnu/13/ecj1-orig
sed -i.bak s/\\/usr\\/share\\/java/~usr\\/share\\/java/g /app/.apt/usr/lib/gcc/x86_64-linux-gnu/13/ecj1


echo "Compiling"
(
	cd pdftk-*
	cd java
	ln -s /app/.apt/usr/ ~usr
	cd ..
	cd pdftk
	ln -s /app/.apt/usr/ ~usr
	
	sed -i.bak s/\\/usr\\/lib/~usr\\/lib/g ./~usr/lib/x86_64-linux-gnu/libm.so
	sed -i.bak s/\\/usr\\/lib/~usr\\/lib/g ./~usr/lib/x86_64-linux-gnu/libc.so
	
	sed -i.bak s/VERSUFF=-4.6/VERSUFF=-13/g Makefile.Debian 
	sed -i.bak s/\\/usr\\/share\\/java/~usr\\/share\\/java/g Makefile.Debian 
	sed -i.bak "s/CXXFLAGS=/CXXFLAGS= -I\\/app\\/.apt\\/usr\\/include\\/c++\\/13\\/ -idirafter\\/app\\/.apt\\/usr\\/include -I\\/app\\/.apt\\/usr\\/include\\/x86_64-linux-gnu /g" Makefile.Debian 
	
	export CPATH=/app/.apt/usr/include/c++/13:`pwd`/../java
	export LD_LIBRARY_PATH=/app/.apt/usr/lib:/app/.apt/usr/lib/x86_64-linux-gnu
	
	make -f Makefile.Debian 

	# Create binaries-$STACK directory
	mkdir -p "$BUILD_DIR/binaries-$STACK"

	# Move pdftk binary and required libraries
	mv pdftk "$BUILD_DIR/binaries-$STACK/"
	cp /app/.apt/usr/lib/x86_64-linux-gnu/libgcj.so.23 "$BUILD_DIR/binaries-$STACK/"

	# The caching will be handled by the compile script
)

while true
do
	sleep 1
	echo "."
done
