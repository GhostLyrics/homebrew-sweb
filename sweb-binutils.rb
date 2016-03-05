class SwebBinutils < Formula
  desc "FSF Binutils for native development"
  homepage "https://www.gnu.org/software/binutils/binutils.html"
  url "http://ftpmirror.gnu.org/binutils/binutils-2.26.tar.gz"
  mirror "https://ftp.gnu.org/gnu/binutils/binutils-2.26.tar.gz"
  sha256 "9615feddaeedc214d1a1ecd77b6697449c952eab69d79ab2125ea050e944bcc1"

#  bottle do
#    root_url "https://icg.tugraz.at/~skiba/homebrew"
#    sha256 "741cf4ffd83253601846286fbe2f77bf70a79f264f869fafce8ab0253e2e003a" => :el_capitan
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

  def install
    system "./configure", "--enable-debug",
                          "--disable-dependency-tracking",
                          "--disable-nls",
                          "--disable-shared",
                          "--disable-threads", # try changing this later
                          "--prefix=#{prefix}",
                          "--infodir=#{info}",
                          "--mandir=#{man}",
                          "--disable-werror",
                          "--build=#{arch}-apple-darwin#{osmajor}",
                          "--host=#{arch}-apple-darwin#{osmajor}",
                          "--target=i686-linux-gnu",
                          "--disable-multilib",
                          "--with-gcc",
                          "--with-gnu-as",
                          "--with-gnu-ld",
                          "--with-stabs"
    system "make"
    system "make", "install"
  end

  test do
    assert_match /main/, shell_output("#{bin}/gnm #{bin}/gnm")
  end
end
