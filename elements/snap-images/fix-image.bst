kind: script
depends:
  - filename: bootstrap-import.bst
    type: build
  - filename: snap-images/snap-image.bst
    type: build

variables:
  install-root: /buildstream-install

  # Note: /app is only for flatpak application compatibility
  # so that applications can bind themselves to the path
  # The rest comes from Snap.
  required-dirs: >-
    /dev
    /etc
    /home
    /root
    /proc
    /sys
    /tmp
    /var/snap
    /var/lib/snapd
    /var/tmp
    /run
    /usr/src
    /var/log
    /media
    /usr/lib/snapd
    /lib/modules
    /mnt
    /usr/local/share/fonts
    /app
    /snap

config:
  layout:
    - element: bootstrap-import.bst
      destination: /
    - element: snap-images/snap-image.bst
      destination: "%{install-root}"
  commands:
    - |
      for dir in %{required-dirs}
      do
        mkdir -p "%{install-root}${dir}"
      done

    - |
      rm "%{install-root}/usr/bin/sh"
      ln -s dash "%{install-root}/usr/bin/sh"
