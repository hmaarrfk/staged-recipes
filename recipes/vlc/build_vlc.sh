set -ex

# They need a c99 compiler...
# Replace the ending -cc ${CC} with -c99
export BUILDCC="$(echo ${CC} | sed 's/-cc$//')-c99"

EXTRA_CONFIGURE_ARGS=""
if [[ "${license_family:-gpl}" == "gpl" ]]; then
    EXTRA_CONFIGURE_ARGS="${EXTRA_CONFIGURE_ARGS} --enable-postproc"
else
    EXTRA_CONFIGURE_ARGS="${EXTRA_CONFIGURE_ARGS} --disable-postproc"
fi
if [[ "${target_platform}" == "linux-*" ]]; then
    EXTRA_CONFIGURE_ARGS="${EXTRA_CONFIGURE_ARGS} --enable-udev"
fi

if [[ "${PKG_NAME:-libvlc}" == "vlc-bin" ]]; then
    # Only build cvlc (command line) and nvlc (ncurses)
    EXTRA_CONFIGURE_ARGS="${EXTRA_CONFIGURE_ARGS} --enable-vlc --disable-qt"
elif [[ "${PKG_NAME:-libvlc}" == "vlc-gui" ]]; then
    EXTRA_CONFIGURE_ARGS="${EXTRA_CONFIGURE_ARGS} --enable-vlc --enable-qt --enable-skins2"
else
    EXTRA_CONFIGURE_ARGS="${EXTRA_CONFIGURE_ARGS} --disable-vlc"
fi
# I couldn't get wayland to work on vlc4, but we aren't building vlc4
# we are building vlc3
# --disable-wayland
#
# Seems like there is a bug in the C99 script
# https://github.com/conda-forge/ctng-compiler-activation-feedstock/issues/150
sed -i "s,^exec gcc ,exec ${CC} ," ${BUILDCC}

# Parts I would love to enable in the future
#     --enable-matroska  -- needs https://github.com/Matroska-Org/libebml
#     --enable-freerdp
#     --enable-smbclient  -- needs smbclient
#     --enable-nfs      -- needs libnfs
#     --enable-smb2  -- needs libsmb2
#     --enable-shine -- needs libshine
#     --enable-opencv -- needs libopencv
#     --enable-qt -- needs qt

./bootstrap
./configure \
    ${EXTRA_CONFIGURE_ARGS} \
    --enable-archive \
    --enable-sftp \
    --enable-v4l2 \
    --enable-screen \
    --enable-ogg \
    --enable-mpg123 \
    --enable-gst-decode \
    --enable-avcodec \
    --enable-libva \
    --enable-avformat \
    --enable-swscale \
    --enable-dav1d \
    --enable-vpx \
    --enable-flac \
    --enable-vorbis \
    --enable-opus \
    --enable-png \
    --enable-jpeg \
    --enable-secret \
    --disable-a52 \
    --prefix=${PREFIX}

make -j${CPU_COUNT}
make -j${CPU_COUNT} install

# Remove the pre-made vlc binary
# We will make a conda-forge specific one
rm -f ${PREFIX}/bin/vlc
if [[ $PKG_NAME == "vlc-bin" ]]; then
    # Create a vlc binary that prefers qvlc, then nvlc, then cvlc
    cat <<EOF > ${PREFIX}/bin/vlc
if [[ -x ${PREFIX}/bin/qvlc ]] then
    exec ${PREFIX}/bin/qvlc "\$@"
elif [[ -x ${PREIFX}/bin/nvlc ]] then
    exec ${PREFIX}/bin/nvlc "\$@"
elif [[ -x ${PREFIX}/bin/cvlc ]] then
    exec ${PREFIX}/bin/cvlc "\$@"
else
    echo "No VLC binary interface found"
    exit 1
fi
EOF
fi
