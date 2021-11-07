#!/bin/sh

# Add Packages
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
    sudo apt purge "?name(^remmina.*)" "?name(^libfreerdp.*)" "?name(^freerdp.*)" "?name(^libwinpr.*)"
}

# Main.
# addPackages
# removeBinPackages
/usr/bin/cmake -GNinja -DCMAKE_BUILD_TYPE=Release \
    -DWITH_WWW=OFF \
    -DWITH_LIBVNCSERVER=ON \
    -DWITH_GVNC=ON \
    -DWITH_CUPS=OFF \
    -DWITH_SPICE=OFF \
    -DWITH_PCSC=OFF \
    -DWITH_NEWS=OFF \
    -DCMAKE_INSTALL_PREFIX:PATH=/opt/remmina \
    -DCMAKE_PREFIX_PATH=/opt/remmina/freerdp \
    --build=build .

# cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX:PATH=/opt/remmina_devel/remmina -DCMAKE_PREFIX_PATH=/opt/remmina_devel/freerdp --build=build .


