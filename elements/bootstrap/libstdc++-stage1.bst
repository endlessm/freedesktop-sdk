kind: autotools
description: GNU C Library

depends:
- filename: bootstrap/libstdc++-stage1-build-deps.bst
  type: build
- filename: bootstrap/glibc.bst
  type: runtime

(@):
- elements/bootstrap/include/gcc-source.yml
- elements/bootstrap/include/target.yml

variables:
  # Does not compile with -D_FORTIFY_SOURCE=2
  target_flags_fortify_source: ''

  lib: lib

  conf-local: |
    --disable-nls \
    --disable-multilib

config:
  configure-commands:
  - |
    mkdir "%{builddir}"
    cd "%{builddir}"
    ../libstdc++-v3/%{configure}
