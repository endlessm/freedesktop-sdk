kind: autotools

depends:
- filename: bootstrap-import.bst
- filename: components/gnutls.bst
- filename: public-stacks/buildsystem-autotools.bst
  type: build
- filename: components/gzip.bst
  type: build

# -Wno-error=sign-conversion is needed to suppress fatal warnings when building
# cups from git: https://github.com/apple/cups/issues/5483#issuecomment-455227747
variables:
  builddir: ''
  conf-local: |
    --enable-debug \
    --with-components=core \
    --with-dbusdir=/etc/dbus-1 \
    --disable-systemd \
    --enable-threads \
    --enable-gnutls \
    localedir=/usr/share/locale \
    DSOFLAGS="$CFLAGS $LDFLAGS"

config:
  install-commands:
  - |
    make -j1 DSTROOT="%{install-root}" install

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{bindir}/cups-config'
        - '%{libdir}/libcups.so'

sources:
- kind: git_tag
  url: github:apple/cups.git
  track: branch-2.2
  ref: v2.2.11-0-ge4a0aa86c96b5ddda3770c46709f4dee9a59071f
- kind: patch
  path: patches/cups/cups-disable-werror.patch