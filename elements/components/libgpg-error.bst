kind: autotools

depends:
- filename: bootstrap-import.bst
- filename: public-stacks/buildsystem-autotools.bst
  type: build
- filename: components/texinfo.bst
  type: build

variables:
  conf-local: |
    --enable-maintainer-mode \
    --disable-doc

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libgpg-error.so'

sources:
- kind: git_tag
  url: gnupg:libgpg-error.git
  track: master
  ref: gpgrt-1.35-0-g2421afddf6ae5a245e6dd1a59779bd26bf225253