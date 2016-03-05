class SwebGcc < Formula
  desc "GNU compiler collection"
  homepage "https://gcc.gnu.org"
  url "http://ftpmirror.gnu.org/gcc/gcc-5.3.0/gcc-5.3.0.tar.bz2"
  mirror "https://ftp.gnu.org/gnu/gcc/gcc-5.3.0/gcc-5.3.0.tar.bz2"
  sha256 "b84f5592e9218b73dbae612b5253035a7b34a9a1f7688d2e1bfaaf7267d5c4db"

#  bottle do
#    root_url "https://icg.tugraz.at/~skiba/homebrew"
#    sha256 "0f69e18bf5dcd7930efb88925c112f02bf3ee12e93bbdcc5a70a5fd29308853e" => :el_capitan
#  end

  def arch
    if Hardware::CPU.type == :intel
      if MacOS.prefer_64_bit?
        "x86_64"
      else
        "i686"
      end
    elsif Hardware::CPU.type == :ppc
      if MacOS.prefer_64_bit?
        "powerpc64"
      else
        "powerpc"
      end
    end
  end

  def osmajor
    `uname -r`.chomp
  end

  depends_on "sweb-binutils"
  depends_on "gmp"
  depends_on "libmpc"
  depends_on "mpfr"

  fails_with :gcc_4_0
  fails_with :llvm

  # GCC bootstraps itself, so it is OK to have an incompatible C++ stdlib
  cxxstdlib_check :skip

  # The bottles are built on systems with the CLT installed, and do not work
  # out of the box on Xcode-only systems due to an incorrect sysroot.
  def pour_bottle?
    if MacOS::CLT.installed?
      true
    else
      opoo "Xcode CLT not installed => Not pouring bottle. Will install from source."
      false
    end
  end

  def version_suffix
    version.to_s.slice(/\d\.\d/)
  end

  def install
    # GCC will suffer build errors if forced to use a particular linker.
    ENV.delete "LD"

    # C, C++, ObjC compilers are always built
    languages = %w[c c++]

    args = [
      "--bindir=#{bin}",
      "--target=i686-linux-gnu",
      "--prefix=#{prefix}",
      "--enable-languages=#{languages.join(",")}",
      "--with-gmp=#{Formula["gmp"].opt_prefix}",
      "--with-mpfr=#{Formula["mpfr"].opt_prefix}",
      "--with-mpc=#{Formula["libmpc"].opt_prefix}",
      "--disable-werror",
      "--with-pkgversion=Homebrew #{name} #{pkg_version} #{build.used_options*" "}".strip,
      "--with-bugurl=https://github.com/Homebrew/homebrew/issues",
      "--disable-multilib",
      "--disable-nls",
      "--with-gcc",
      "--with-gnu-as",
      "--with-gnu-ld",
      "--with-stabs",
      "--disable-shared",
      "--without-headers",
      "--enable-debug",
      "--infodir=#{info}",
      "--mandir=#{man}",
      "--build=#{arch}-apple-darwin#{osmajor}",
      "--host=#{arch}-apple-darwin#{osmajor}",
    ]

    mkdir "build" do
      unless MacOS::CLT.installed?
        # For Xcode-only systems, we need to tell the sysroot path.
        # "native-system-headers" will be appended
        args << "--with-native-system-header-dir=/usr/include"
        args << "--with-sysroot=#{MacOS.sdk_path}"
      end

      system "../configure", *args
      system "make", "all-gcc"
      system "make", "install-gcc"
    end

    ln_s("#{Formula["sweb-binutils"].opt_prefix}/i686-linux-gnu", "#{prefix}/i686-linux-gnu")

    # Handle conflicts between GCC formulae and avoid interfering
    # with system compilers.
    # Since GCC 4.8 libffi stuff are no longer shipped.
    # Rename man7.
    Dir.glob(man7/"*.7") { |file| add_suffix file, version_suffix }
    # Even when suffixes are appended, the info pages conflict when
    # install-info is run. TODO fix this.
    info.rmtree
  end

  def add_suffix(file, suffix)
    dir = File.dirname(file)
    ext = File.extname(file)
    base = File.basename(file, ext)
    File.rename file, "#{dir}/#{base}-#{suffix}#{ext}"
  end
end
