kind: autotools

depends:
- filename: bootstrap-import.bst
- filename: public-stacks/buildsystem-autotools.bst
  type: build
- filename: components/pcre2.bst
- filename: components/libsepol.bst

variables:
  builddir: ''

environment:
  USE_PCRE2: y
  LIBDIR: '%{libdir}'
  SHLIBDIR: '%{libdir}'
  SBINDIR: '%{sbindir}'

config:
  configure-commands: []
  build-commands:
  - |
    cd libselinux && %{make}

  install-commands:
  - |
    cd libselinux && %{make-install}

  - |
    rm "%{install-root}/%{libdir}/libselinux.a"

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libselinux.so'

sources:
- kind: git_tag
  url: github:SELinuxProject/selinux.git
  track: master
  match:
  - libselinux-*
  exclude:
  - '*rc*'
  ref: libselinux-3.0-0-gdca7ce8195d241bf44eb4b158ef2e5d6e3b9963a
