kind: autotools
description: GNU gcc Stage 1

depends:
- filename: bootstrap/build/binutils-stage1.bst
- filename: bootstrap/gnu-config.bst
  type: build

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
  prefix: '%{tools}'
  lib: lib

  conf-local: |
    --target=%{triplet} \
    --with-newlib \
    --enable-multiarch \
    --with-sysroot=%{sysroot} \
    --without-headers \
    --disable-bootstrap \
    --disable-nls \
    --disable-shared \
    --disable-threads \
    --disable-libstdcxx \
    --disable-decimal-float \
    --disable-libatomic \
    --disable-libgomp \
    --disable-libmpx \
    --disable-libquadmath \
    --disable-libssp \
    --disable-libvtv \
    --disable-multilib \
    --enable-default-pie \
    --enable-default-ssp \
    --enable-languages=c,c++ \
    --with-isl \
    --enable-deterministic-archives \
    --enable-linker-build-id \
    %{conf-extra}

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
