kind: flatpak_repo
description: Generates a flatpak repository with all flatpak image elements

depends:
- filename: public-stacks/flatpak-publish-tools.bst
  type: build
- filename: flatpak-release-deps.bst
  type: build

config:
  arch: '%{flatpak_arch}' # This is the interface for flatpak-repo plugin 
  repo-mode: bare-user-only
  environment:
  - public-stacks/flatpak-publish-tools.bst
  (?):
  - target_arch == 'i686':
      copy-refs:
      - src: runtime/org.freedesktop.Platform.Compat.%{flatpak_arch}/%{flatpak_arch}/%{branch}
        dest: runtime/org.freedesktop.Platform.Compat.%{flatpak_arch}/x86_64/%{branch}
      - src: runtime/org.freedesktop.Platform.Compat.%{flatpak_arch}.Debug/%{flatpak_arch}/%{branch}
        dest: runtime/org.freedesktop.Platform.Compat.%{flatpak_arch}.Debug/x86_64/%{branch}
      - src: runtime/org.freedesktop.Platform.GL.default/%{flatpak_arch}/%{branch}
        dest: runtime/org.freedesktop.Platform.GL32.default/x86_64/%{branch}
      - src: runtime/org.freedesktop.Sdk.Compat.%{flatpak_arch}/%{flatpak_arch}/%{branch}
        dest: runtime/org.freedesktop.Sdk.Compat.%{flatpak_arch}/x86_64/%{branch}
      - src: runtime/org.freedesktop.Sdk.Compat.%{flatpak_arch}.Debug/%{flatpak_arch}/%{branch}
        dest: runtime/org.freedesktop.Sdk.Compat.%{flatpak_arch}.Debug/x86_64/%{branch}
      - src: runtime/org.freedesktop.Platform.VAAPI.Intel/%{flatpak_arch}/%{branch}
        dest: runtime/org.freedesktop.Platform.VAAPI.Intel.%{flatpak_arch}/x86_64/%{branch}
      - src: runtime/org.freedesktop.Platform.GL.mesa-git/%{flatpak_arch}/%{branch}
        dest: runtime/org.freedesktop.Platform.GL32.mesa-git/x86_64/%{branch}
      - src: runtime/org.freedesktop.Platform.ffmpeg-full/%{flatpak_arch}/%{branch}
        dest: untime/org.freedesktop.Platform.ffmpeg-full.%{flatpak_arch}/x86_64/%{branch}

  - target_arch == 'arm':
      copy-refs:
      - src: runtime/org.freedesktop.Platform.Compat.%{flatpak_arch}/%{flatpak_arch}/%{branch}
        dest: runtime/org.freedesktop.Platform.Compat.%{flatpak_arch}/aarch64/%{branch}
      - src: runtime/org.freedesktop.Platform.Compat.%{flatpak_arch}.Debug/%{flatpak_arch}/%{branch}
        dest: runtime/org.freedesktop.Platform.Compat.%{flatpak_arch}.Debug/aarch64/%{branch}
      - src: runtime/org.freedesktop.Platform.GL.default/%{flatpak_arch}/%{branch}
        dest: runtime/org.freedesktop.Platform.GL32.default/aarch64/%{branch}
      - src: runtime/org.freedesktop.Sdk.Compat.%{flatpak_arch}/%{flatpak_arch}/%{branch}
        dest: runtime/org.freedesktop.Sdk.Compat.%{flatpak_arch}/x86_64/%{branch}
      - src: runtime/org.freedesktop.Sdk.Compat.%{flatpak_arch}.Debug/%{flatpak_arch}/%{branch}
        dest: runtime/org.freedesktop.Sdk.Compat.%{flatpak_arch}.Debug/x86_64/%{branch}

  - target_arch == 'aarch64':
      copy-refs:
      - src: runtime/org.freedesktop.Sdk.Compat.%{flatpak_arch}/%{flatpak_arch}/%{branch}
        dest: runtime/org.freedesktop.Sdk.Compat.%{flatpak_arch}/x86_64/%{branch}
      - src: runtime/org.freedesktop.Sdk.Compat.%{flatpak_arch}.Debug/%{flatpak_arch}/%{branch}
        dest: runtime/org.freedesktop.Sdk.Compat.%{flatpak_arch}.Debug/x86_64/%{branch}
