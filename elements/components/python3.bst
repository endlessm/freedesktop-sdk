kind: autotools
description: Python 3

depends:
- filename: bootstrap-import.bst
- filename: public-stacks/buildsystem-autotools.bst
  type: build
- filename: components/expat.bst
- filename: components/libffi.bst
- filename: components/gdbm.bst
- filename: components/sqlite.bst
- filename: components/xz.bst
- filename: components/bluez-headers.bst
  type: build

variables:
  conf-local: |
    --enable-shared \
    --without-ensurepip \
    --with-system-expat \
    --with-system-ffi \
    --enable-loadable-sqlite-extensions \
    --with-dbmliborder=gdbm \
    --with-lto \
    --with-conf-includedir="%{includedir}/%{gcc_triplet}"

config:
  install-commands:
  - |
    if [ -n "%{builddir}" ]; then
    cd %{builddir}
    fi
    %{make-install} DESTSHARED=/usr/lib/python3.8/lib-dynload

  - |
    rm -rf %{install-root}%{bindir}/idle*
  - |
    rm -rf %{install-root}%{indep-libdir}/python3.8/idlelib
  - |
    rm -rf %{install-root}%{indep-libdir}/python3.8/tkinter
  - |
    rm -rf %{install-root}%{indep-libdir}/python3.8/turtle*
  - |
    rm -rf %{install-root}%{indep-libdir}/python3.8/__pycache__/turtle.*
  - |
    rm -rf %{install-root}%{indep-libdir}/python3.8/test
  - |
    rm -rf %{install-root}%{indep-libdir}/python3.8/*/test
  - |
    rm -rf %{install-root}%{indep-libdir}/python3.8/*/tests

  - |
    find "%{install-root}" -name "lib*.a" -exec rm {} ";"

  - |
    cat <<EOF >"%{install-root}%{includedir}/python3.8/pyconfig.h"
    #if defined(__x86_64__)
    # include "x86_64-linux-gnu/python3.8/pyconfig.h"
    #elif defined(__i386__)
    # include "i386-linux-gnu/python3.8/pyconfig.h"
    #elif defined(__aarch64__)
    # include "aarch64-linux-gnu/python3.8/pyconfig.h"
    #elif defined(__arm__)
    # include "arm-linux-gnueabihf/python3.8/pyconfig.h"
    #elif defined(__powerpc64__)
    # include "powerpc64le-linux-gnu/python3.8/pyconfig.h"
    #else
    # error "Unknown cross-compiler"
    #endif
    EOF

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{bindir}/2to3*'
        - '%{bindir}/python3-config'
        - '%{bindir}/python3.8-config'
        - '%{libdir}/libpython3.8.so'
        - '%{indep-libdir}/python3.8/config-3.8-%{gcc_triplet}'
        - '%{indep-libdir}/python3.8/config-3.8-%{gcc_triplet}/**'
        - '%{indep-libdir}/python3.8/lib2to3'
        - '%{indep-libdir}/python3.8/lib2to3/**'
    integration-commands:
    - command -v python || ln -s python3 %{bindir}/python
  cpe:
    product: python
    patches:
    - CVE-2019-16056

sources:
- kind: git_tag
  track: '3.8'
  exclude:
  - v*rc*
  url: github:python/cpython.git
  ref: v3.8.1-0-g1b293b60067f6f4a95984d064ce0f6b6d34c1216
- kind: patch
  path: patches/python3/python3-multiarch-include.patch
