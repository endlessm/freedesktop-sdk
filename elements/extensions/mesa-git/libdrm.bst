kind: meson
description: libdrm

depends:
- filename: bootstrap-import.bst
- filename: public-stacks/buildsystem-meson.bst
  type: build
- filename: components/xorg-lib-pciaccess.bst
- filename: components/libdrm.bst

variables:
  prefix: "/usr/lib/%{gcc_triplet}/GL/mesa-git"
  lib: "lib"
  debugdir: "/usr/lib/debug"

  meson-local: |
    -Detnaviv=true \
    -Dtegra=true \
    -Dudev=false \
    -Dlibdrm=false \
    -Dlibkms=false \

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libdrm_*.so'

sources:
- kind: git_tag
  url: freedesktop:mesa/drm.git
  track: master
  # Currently backends from master are not compatible with the last
  # release of libdrm. We need to wait for a release and an update
  # of components/libdrm.bst before uncommenting the following.
  #track-tags: false
  ref: libdrm-2.4.100-0-g0190f49a139e7069d7cad6a6890832831da1aa8b
- kind: patch
  path: patches/libdrm/libdrm_disable_libdrm.patch
