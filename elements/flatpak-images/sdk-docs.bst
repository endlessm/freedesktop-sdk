kind: flatpak_image

config:
  directory: '%{datadir}/runtime/docs'

  metadata:
    Runtime:
      name: org.freedesktop.Sdk.Docs

    ExtensionOf:
      ref: runtime/org.freedesktop.Sdk/%{flatpak_arch}/%{branch}

depends:
- filename: sdk-image.bst
  type: build
