kind: flatpak_image

config:
  directory: '%{debugdir}%{libdir}'
  include:
  - debug

  metadata:
    Runtime:
      name: org.freedesktop.Sdk.Compat.%{flatpak_arch}.Debug

    ExtensionOf:
      ref: runtime/org.freedesktop.Sdk/%{flatpak_arch}/%{branch}

depends:
- filename: sdk-image.bst
  type: build
