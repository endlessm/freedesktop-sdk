kind: autotools

depends:
- filename: bootstrap-import.bst
- filename: public-stacks/buildsystem-autotools.bst
  type: build

variables:
  includedir: "%{prefix}/include/%{gcc_triplet}"

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{prefix}/include'
        - '%{bindir}/npth-config'
        - '%{libdir}/libnpth.so'

sources:
- kind: git_tag
  url: gnupg:npth.git
  track: master
  ref: npth-1.6-0-g771287929ed226add3ef27de882c5359dcd3f66e
