#!/usr/bin/env - LC_ALL=C SHELL=/bin/bash bash -x

projectroot="$(cd "$(dirname "$0")"; pwd)"
srcdir=${projectroot}/sources
test -f ${srcdir}/m4-1.4.16.tar.bz2 || exit

bootstrap_tar=${projectroot}/binaries/bootstrap.tar.bz2
domain=com.rawtherapee.RawTherapee
destroot=/tmp/${domain}
builddir=/tmp/${domain}_build
prefix=${destroot}/RawTherapee.app/Contents/SharedSupport
sdkroot=/Developer/SDKs/MacOSX10.6.sdk

PATH=$(/usr/sbin/sysctl -n user.cs_path)
PATH=/usr/local/git/bin:$PATH
PATH=/Library/Frameworks/Python.framework/Versions/2.7/bin:$PATH
PATH=${prefix}/bin:${prefix}/sbin:$PATH
export PATH
export CC="/usr/local/bin/ccache $( xcrun -find gcc-4.2)"
export CXX="/usr/local/bin/ccache $(xcrun -find g++-4.2)"
export CFLAGS="-pipe -m64 -arch x86_64 -march=core2 -mtune=core2"
export CXXFLAGS="${CFLAGS}"
export CPPFLAGS="-isysroot ${sdkroot} -I${prefix}/include"
export LDFLAGS="-Wl,-headerpad_max_install_names -Wl,-syslibroot,${sdkroot} -L${prefix}/lib"
export MACOSX_DEPLOYMENT_TARGET=10.6
export OBJDUMP=${prefix}/bin/gobjdump
export OBJCOPY=${prefix}/bin/gobjcopy
make_args="-j $(($(sysctl -n hw.ncpu) + 2))"
configure_args="\
--prefix=${prefix} \
--build=x86_64-apple-darwin10 \
--enable-shared --enable-static \
--disable-dependency-tracking \
--disable-gtk-doc \
--without-x"

function BuildDeps_ {
  test -n "$1" || exit
  local f=${srcdir}/$1 &&
  shift &&
  
  cd ${builddir} &&
  case ${f} in
    *.xz)
      xzcat ${f} | tar -x -
    ;;
    *)
      tar -xf ${f}
    ;;
  esac &&
  
  case ${f} in
    */icu*)
      cd icu/source
    ;;
    *)
      cd $(basename ${f%.tar.*})
    ;;
  esac &&
  
  case ${f} in
    */glib-2.*)
      sh autogen.sh ${configure_args}
    ;;
    *)
      sh configure ${configure_args} "$@"
    ;;
  esac &&
  make ${make_args} &&
  make install || exit
}

#rm -rf ${destroot} ${builddir}
#install -d ${prefix}/{bin,include,share} ${builddir}

! : && {
if test -f ${bootstrap_tar}; then tar -xvPf ${bootstrap_tar}
else
  BuildDeps_ m4-1.4.16.tar.bz2 --program-prefix=g && (
    cd ${prefix}/bin &&
    ln -sf {g,}m4
  ) || exit
  BuildDeps_ autoconf-2.69.tar.gz
  BuildDeps_ automake-1.13.1.tar.gz
  BuildDeps_ libtool-2.4.2.tar.gz --program-prefix=g && (
    cd ${prefix}/bin &&
    ln -sf {g,}libtool &&
    ln -sf {g,}libtoolize
  ) || exit
  BuildDeps_ valgrind-3.8.1.tar.bz2 --enable-only64bit --without-mpicc
  BuildDeps_ pkg-config-0.28.tar.gz --disable-host-tool --with-internal-glib --with-pc-path=${prefix}/lib/pkgconfig:${prefix}/share/pkgconfig:/usr/lib
  BuildDeps_ gettext-0.18.2.tar.gz
  BuildDeps_ libiconv-1.14.tar.gz
  BuildDeps_ binutils-2.23.2.tar.bz2 --program-prefix=g
  BuildDeps_ gdb-7.6.tar.bz2
  BuildDeps_ xz-5.0.4.tar.bz2
  BuildDeps_ libffi-3.0.13.tar.gz
  BuildDeps_ glib-2.36.1.tar.gz
  BuildDeps_ freetype-2.4.11.tar.gz
  BuildDeps_ fontconfig-2.10.92.tar.bz2
  tar -cP ${destroot} | bzip2 > ${bootstrap_tar}
fi

BuildDeps_ libpng-1.6.1.tar.gz
BuildDeps_ nasm-2.10.07.tar.xz
BuildDeps_ libjpeg-turbo-1.2.1.tar.gz --with-jpeg8
BuildDeps_ tiff-4.0.3.tar.gz
BuildDeps_ pixman-0.28.2.tar.gz
BuildDeps_ lzo-2.06.tar.gz
BuildDeps_ cairo-1.12.14.tar.xz --enable-tee --enable-xml --enable-quartz-image
BuildDeps_ icu4c-51_1-src.tgz
(
  cd ${builddir} &&
  tar xf ${srcdir}/graphite2-1.2.1.tgz &&
  install -d graphite2-1.2.1/build
  cd $_ &&
  /usr/local/bin/cmake -DCMAKE_INSTALL_PREFIX=${prefix} -DCMAKE_PREFIX_PATH=${prefix} -DCMAKE_BUILD_TYPE=Release -DDOXYGEN= .. &&
  make ${make_args} &&
  make install
) || exit



:
afplay /System/Library/Sounds/Hero.aiff
