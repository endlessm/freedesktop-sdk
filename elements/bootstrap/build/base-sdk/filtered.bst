kind: filter

(?):
- bootstrap_build_arch == "x86_64":
    depends:
    - filename: bootstrap/build/base-sdk/image-x86_64.bst
      type: build
- bootstrap_build_arch == "aarch64":
    depends:
    - filename: bootstrap/build/base-sdk/image-aarch64.bst
      type: build
- bootstrap_build_arch == "powerpc64le":
    depends:
    - filename: bootstrap/build/base-sdk/image-powerpc64le.bst
      type: build
- bootstrap_build_arch == "arm":
    depends:
    - filename: bootstrap/build/base-sdk/image-arm.bst
      type: build

config:
  exclude:
    - filter
  include-orphans: True
