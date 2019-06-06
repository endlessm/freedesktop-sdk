kind: meson

depends:
- filename: bootstrap-import.bst
- filename: components/cairo.bst
- filename: components/harfbuzz.bst
- filename: components/fontconfig.bst
- filename: components/gobject-introspection.bst
  type: build
- filename: public-stacks/buildsystem-meson.bst
  type: build
- filename: components/fribidi.bst

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libpango-1.0.so'
        - '%{libdir}/libpangoft2-1.0.so'
        - '%{libdir}/libpangocairo-1.0.so'

# Those are the defaults which we explicitly match.
variables:
  meson-local: |
   -Denable_docs=false \
   -Dgir=true

config:
  install-commands:
    (>):
    - |
      rm -rf "%{install-root}%{libexecdir}/installed-tests"
      rm -rf "%{install-root}%{datadir}/installed-tests"

sources:
- kind: git_tag
  url: gnome:pango
  track: master
  ref: 1.43.0-0-g26f1135f374f3ad5eb963dcdf016542fbbda361b
- kind: patch
  path: patches/pango/pango-Make-gobject-2.0-a-non-private-requirement.patch