kind: autotools

depends:
- bootstrap-import.bst
- components/libportal.bst

build-depends:
- public-stacks/buildsystem-autotools.bst
- components/flatpak.bst
- components/glib.bst
- components/fontconfig.bst
- components/pipewire.bst
- components/geoclue.bst

public:
  bst:
    split-rules:
      interfaces:
      - "%{datadir}/pkgconfig/*.pc"
      - "%{datadir}/dbus-1/interfaces"
      - "%{datadir}/dbus-1/interfaces/org.freedesktop.portal*"

sources:
- kind: git_tag
  url: github:flatpak/xdg-desktop-portal.git
  track: master
  ref: 1.6.0-0-g28b93e213a83c78bb6d65d5a1a65c57d62957827
