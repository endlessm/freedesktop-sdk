kind: manual

build-depends:
- bootstrap-import.bst
- components/m4.bst

runtime-depends:
- components/systemd.bst
- components/ostree.bst

variables:
  (@):
  - ostree-config.yml

config:
  build-commands:
  - |
    m4 -DOSTREE_REMOTE_URL="%{ostree-remote-url}" \
      freedesktop-sdk.conf.in >freedesktop-sdk.conf

  install-commands:
  - |
    mkdir %{install-root}/boot
    mkdir %{install-root}/efi
    mkdir %{install-root}/etc
    mkdir %{install-root}/mnt
    mkdir %{install-root}/run
    mkdir %{install-root}/opt
    mkdir %{install-root}/sys
    mkdir %{install-root}/tmp
    mkdir %{install-root}/dev
    mkdir %{install-root}/proc

  - |
    mkdir -p "%{install-root}/sysroot"
    ln -s sysroot/ostree "%{install-root}/ostree"
    ln -s var/home "%{install-root}/home"
    ln -s var/roothome "%{install-root}/root"
    ln -s run/media "%{install-root}/media"

  - |
    install -Dm644 -t "%{install-root}/usr/lib/tmpfiles.d" ostree.conf
    install -Dm644 -t "%{install-root}/etc/pki/ostree" fdsdk.gpg
    install -Dm644 -t "%{install-root}/etc/ostree/remotes.d" freedesktop-sdk.conf

sources:
- kind: local
  path: files/vm/ostree-config
