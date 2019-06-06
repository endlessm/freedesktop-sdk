kind: cmake

depends:
- filename: bootstrap-import.bst
- filename: public-stacks/buildsystem-cmake.bst
  type: build
- filename: components/extra-cmake-modules.bst
  type: build
- filename: components/gtk3.bst

variables:
  cmake-local: |
    -DLIB_INSTALL_DIR=%{libdir} \
    -DSYSCONFDIR=%{sysconfdir} \
    -DENABLE_QT=Off \
    -DENABLE_PINYIN=Off \
    -DENABLE_TABLE=Off \
    -DENABLE_GIR=Off \
    -DENABLE_GTK3_IM_MODULE=On \
    -DENABLE_OPENCC=Off \
    -DENABLE_CAIRO=Off \
    -DENABLE_SPELL=Off \
    -DENABLE_GTK2_IM_MODULE=Off \
    -DENABLE_LIBXML2=Off \
    -DENABLE_X11=Off \
    -DENABLE_ENCHANT=Off \
    -DENABLE_PRESAGE=Off

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libfcitx-core.so'
        - '%{libdir}/libfcitx-gclient.so'
        - '%{libdir}/libfcitx-config.so'
        - '%{libdir}/libfcitx-utils.so'

sources:
- kind: git_tag
  url: gitlab:fcitx/fcitx.git
  track: master
  ref: 4.2.9.6-0-g6fdfaa072cf634d81d4cbb5ecb288c3a63411151