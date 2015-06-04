require "formula"

class SwebGcc < Formula
  homepage "http://gcc.gnu.org"
  url "http://ftpmirror.gnu.org/gcc/gcc-4.9.1/gcc-4.9.1.tar.bz2"
  mirror "ftp://gcc.gnu.org/pub/gcc/releases/gcc-4.9.1/gcc-4.9.1.tar.bz2"
  sha1 "3f303f403053f0ce79530dae832811ecef91197e"

  bottle do
    root_url "http://static.ghostlyrics.net/homebrew"
    revision 2
    sha256 "1e9ddb9f880885dc74259f7c5193ce65d32413c31a8b4a759f5ea5ed05a59729" => :yosemite
  end

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

  # GCC bootstraps itself, so it is OK to have an incompatible C++ stdlib
  cxxstdlib_check :skip

  # The bottles are built on systems with the CLT installed, and do not work
  # out of the box on Xcode-only systems due to an incorrect sysroot.
  def pour_bottle?
    MacOS::CLT.installed?
  end

  def version_suffix
    version.to_s.slice(/\d\.\d/)
  end

  # Fix 10.10 issues: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=61407
  patch do
    url "https://gcc.gnu.org/bugzilla/attachment.cgi?id=33180"
    sha1 "def0cb036a255175db86f106e2bb9dd66d19b702"
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
      system "../configure", *args
      system "make", "all-gcc"
      system "make", "install-gcc"
    end

    system "ln", "-s", "#{Formula["sweb-binutils"].opt_prefix}/i686-linux-gnu", "#{prefix}/i686-linux-gnu"

    # Handle conflicts between GCC formulae and avoid interfering
    # with system compilers.
    # Since GCC 4.8 libffi stuff are no longer shipped.
    # Rename man7.
    Dir.glob(man7/"*.7") { |file| add_suffix file, version_suffix }
    # Even when suffixes are appended, the info pages conflict when
    # install-info is run. TODO fix this.
    info.rmtree

  end

  def add_suffix file, suffix
    dir = File.dirname(file)
    ext = File.extname(file)
    base = File.basename(file, ext)
    File.rename file, "#{dir}/#{base}-#{suffix}#{ext}"
  end

end
