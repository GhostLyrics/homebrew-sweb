require 'formula'

class SwebBinutils < Formula
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

  homepage 'http://www.gnu.org/software/binutils/binutils.html'
  url 'http://ftpmirror.gnu.org/binutils/binutils-2.24.tar.gz'
  mirror 'http://ftp.gnu.org/gnu/binutils/binutils-2.24.tar.gz'
  sha1 '1b2bc33003f4997d38fadaa276c1f0321329ec56'

  bottle do
    root_url "http://static.ghostlyrics.net/homebrew"
    sha1 "79c84de755013ddd377da3e1f37f10910ccbf323" => :mavericks
    sha1 "9296897e04a62768b654dd86e1908060e49ea986" => :yosemite
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
    assert `#{bin}/gnm #{bin}/gnm`.include? 'main'
    assert_equal 0, $?.exitstatus
  end
end
