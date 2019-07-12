kind: cmake

depends:
- filename: bootstrap-import.bst
- filename: public-stacks/buildsystem-cmake.bst
  type: build
- filename: components/nasm.bst
  type: build

variables:
  cmake-local: |
    -DCMAKE_INSTALL_LIBDIR="%{libdir}"

config:
  install-commands:
    (>):
    - |
      find "%{install-root}" -name "lib*.a" -exec rm {} ";"

    - |
      mkdir -p "%{install-root}%{includedir}/%{gcc_triplet}/"
      mv "%{install-root}%{includedir}/jconfig.h" "%{install-root}%{prefix}/include/%{gcc_triplet}/"

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libjpeg.so'
        - '%{libdir}/libturbojpeg.so'
  cpe:
    product: libjpeg-turbo

sources:
- kind: git_tag
  url: github:libjpeg-turbo/libjpeg-turbo.git
  track: master
  ref: 2.0.0-3-g2260b66e1671038a362dca4a204c28d72b8f7e4e
- kind: patch
  path: patches/jpeg/no-rpath.patch