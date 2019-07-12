kind: autotools

depends:
- filename: bootstrap-import.bst
- filename: components/libpng.bst
- filename: components/harfbuzz.bst
- filename: components/freetype-stage1.bst
  type: build
- filename: public-stacks/buildsystem-autotools.bst
  type: build

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{bindir}/freetype-config'
        - '%{libdir}/libfreetype.so'

  cpe:
    version: '2.10.0'
    product: 'freetype2'
    vendor: 'freetype'

variables:
  conf-local: |
    --enable-freetype-config \
    --with-zlib=yes \
    --with-bzip2=yes \
    --with-png=yes \
    --with-harfbuzz=yes

config:
  configure-commands:
    (<):
    - ./autogen.sh

sources:
- kind: git_tag
  url: savannah:freetype/freetype2.git
  track: master
  ref: VER-2-10-0-0-gfbbcf50367403a6316a013b51690071198962920