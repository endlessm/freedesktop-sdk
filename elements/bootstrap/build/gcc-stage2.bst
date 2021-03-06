kind: autotools
description: GNU gcc Stage 2

depends:
- filename: bootstrap/build/gcc-stage-2-build-deps.bst
  type: build

- filename: bootstrap/build/binutils-stage1.bst
  type: runtime

(@):
- elements/bootstrap/include/gcc-arch-opts.yml
- elements/bootstrap/include/gcc-source.yml
- elements/bootstrap/include/build.yml

environment:
  CFLAGS_FOR_TARGET:  "%{target_flags}"
  CXXFLAGS_FOR_TARGET: "%{target_flags}"
  LDFLAGS_FOR_TARGET:  "%{ldflags_defaults}"
  PYTHON: python3

variables:
  conf-link-args: |
    --enable-shared \
    --enable-static
  prefix: '%{tools}'
  lib: lib

  conf-local: |
    --target=%{triplet} \
    --enable-multiarch \
    --disable-multilib \
    --disable-bootstrap \
    --disable-nls \
    --with-sysroot=%{sysroot} \
    --enable-languages=c,c++,fortran \
    --enable-default-pie \
    --enable-default-ssp \
    --with-isl \
    --disable-libssp \
    --enable-deterministic-archives \
    --enable-linker-build-id \
    %{conf-extra}

  # strip-binaries fails when cross compiling because artifact
  # contains 2 architectures.
  strip-binaries: "true"

config:
  install-commands:
    (>):
    - |
      rm "%{install-root}%{bindir}/%{triplet}-c++"
      ln -s "%{triplet}-g++" "%{install-root}%{bindir}/%{triplet}-c++"

    - |
      rm "%{install-root}%{bindir}/%{triplet}-gcc"
      ln -s "%{triplet}-gcc-$(cat gcc/BASE-VER)" "%{install-root}%{bindir}/%{triplet}-gcc"

    - |
      for f in "%{install-root}%{bindir}/"*; do
        base="$(basename "${f}")"
        case "${base}" in
          %{triplet}-*)
            continue
          ;;
          *)
            if [ -f "%{install-root}%{bindir}/%{triplet}-${base}" ]; then
              rm "${f}"
              ln -s "%{triplet}-${base}" "${f}"
            fi
          ;;
        esac
      done

    - |
      rm "%{install-root}%{infodir}/dir"
