kind: autotools

depends:
- filename: bootstrap-import.bst
- filename: components/libogg.bst
- filename: public-stacks/buildsystem-autotools.bst
  type: build

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libvorbis.so'
        - '%{libdir}/libvorbisfile.so'
        - '%{libdir}/libvorbisenc.so'
  cpe:
    patches:
    - CVE-2018-10392
    - CVE-2018-10393

sources:
- kind: git_tag
  url: github:xiph/vorbis.git
  track: master
  ref: v1.3.6-0-gd22c3ab5f633460abc2532feee60ca0892134cbf
- kind: patch
  path: patches/libvorbis/CVE-2018-10392.patch
