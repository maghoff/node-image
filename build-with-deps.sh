#!/bin/bash -e

PREFIX="$(pwd)/.tmp/prefix"
mkdir -p "$PREFIX/include"
mkdir -p "$PREFIX/lib"

mkdir -p .tmp
pushd .tmp

if ! [ -d FreeImage ]
then
	if ! [ -e freeimage.zip ]
	then
		curl -o freeimage.zip -L 'http://downloads.sourceforge.net/project/freeimage/Source%20Distribution/3.15.4/FreeImage3154.zip?r=http%3A%2F%2Ffreeimage.sourceforge.net%2Fdownload.html&ts=1362172561&use_mirror=switch'
	fi

	unzip -o freeimage.zip
fi

mkdir -p bin
pushd bin
ln -sf "$(which g++)" g++-4.0
ln -sf "$(which gcc)" gcc-4.0

# --- --- --- Fake install script --- --- ---
cat >install << EOF
#!/bin/bash -e

MODE=0644

OPTIND=1
while getopts "dm:o:g:" opt; do
	case "\$opt" in
	d) exit 0 ;;
	m) MODE="\$OPTARG" ;;
	o) ;;
	g) ;;
	esac
done
shift \$((OPTIND-1))

#chmod "\$MODE" "\$SRC"
mkdir -p "\${@: - 1}"
cp "\$@"
EOF
chmod a+x install
# --- --- --- --- --- --- --- --- --- --- ---

export PATH=$(pwd):$PATH
hash -r
popd

if ! [ -e FreeImage/installed ]
then
	pushd FreeImage

	if [[ "$OSTYPE" == "darwin"* ]]
	then
		OSX_VERSION=$(( $( sysctl -n kern.osrelease | cut -d . -f 1 ) - 4 ))

		sed -i \
			-e "s|/Developer/SDKs/MacOSX10\..\.sdk|/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.$OSX_VERSION.sdk|g" \
			Makefile.osx

		sed -i \
			-e 's|$(STATICLIB)-ppc $(STATICLIB)-i386 $(STATICLIB)-x86_64|$(STATICLIB)-x86_64|g' \
			Makefile.osx

		sed -i \
			-e 's|$(SHAREDLIB)-ppc $(SHAREDLIB)-i386 $(SHAREDLIB)-x86_64|$(SHAREDLIB)-x86_64|g' \
			Makefile.osx

		sed -i \
			-e 's|PREFIX = .*|PREFIX = $(DESTDIR)|g' \
			Makefile.osx
	fi

	export CXXFLAGS="-include string.h"
	make
	make install DESTDIR="$PREFIX"

	# Blunt way to make sure it links to the static library:
	echo rm -f "$PREFIX"/usr/lib/*.so* "$PREFIX"/lib/*.dylib
	rm -f "$PREFIX"/usr/lib/*.so* "$PREFIX"/lib/*.dylib

	touch installed

	popd
fi

popd


export CPLUS_INCLUDE_PATH="$PREFIX/include:$PREFIX/usr/include:$CPLUS_INCLUDE_PATH"
export LIBRARY_PATH="$PREFIX/lib:$PREFIX/usr/lib:$LIBRARY_PATH"

node-gyp configure build
