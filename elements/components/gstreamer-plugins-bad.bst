kind: meson

depends:
- filename: bootstrap-import.bst
- filename: components/aom.bst
- filename: components/orc.bst
- filename: components/frei0r.bst
- filename: components/gobject-introspection.bst
  type: build
- filename: components/gstreamer.bst
- filename: components/gstreamer-plugins-base.bst
- filename: components/ladspa-sdk.bst
- filename: components/libdrm.bst
- filename: components/libfdk-aac.bst
- filename: components/libglvnd.bst
- filename: components/libnice.bst
- filename: components/librsvg.bst
- filename: components/openal.bst
- filename: components/vulkan.bst
- filename: components/wayland.bst
- filename: components/wayland-protocols.bst
  type: build
- filename: public-stacks/buildsystem-meson.bst
  type: build
- filename: components/curl.bst
- filename: components/libwebp.bst
- filename: components/sndfile.bst
- filename: components/webrtc-audio-processing.bst


variables:
  meson-local: >-
    -Daom=enabled
    -Dbz2=enabled
    -Dcurl=enabled
    -Dfdkaac=enabled
    -Dfrei0r=enabled
    -Dgl=enabled
    -Dhls=enabled
    -Dintrospection=enabled
    -Dladspa=enabled
    -Dopenal=enabled
    -Dopus=enabled
    -Dorc=enabled
    -Dpackage-origin="freedesktop-sdk"
    -Drsvg=enabled
    -Dsndfile=enabled
    -Dvdpau=disabled
    -Dvulkan=enabled
    -Dwayland=enabled
    -Dwebp=enabled

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libgstbadallocators-1.0.so'
        - '%{libdir}/libgstbadbase-1.0.so'
        - '%{libdir}/libgstcodecparsers-1.0.so'
        - '%{libdir}/libgstplayer-1.0.so'
        - '%{libdir}/libgstbadvideo-1.0.so'
        - '%{libdir}/libgstbadaudio-1.0.so'
        - '%{libdir}/libgstmpegts-1.0.so'
        - '%{libdir}/libgstadaptivedemux-1.0.so'
        - '%{libdir}/libgstinsertbin-1.0.so'
        - '%{libdir}/libgsturidownloader-1.0.so'
        - '%{libdir}/libgstbasecamerabinsrc-1.0.so'
        - '%{libdir}/libgstphotography-1.0.so'
        - '%{libdir}/libgstisoff-1.0.so'
        - '%{libdir}/libgstwebrtc-1.0.so'
        - '%{libdir}/libgstwayland-1.0.so'
        - '%{libdir}/libgstsctp-1.0.so'

sources:
- kind: git_tag
  url: freedesktop:gstreamer/gst-plugins-bad
  track: '1.16'
  ref: 1.16.0-0-g5fde70bb63a1cbf6f734fb2429e74ffb53126217
  submodules:
    common:
      checkout: true
      url: freedesktop:gstreamer/common
- kind: patch
  path: patches/gstreamer-plugins-bad/gst-plugins-bad-Optional-LRDF-dep-for-ladspa.patch