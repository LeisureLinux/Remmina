#!/bin/sh

# Required Packages on Ubuntu/Debian
addPackages () {
    sudo apt install build-essential git-core cmake libssl-dev libx11-dev libxext-dev libxinerama-dev \
  libxcursor-dev libxdamage-dev libxv-dev libxkbfile-dev libasound2-dev libcups2-dev libxml2 libxml2-dev \
  libxrandr-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
  libxi-dev libavutil-dev \
  libavcodec-dev libxtst-dev libgtk-3-dev libgcrypt20-dev libssh-dev libpulse-dev \
  libvte-2.91-dev libxkbfile-dev libtelepathy-glib-dev libjpeg-dev \
  libgnutls28-dev libavahi-ui-gtk3-dev libvncserver-dev \
  libappindicator3-dev intltool libsecret-1-dev libwebkit2gtk-4.0-dev libsystemd-dev \
  libsoup2.4-dev libjson-glib-dev libavresample-dev libsodium-dev \
  libusb-1.0-0-dev libpcre2-dev libicu-dev
}

removeBinPackages () {
    # Remove old packages first to avoid conflict
    sudo apt purge "?name(^remmina.*)" "?name(^libfreerdp.*)" "?name(^freerdp.*)" "?name(^libwinpr.*)"
}

addFreeRDPPackage () {
#############################
# Master clone needed:
sudo apt-get install libavutil-dev libavcodec-dev libavresample-dev
#############################
# Needed packages
# git
# Optional: 
# Where cunit is for the unit tests, directfb is for dfreerdp, xmlto is for man pages, and doxygen for API documentation.
sudo apt-get install libcunit1-dev libdirectfb-dev xmlto doxygen libxtst-dev
# Core Packages Needed
sudo apt-get install ninja-build build-essential debhelper cdbs dpkg-dev autotools-dev cmake pkg-config xmlto libssl-dev docbook-xsl xsltproc libxkbfile-dev libx11-dev libwayland-dev libxrandr-dev libxi-dev libxrender-dev libxext-dev libxinerama-dev libxfixes-dev libxcursor-dev libxv-dev libxdamage-dev libxtst-dev libcups2-dev libpcsclite-dev libasound2-dev libpulse-dev libjpeg-dev libgsm1-dev libusb-1.0-0-dev libudev-dev libdbus-glib-1-dev uuid-dev libxml2-dev libfaad-dev libfaac-dev
# Failed to install
## libgstreamer1.0-dev libgstreamer0.10-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-base0.10-dev 
}

buildFreeRDP () {
    cd ../FreeRDP
    NAME=$(basename $PWD)
    local buildLog=/var/tmp/build${NAME}.log
    [ $? != 0 ] && echo "Please git clone $NAME to $PWD !" && exit 9
    # addFreeRDPPackage
    /usr/bin/ninja clean
    echo "Info: Start building $NAME, view log: $ tail -f $buildLog"
    /usr/bin/cmake -GNinja -DCMAKE_BUILD_TYPE=Release \
        -DCHANNEL_URBDRC=ON -DWITH_DSP_FFMPEG=ON \
        -DWITH_CUPS=OFF -DWITH_PULSE=ON \
        -DWITH_FAAC=ON -DWITH_FAAD2=ON \
        -DWITH_GSM=ON -DWITH_MANPAGES=ON \
        -DWITH_SSE2=ON  -DWITH_ICU=ON \
        -DWITH_X11=ON -DWITH_SERVER=ON \
        -DCMAKE_INSTALL_PREFIX:PATH=$INST_DIR/freerdp . 1>$buildLog 2>&1
    [ $? != 0 ] && echo "Cmake failed!" && exit 1
    echo "Info: Start installing $NAME, view log: $ tail -f $buildLog"
    sudo ninja -j4 -k4 install 1>>$buildLog 2>&1
    cd ../Remmina
}

# Main.
# removeBinPackages
# addPackages
INST_DIR=/opt/remmina
[ ! -f $INST_DIR/freerdp/bin/xfreerdp ] && buildFreeRDP
#
/usr/bin/ninja clean
NAME=$(basename $PWD)
buildLog=/var/tmp/build${NAME}.log
echo "Info: Start building $NAME, view log: $ tail -f $buildLog"
/usr/bin/cmake -GNinja -DCMAKE_BUILD_TYPE=Release \
    -DWITH_LIBVNCSERVER=ON \
    -DWITH_GVNC=ON \
    -DWITH_CUPS=OFF \
    -DWITH_SPICE=OFF \
    -DWITH_WWW=OFF \
    -DWITH_PCSC=OFF \
    -DWITH_NEWS=OFF \
    -DCMAKE_INSTALL_PREFIX:PATH=$INST_DIR \
    -DCMAKE_PREFIX_PATH=$INST_DIR/freerdp \
    --build=build . 1>$buildLog 2>&1
[ $? != 0 ] && echo "Error: Cmake $NAME Failed!" && exit 1
echo "Info: Start Installing $NAME into $INST_DIR, view log: $ tail -f $buildLog"
sudo ninja -j4 -k4 install 1>>$buildLog 2>&1
[ $? != 0 ] && echo "Error: Build $NAME Failed!" && exit 1
