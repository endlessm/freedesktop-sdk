kind: autotools

depends:
- filename: bootstrap-import.bst
- filename: public-stacks/buildsystem-autotools.bst
  type: build
- filename: components/nettle.bst
- filename: components/libtirpc.bst
- filename: components/libdrm.bst
- filename: components/dummy-gbm.bst
- filename: components/libepoxy.bst
- filename: components/pixman.bst
- filename: components/xorg-lib-xkbfile.bst
- filename: components/xorg-lib-xfont2.bst
- filename: components/xorg-lib-xdmcp.bst
- filename: components/xorg-lib-xshmfence.bst
- filename: components/xorg-app-xkbcomp.bst
- filename: components/xorg-font-util.bst
- filename: components/xorg-proto-xorgproto.bst
  type: build
- filename: components/xorg-util-macros.bst
  type: build
- filename: components/wayland.bst
- filename: components/wayland-protocols.bst
  type: build
- filename: components/systemd.bst

variables:
  conf-local: |
    --disable-xvfb \
    --disable-xnest \
    --disable-xwin \
    --enable-glamor \
    --enable-xwayland

sources:
- kind: git_tag
  url: freedesktop:xorg/xserver.git
  track: master
  track-extra:
  - server-1.20-branch
  match:
  - xorg-server-*
  exclude:
  - xorg-server-*.99.*
  ref: xorg-server-1.20.5-0-gfbbdd5613122f0f7d74471f240c28e4c3b796065
- kind: patch
  path: patches/xorg-server/0001-compiler.h-Do-not-include-sys-io.h-on-ARM-with-glibc.patch
