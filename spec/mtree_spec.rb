require_relative 'spec_helper'
require 'fileutils'
require 'securerandom'

describe :dct_mtree do
  before(:all) do
    @dir = TestDir.new
    @mtree = File.join(@dir.tempdir, "bin", "dct-mtree")
  end

  before(:each) do
    @tempdir = File.join(@dir.tempdir, SecureRandom.alphanumeric(20))
    Dir.mkdir @tempdir
    Dir.mkdir File.join(@tempdir, "foo")
    Dir.mkdir File.join(@tempdir, "bar")
    Dir.mkdir File.join(@tempdir, "bar", "quux")
    Dir.mkdir File.join(@tempdir, "baz")
    File.write(File.join(@tempdir, "foo", "file1"), "")
    File.write(File.join(@tempdir, "foo", "file2"), "")
    File.write(File.join(@tempdir, "bar", "file3"), "")
    File.chmod(0750, File.join(@tempdir, "bar", "file3"))
    File.write(File.join(@tempdir, "bar", "quux", "file#"), "")
    File.write(File.join(@tempdir, "bar", "file with space"), "")
    File.symlink("../bar/file1", File.join(@tempdir, "bar", "link1"))
    File.write(File.join(@tempdir, "file4"), "")
  end

  SAMPLE1 = <<~EOF
  barbaz type=dir mode=0755 src=bar recurse=true filemode=0640 dirmode=0750
  foobar type=dir mode=0755 src=baz

  # This is a comment.
  #
  # More comment.
  file4 type=file mode=0664
  foo type=dir mode=0755
  EOF

  SAMPLE2 = <<~EOF
  barbaz type=dir mode=0755 src=bar recurse=true filemode=0640+x dirmode=0750
  foobar type=dir mode=0755 src=baz
  file4 type=file mode=0664
  foo type=dir mode=0755
  EOF

  context 'mtree printing' do
    it 'should generate recursive mtree source output' do
      output = <<~EOF
      . type=dir
      ./bar type=dir mode=0755
      ./bar/file\\swith\\sspace type=file mode=0640
      ./bar/file3 type=file mode=0640
      ./bar/link1 type=link mode=0777 link=../bar/file1
      ./bar/quux type=dir mode=0750
      ./bar/quux/file\\# type=file mode=0640
      ./baz type=dir mode=0755
      ./file4 type=file mode=0664
      ./foo type=dir mode=0755
      EOF
      expect(@dir.stream([@mtree, '--backend=sh', '--mtree-src'], SAMPLE1, chdir: @tempdir)).to eq output
      expect(@dir.stream([@mtree, '--backend=ruby', '--mtree-src'], SAMPLE1, chdir: @tempdir)).to eq output
      expect(@dir.stream([@mtree, '--mtree-src'], SAMPLE1, chdir: @tempdir)).to eq output
    end

    it 'should generate recursive mtree source output with executable handling' do
      output = <<~EOF
      . type=dir
      ./bar type=dir mode=0755
      ./bar/file\\swith\\sspace type=file mode=0640
      ./bar/file3 type=file mode=0750
      ./bar/link1 type=link mode=0777 link=../bar/file1
      ./bar/quux type=dir mode=0750
      ./bar/quux/file\\# type=file mode=0640
      ./baz type=dir mode=0755
      ./file4 type=file mode=0664
      ./foo type=dir mode=0755
      EOF
      expect(@dir.stream([@mtree, '--backend=sh', '--mtree-src'], SAMPLE2, chdir: @tempdir)).to eq output
      expect(@dir.stream([@mtree, '--backend=ruby', '--mtree-src'], SAMPLE2, chdir: @tempdir)).to eq output
      expect(@dir.stream([@mtree, '--mtree-src'], SAMPLE2, chdir: @tempdir)).to eq output
    end


    it 'should generate non-recursive mtree source output' do
      output = <<~EOF
      . type=dir
      ./bar type=dir mode=0755
      ./baz type=dir mode=0755
      ./file4 type=file mode=0664
      ./foo type=dir mode=0755
      EOF
      expect(@dir.stream([@mtree, '--no-recurse', '--backend=sh', '--mtree-src'], SAMPLE1, chdir: @tempdir)).to eq output
      expect(@dir.stream([@mtree, '--no-recurse', '--backend=ruby', '--mtree-src'], SAMPLE1, chdir: @tempdir)).to eq output
      expect(@dir.stream([@mtree, '--no-recurse', '--mtree-src'], SAMPLE1, chdir: @tempdir)).to eq output
    end

    it 'should generate recursive mtree destination output' do
      output = <<~EOF
      . type=dir
      ./barbaz type=dir mode=0755
      ./barbaz/file\\swith\\sspace type=file mode=0640
      ./barbaz/file3 type=file mode=0640
      ./barbaz/link1 type=link mode=0777 link=../bar/file1
      ./barbaz/quux type=dir mode=0750
      ./barbaz/quux/file\\# type=file mode=0640
      ./foobar type=dir mode=0755
      ./file4 type=file mode=0664
      ./foo type=dir mode=0755
      EOF
      expect(@dir.stream([@mtree, '--backend=sh', '--mtree-dest'], SAMPLE1, chdir: @tempdir)).to eq output
      expect(@dir.stream([@mtree, '--backend=ruby', '--mtree-dest'], SAMPLE1, chdir: @tempdir)).to eq output
      expect(@dir.stream([@mtree, '--mtree-dest'], SAMPLE1, chdir: @tempdir)).to eq output
    end

    it 'should generate non-recursive mtree destination output' do
      output = <<~EOF
      . type=dir
      ./barbaz type=dir mode=0755
      ./foobar type=dir mode=0755
      ./file4 type=file mode=0664
      ./foo type=dir mode=0755
      EOF
      expect(@dir.stream([@mtree, '--backend=sh', '--mtree-dest', '--no-recurse'], SAMPLE1, chdir: @tempdir)).to eq output
      expect(@dir.stream([@mtree, '--backend=ruby', '--mtree-dest', '--no-recurse'], SAMPLE1, chdir: @tempdir)).to eq output
      expect(@dir.stream([@mtree, '--mtree-dest', '--no-recurse'], SAMPLE1, chdir: @tempdir)).to eq output
    end
  end

  context 'installation' do
    INSTALL1 = <<~EOF
    . type=dir
    ./barbaz type=dir mode=0755
    ./barbaz/quux type=dir mode=0750
    ./barbaz/file\\swith\\sspace type=file mode=0640
    ./barbaz/file3 type=file mode=0640
    ./barbaz/quux/file\\# type=file mode=0640
    ./barbaz/link1 type=link mode=0777 link=../bar/file1
    ./foobar type=dir mode=0755
    ./file4 type=file mode=0664
    ./foo type=dir mode=0755
    EOF

    VERIFY1 = <<~EOF
    . type=dir
    ./barbaz type=dir mode=0755
    ./barbaz/quux type=dir mode=0750
    ./barbaz/file\\swith\\sspace type=file mode=0640
    ./barbaz/file3 type=file mode=0640
    ./barbaz/quux/file\\# type=file mode=0640
    ./barbaz/link1 type=link mode=0777 link=../bar/file1
    ./foobar type=dir mode=0755
    ./file4 type=file mode=0664 sha256digest=ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
    ./foo type=dir mode=0755
    EOF

    it 'should install files correctly for default backend' do
      dest = File.join(@dir.tempdir, "dest")
      Dir.rmdir(dest) rescue nil

      expect(@dir.stream([@mtree, '--install', 'dest'], SAMPLE1, chdir: @tempdir)).to eq ''
      expect(@dir.stream(['sh', '-c', 'cd dest && mtree -f /dev/stdin'], INSTALL1, chdir: @tempdir)).to eq ''
    end

    it 'should install files correctly for sh backend' do
      dest = File.join(@dir.tempdir, "dest")
      Dir.rmdir(dest) rescue nil

      expect(@dir.stream([@mtree, '--backend=sh', '--install', 'dest'], SAMPLE1, chdir: @tempdir)).to eq ''
      expect(@dir.stream(['sh', '-c', 'cd dest && mtree -f /dev/stdin'], INSTALL1, chdir: @tempdir)).to eq ''
    end

    it 'should install files correctly for ruby backend' do
      dest = File.join(@dir.tempdir, "dest")
      FileUtils.rm_rf(dest, secure: true) rescue nil

      expect(@dir.stream([@mtree, '--backend=ruby', '--install', 'dest'], SAMPLE1, chdir: @tempdir)).to eq ''
      expect(@dir.stream(['sh', '-c', 'cd dest && mtree -f /dev/stdin'], INSTALL1, chdir: @tempdir)).to eq ''
    end

    it 'should install modified files correctly for sh backend' do
      expect(@dir.stream([@mtree, '--backend=sh', '--install', 'dest'], SAMPLE1, chdir: @tempdir)).to eq ''
      expect(@dir.stream(['sh', '-c', 'cd dest && mtree -f /dev/stdin'], INSTALL1, chdir: @tempdir)).to eq ''

      File.write(File.join(@tempdir, "file4"), "abc")

      expect(@dir.stream([@mtree, '--backend=sh', '--install', 'dest'], SAMPLE1, chdir: @tempdir)).to eq ''
      expect(@dir.stream(['sh', '-c', 'cd dest && mtree -f /dev/stdin'], VERIFY1, chdir: @tempdir)).to eq ''
    end

    it 'should install modified files correctly for ruby backend' do
      expect(@dir.stream([@mtree, '--backend=ruby', '--install', 'dest'], SAMPLE1, chdir: @tempdir)).to eq ''
      expect(@dir.stream(['sh', '-c', 'cd dest && mtree -f /dev/stdin'], INSTALL1, chdir: @tempdir)).to eq ''

      File.write(File.join(@tempdir, "file4"), "abc")

      expect(@dir.stream([@mtree, '--backend=ruby', '--install', 'dest'], SAMPLE1, chdir: @tempdir)).to eq ''
      expect(@dir.stream(['sh', '-c', 'cd dest && mtree -f /dev/stdin'], VERIFY1, chdir: @tempdir)).to eq ''
    end

    it 'should install absolute files correctly for sh backend' do
      dest = File.join(@dir.tempdir, "dest")
      FileUtils.rm_rf(dest, secure: true) rescue nil
      sample1 = SAMPLE1.gsub(/^\./, @dir.tempdir)

      expect(@dir.stream([@mtree, '--backend=sh', '--install', 'dest'], sample1, chdir: @tempdir)).to eq ''
      expect(@dir.stream(['sh', '-c', 'cd dest && mtree -f /dev/stdin'], INSTALL1, chdir: @tempdir)).to eq ''
    end

    it 'should install absolute files correctly for ruby backend' do
      dest = File.join(@dir.tempdir, "dest")
      FileUtils.rm_rf(dest, secure: true) rescue nil
      sample1 = SAMPLE1.gsub(/^\./, @dir.tempdir)

      expect(@dir.stream([@mtree, '--backend=ruby', '--install', 'dest'], sample1, chdir: @tempdir)).to eq ''
      expect(@dir.stream(['sh', '-c', 'cd dest && mtree -f /dev/stdin'], INSTALL1, chdir: @tempdir)).to eq ''
    end
  end

  context 'edge cases' do
    ORDER = <<~EOF
    . type=dir
    ./.config type=dir mode=0700
    ./.config/nvim type=link link=../.vim
    EOF

    CONTENTS_INSTALL = <<~EOF
    . type=dir
    ./.config type=dir mode=0700
    ./.config/mutt type=dir mode=0700
    ./.config/mutt/aliases type=file mode=0600 contents=ignore
    EOF

    CONTENTS_VERIFY = <<~EOF
    . type=dir
    ./.config type=dir mode=0700
    ./.config/mutt type=dir mode=0700
    ./.config/mutt/aliases type=file mode=0600 size=0
    EOF

    it 'should install modified files in order for ruby backend' do
      expect(@dir.stream([@mtree, '--backend=ruby', '--install', 'dest'], ORDER, chdir: @tempdir)).to eq ''
      expect(@dir.stream(['sh', '-c', 'cd dest && mtree -f /dev/stdin'], ORDER, chdir: @tempdir)).to eq ''
    end

    it 'should install modified files in order for sh backend' do
      expect(@dir.stream([@mtree, '--backend=sh', '--install', 'dest'], ORDER, chdir: @tempdir)).to eq ''
      expect(@dir.stream(['sh', '-c', 'cd dest && mtree -f /dev/stdin'], ORDER, chdir: @tempdir)).to eq ''
    end

    it 'should accept contents=ignore for ruby backend' do
      expect(@dir.stream([@mtree, '--backend=ruby', '--install', 'dest'], CONTENTS_INSTALL, chdir: @tempdir)).to eq ''
      expect(@dir.stream(['sh', '-c', 'cd dest && mtree -f /dev/stdin'], CONTENTS_VERIFY, chdir: @tempdir)).to eq ''
    end

    it 'should accept contents=ignore for sh backend' do
      expect(@dir.stream([@mtree, '--backend=sh', '--install', 'dest'], CONTENTS_INSTALL, chdir: @tempdir)).to eq ''
      expect(@dir.stream(['sh', '-c', 'cd dest && mtree -f /dev/stdin'], CONTENTS_VERIFY, chdir: @tempdir)).to eq ''
    end
  end

  context 'escaping' do
    ALL_BYTES = (0..255).map { |b| b.chr("ASCII-8BIT") }.join
    ALL_NONNULL_BYTES = (1..255).map { |b| b.chr("ASCII-8BIT") }.join

    it 'should accept FreeBSD (VIS_OCTAL) escaping' do
      octal = (0..255).map { |b| "\\%03o" % b }.join
      expect(@dir.stream([@mtree, '--backend=ruby', '--unescape'], octal).b).to eq ALL_BYTES
      expect(@dir.stream([@mtree, '--backend=perl', '--unescape'], octal).b).to eq ALL_BYTES

      octal = (1..255).map { |b| "\\%03o" % b }.join
      expect(@dir.stream([@mtree, '--backend=perl', '--unescape'], octal, chdir: @tempdir).b).to eq ALL_NONNULL_BYTES
      expect(@dir.stream([@mtree, '--backend=sh', '--unescape'], octal, chdir: @tempdir).b).to eq ALL_NONNULL_BYTES
      expect(@dir.stream([@mtree, '--backend=ruby', '--unescape'], octal, chdir: @tempdir).b).to eq ALL_NONNULL_BYTES
    end

    it 'should accept NetBSD (VIS_CSTYLE) escaping' do
      cstyle = "\\0\\^A\\^B\\^C\\^D\\^E\\^F\\a\\b\\t\\n\\v\\f\\r\\^N\\^O\\^P\\^Q\\^R\\^S\\^T\\^U\\^V\\^W\\^X\\^Y\\^Z\\^[\\^\\\\^]\\^^\\^_\\s!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\\\]^_`abcdefghijklmnopqrstuvwxyz{|}~\\^?\\M^@\\M^A\\M^B\\M^C\\M^D\\M^E\\M^F\\M^G\\M^H\\M^I\\M^J\\M^K\\M^L\\M^M\\M^N\\M^O\\M^P\\M^Q\\M^R\\M^S\\M^T\\M^U\\M^V\\M^W\\M^X\\M^Y\\M^Z\\M^[\\M^\\\\M^]\\M^^\\M^_\\240\\M-!\\M-\"\\M-#\\M-$\\M-%\\M-&\\M-'\\M-(\\M-)\\M-*\\M-+\\M-,\\M--\\M-.\\M-/\\M-0\\M-1\\M-2\\M-3\\M-4\\M-5\\M-6\\M-7\\M-8\\M-9\\M-:\\M-;\\M-<\\M-=\\M->\\M-?\\M-@\\M-A\\M-B\\M-C\\M-D\\M-E\\M-F\\M-G\\M-H\\M-I\\M-J\\M-K\\M-L\\M-M\\M-N\\M-O\\M-P\\M-Q\\M-R\\M-S\\M-T\\M-U\\M-V\\M-W\\M-X\\M-Y\\M-Z\\M-[\\M-\\\\M-]\\M-^\\M-_\\M-`\\M-a\\M-b\\M-c\\M-d\\M-e\\M-f\\M-g\\M-h\\M-i\\M-j\\M-k\\M-l\\M-m\\M-n\\M-o\\M-p\\M-q\\M-r\\M-s\\M-t\\M-u\\M-v\\M-w\\M-x\\M-y\\M-z\\M-{\\M-|\\M-}\\M-~\\M^?"
      expect(@dir.stream([@mtree, '--backend=ruby', '--unescape'], cstyle, chdir: @tempdir).b).to eq ALL_BYTES
      expect(@dir.stream([@mtree, '--backend=perl', '--unescape'], cstyle, chdir: @tempdir).b).to eq ALL_BYTES

      cstyle = cstyle[2..]
      expect(@dir.stream([@mtree, '--backend=ruby', '--unescape'], cstyle, chdir: @tempdir).b).to eq ALL_NONNULL_BYTES
      expect(@dir.stream([@mtree, '--backend=perl', '--unescape'], cstyle, chdir: @tempdir).b).to eq ALL_NONNULL_BYTES
      expect(@dir.stream([@mtree, '--backend=sh', '--unescape'], cstyle, chdir: @tempdir).b).to eq ALL_NONNULL_BYTES
    end

    it 'should escape characters sensibly' do
      expected = "\\000\\001\\002\\003\\004\\005\\006\\007\\010\\t\\n\\013\\014\\015\\016\\017\\020\\021\\022\\023\\024\\025\\026\\027\\030\\031\\032\\033\\034\\035\\036\\037\\s!\"\\#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\134]^_`abcdefghijklmnopqrstuvwxyz{|}~\\177\\200\\201\\202\\203\\204\\205\\206\\207\\210\\211\\212\\213\\214\\215\\216\\217\\220\\221\\222\\223\\224\\225\\226\\227\\230\\231\\232\\233\\234\\235\\236\\237\\240\\241\\242\\243\\244\\245\\246\\247\\250\\251\\252\\253\\254\\255\\256\\257\\260\\261\\262\\263\\264\\265\\266\\267\\270\\271\\272\\273\\274\\275\\276\\277\\300\\301\\302\\303\\304\\305\\306\\307\\310\\311\\312\\313\\314\\315\\316\\317\\320\\321\\322\\323\\324\\325\\326\\327\\330\\331\\332\\333\\334\\335\\336\\337\\340\\341\\342\\343\\344\\345\\346\\347\\350\\351\\352\\353\\354\\355\\356\\357\\360\\361\\362\\363\\364\\365\\366\\367\\370\\371\\372\\373\\374\\375\\376\\377".b

      expect(@dir.stream([@mtree, '--backend=ruby', '--escape'], ALL_BYTES, chdir: @tempdir).b).to eq expected
      expect(@dir.stream([@mtree, '--backend=perl', '--escape'], ALL_BYTES, chdir: @tempdir).b).to eq expected

      expected = expected[4..].sub(/\\n/, '')
      input = ALL_NONNULL_BYTES.sub(/\n/, '')
      expect(@dir.stream([@mtree, '--backend=ruby', '--escape'], input, chdir: @tempdir).b).to eq expected
      expect(@dir.stream([@mtree, '--backend=perl', '--escape'], input, chdir: @tempdir).b).to eq expected
      expect(@dir.stream([@mtree, '--backend=sh', '--escape'], input, chdir: @tempdir).b).to eq expected
    end
  end

  context 'format' do
    DEFAULT = <<~'EOF'
    # .
    /set type=file uname=bmc gname=bmc mode=0700 nlink=1 flags=none
    .               type=dir time=1781923390.867878812
        nvim        type=link mode=0777 time=1781922586.544963474 link=../.vim

    # ./abcd\
    abcd\\          type=dir mode=0775 time=1781923384.527988155
    # ./abcd\
    ..


    # ./alacritty
    /set type=file uname=bmc gname=bmc mode=0640 nlink=1 flags=none
    alacritty       type=dir mode=0700 time=1781922575.840764324
        alacritty.toml \
                    size=1657 time=1781922586.537646622 cksum=3019338482 \
                    md5=1bb596f0a2462fc982227ca38e361953 \
                    rmd160=279bca3c5544fe288720cd2a20c6f94d5b906c51 \
                    sha1=2615cba7b4f382abf9f4e4c3e93099dff8222333 \
                    sha256=8af6915c6a29481b6fe101ad88272bcb666bc9d4f5275452cff1b68d71e3aeaf \
                    sha384=1ced4c8a3d53bf80fa1f6189ef54a8362ce39adceb73d1320c7965fc155daa5e5d7c8ced6963505be469908d80f577a8 \
                    sha512=c1057037b486dd3466a8f445091bc6e8e8a31bcc9d61048f8700f0f864e1d6a785abe0f7a0a69310b0df6ecc41db30f97e46489e81621d3c0ab5018c45ccc732
        alacritty.yml \
                    size=1810 time=1781922586.537450193 cksum=1984605283 \
                    md5=331f4f8ba154d04036507fbaba4127dd \
                    rmd160=2a68592f18139e4b76a176890630d19288d7b63b \
                    sha1=94516ed79fa8fbd62d42fb7a87d9b7cee56e8a3a \
                    sha256=5b504be024805065b0f639c09501078b31d733115b005009098364dd623b7709 \
                    sha384=64fa3f4c7df676cab8d2087751bca665a1738e5c949c851a5a7102ec43ad18a754d2ca772bfbfd670241dcf6aa5dc50e \
                    sha512=b57aa042fd4af00a18e787594dafb7a56d415f48c3abf0319275f6aefa03c4e8bf1d0a25e8898df79a849a56c9338cbaf93d7567c2f24f061c8b0cd16b4f0194
    # ./alacritty
    ..


    # ./dct-jump
    /set type=file uname=bmc gname=bmc mode=0600 nlink=1 flags=none
    dct-jump        type=dir mode=0700 time=1781922575.841113711
        config      size=2157 time=1781922586.537966333 cksum=3349588464 \
                    md5=66f48dc2158e42cd15f45cbc6cc53dde \
                    rmd160=984fc1f68bbbc1c4dcebc4d70e8baeeaeabd445e \
                    sha1=f9f767ee034a7489a0f1d83489da9d81cadadf10 \
                    sha256=b50e725ff04d8343d60ec65b96e8f16f83d863c8dbce4310d85e012496d0be83 \
                    sha384=5027c382cf8479d9d19130e168401e17d4252050083bfb7a04197e3af4e37b66b76dbbb6aaff4311427fce336d9e98b4 \
                    sha512=623d6e464401b978b394ad3f096e432cb410a2b5f851d5cf7255fc3aeaf84d29ef398f3902e9f90f22ce8556719cda15f3debdfd77ae46c50c32fd887ece8cea
    # ./dct-jump
    ..


    # ./efgh \
    efgh\s\\        type=dir mode=0775 time=1781923390.867878812
    # ./efgh \
    ..


    # ./git
    /set type=file uname=bmc gname=bmc mode=0644 nlink=1 flags=none
    git             type=dir mode=0755 time=1781922575.836762122
        config      size=6973 time=1781922586.532964423 cksum=3167949394 \
                    md5=98970a2d7e36fac13ae968b960b0261d \
                    rmd160=9e3f34a411f9172cf584eeaa29ed5fc495454cd7 \
                    sha1=62396a7b48796a572b784507baf8578b0776008a \
                    sha256=acb50991cf397a1b6a9ae06c2ed6dd9c0ec9ab17fa94efc588c38058694ff502 \
                    sha384=66a2cd95c64c56b71e139f6cbaadf2150c772207e09b39b6d0e18c96dc7ef692b551584b9469b15a3c63b470ed5e4b34 \
                    sha512=09f7d1116d82dc3dee83d9f7891137f44df43134039d3bd37ba93c1a0823e404d713648f39960cee581c148fd04b1f97e38cb44691d6bb59736ad6e22684aac6
    # ./git
    ..


    # ./kitty
    /set type=file uname=bmc gname=bmc mode=0640 nlink=1 flags=none
    kitty           type=dir mode=0700 time=1781922575.837534414
        kitty.conf  size=941 time=1781922586.534766360 cksum=362245594 \
                    md5=b2b091a8a0883cc4fdcf74e41e603a1d \
                    rmd160=3e94572b8cc8297ee1f6bb30e5769e922e3ccfd0 \
                    sha1=9b4f8902a74bb217a8d5f305941d7975062dce6e \
                    sha256=874f3c9733bd616c68bb5c5c52d44f0171d3d457b87d8e1c782e2c1fc492f26a \
                    sha384=f474b232ac68b87c7b8b3aea16c404dd12f629ece74cd0d2e9d5551568443b9c2dc5f0f8bd182a0ce655951b9fa762c9 \
                    sha512=fbcff876ba05105b92e6222da65c28cf46a347e1df1e95efd8b0eca5433fb98f9c36cb6d52997ec0fc16f29ccce7bbf32293638be25ee9a3d6efd62d9ebfac52

    # ./kitty/conf.d
    conf.d          type=dir mode=0700 time=1781922575.838360366
        fonts.conf  size=50 time=1781922586.535091931 cksum=1850747784 \
                    md5=e38451fccf09bebbef7fd37641fb51e4 \
                    rmd160=4d1f6b4c3aae4175920cdc3e37f01bcabc56b5a2 \
                    sha1=03040468b3234e3c9d133899a91f7d8204166341 \
                    sha256=13def07a922567b7e384110dfd3ac60098a921436c081cc57363c055b4cade87 \
                    sha384=01d23941dd48635c1537de4c8bc9f86d367baaa4428c40171277c0395ffc2873de0602674a416bbf2422760dd0e10b69 \
                    sha512=fc3c5bc793dbbff175d187997f8c4a4f6cf107c6228bb2bc089c48301d1589fbd584c10ba75a3bb7004a76090b9418c43f6a3720218153c5a8c2672cebbe5b3f
    # ./kitty/conf.d
    ..

    # ./kitty
    ..


    # ./lawn
    /set type=file uname=bmc gname=bmc mode=0600 nlink=1 flags=none
    lawn            type=dir mode=0700 time=1781922575.840289261
        config.yaml size=1245 time=1781922586.537295442 cksum=165022565 \
                    md5=210fc66b4abadaafa3a832b552e096c4 \
                    rmd160=8ce53bd412114528833d6db2429843aeeaedd7f8 \
                    sha1=f8d457019d6c489c175747f38f2c45db6ba47b1b \
                    sha256=c31b14ee8fcd2e47b07cf3491a496d19d10402f98ec61388eec04907775f9c7d \
                    sha384=fe90374540ad0a8f83369988da6c95df312db872b97a306cce0cb4ea25b0f2a7278e46612a37230c7651d08b7525a391 \
                    sha512=173f2141ffb64487d947cef2d06461381acab4f7131dc0c1956eb20d052b679603648d835d2260084cf60e28dc5b09d7e0c5150741ee9b98813eb06833ef6dbc
    # ./lawn
    ..


    # ./mutt
    mutt            type=dir mode=0700 time=1781922575.843890249
        aliases     size=2490 time=1781922586.643047226 cksum=89445784 \
                    md5=f484c7e9d4aad8ad82aab83cb0c3adbe \
                    rmd160=c629b767694ce2c0571882274aecd56d4bb3a5e4 \
                    sha1=7fb5a308ce196ca68755a805f06e34d6c59dbfc6 \
                    sha256=52c3e6fbd28bc8d8120c3c435e4c2d58ad6dbb41d15885dba93d5e18b17bb108 \
                    sha384=d65f1ea4d9c0b19d8713bb09844a882e61f8d4432b0c03452b97484c20f72211d412fb57b96b8d5ebe2eece8ad9b3c3d \
                    sha512=27114c4833861eabdd7a80a5cb140918be6dc6caa2b8a726bf3fedda370bce26070a88e20639dc75b0964e4ecc0bba5520077a2b45414982c2221967752abdbd
        muttrc      size=190 time=1781922586.539500918 cksum=3618234492 \
                    md5=add11fbb467e3aa8f31d4b4318f9449d \
                    rmd160=6c4b1ead1b7e9e79649b106a496f403873951cc0 \
                    sha1=3671ce5e1ea9f62a20e22d56f8eca60b1693936c \
                    sha256=e201fbafee48bec6afe71fddf50d9acad030e34158be1b3d1d4a0a87a28a33c8 \
                    sha384=f3f0c093cce0f68656d5e4c165dfa1e4587fba26cc99b00acbbccb8ba5abf6141f81b6ded129bcf8824138ad47691cb9 \
                    sha512=51065d804c856d57d4114b427ecb30dd974edfcc44237222ae64e585818aba742ae872f3318238fe64e7cf25f5421a0f3872c1e2f037ff051bbfa524882a997a
        profile.auricblue \
                    size=68 time=1781922586.540213236 cksum=2487727371 \
                    md5=4e0e2c61d8b2783f99bd7fbbfef6a9dc \
                    rmd160=4e67f086a7f6252dfd40015117a79bef38d76aaf \
                    sha1=36f0fa57575dc6547310c9167eb219f78450ae9c \
                    sha256=8915064169104448ef65594273119832076f2c5854d32bb2260bd6fe1aa56445 \
                    sha384=4ff2adbfcc65b93b36b7eede3927551b284921577688f9bc65d4317d5af6ea44c4cf3e08854e57b3a7a7ce8cade64c69 \
                    sha512=13035bf77642b1f3777b9864ef2ca38ec986e180ba895d0cfd220a620defd38aa2f1c2e5319a8f385af37aaae53d5a447f19a0fc04d4ec01cb1e6c9232b4af8e
        profile.gmail \
                    size=59 time=1781922586.540408233 cksum=42659435 \
                    md5=1bfb245d5ce979ec099d4086195bb3f6 \
                    rmd160=d67840e7f565a42a6c3d840806b14e96a01b725d \
                    sha1=64d3cf729e119462b02b3ab4e3a4df06257a2589 \
                    sha256=cee4a531d44ccb5bf3f49b27915c3d7b232f940f73b1f46e71c3151013b03db0 \
                    sha384=c5dc1ab2ba719d6c9af7615b896697e86cb0a98caad78930f7aebdd339279bfa28d755068dd714505808c9f877a2791a \
                    sha512=efaf77a39bf553d6f673e8a1c6c38fa0019f459729c7fd31b2514616f3bf941a1ed81005cb7ab1a0b248649b3bbbbb3bd94beeda5a9101bb849ec41aed61b8c7
        profile.personal \
                    size=65 time=1781922586.540570678 cksum=114662987 \
                    md5=3ef88f7851209fe8c53f782571f8f3cf \
                    rmd160=aeaf879cf800269117e640fcc0f9eb7c6762a090 \
                    sha1=9d66f2bcc6a76c637d35bac254f3ca5343a25560 \
                    sha256=554fe55a9e7a8030ffd8da418bba0b09d9e7e0c23eafa1843564bbf07c148d61 \
                    sha384=9bdffe05f9e6c64d616eb24deeef74b212352b1f4b015ca8ebc76eda384d515e13077d7d83461934afc1dff22357bcf0 \
                    sha512=8c7bcc35650464a7dd3528fb8e6e7b331b1f2096af39655c0cd94504c2ae41776f5f1a36ceebfde6aa2407cd67a9a4eab31a144593341a69672ea20495c52e3e

    # ./mutt/config.d
    config.d        type=dir mode=0700 time=1781922575.843537687
        account-auricblue \
                    size=766 time=1781922586.539855965 cksum=3681985873 \
                    md5=5f69870d613d2b2fa7c32ea04f1c6e20 \
                    rmd160=07312810f59311b3e5ccd98a5c9704e951f80e15 \
                    sha1=e76cc98729f5eede46c76480f9668d964f55d379 \
                    sha256=16543652c623ed7b7a74d46d1b3dddb7ffd91674d809a5ab68bd388310ca7127 \
                    sha384=6c1a73af61aa539845a34ac2df2005ac79df07aaa835eb8ebf961b9a111d40372add937d315cef494f9db57e8f9d8aca \
                    sha512=2156988ed54287de66256a8d25d8412fee66c3c6b464e1817f559df2c48d4dc105343fb17b99808bdbadfc4198906d623a148aded0b1640e396c94985c0f3b84
        account-gmail \
                    size=891 time=1781922586.539882825 cksum=2792356538 \
                    md5=e2a598179bd539cdb532a207e4b1bfec \
                    rmd160=9e3577b6516c3bd8ac41341c9b8428da8be0120b \
                    sha1=9d5a1f1ee4c9a0df0b106bd093778e6dd510f0b6 \
                    sha256=c65dcd9ee9a5ff0c89d012f8b516f4d2ea1bfb4291a632090a774d8afdd1848a \
                    sha384=5c922662e54646e23769d0cadf218daad765219000f36f39422b600beca4c380b70994130102fc13c669f8868986d5d0 \
                    sha512=8741e4dd80cff026a136a3ef5027fb3dd58636d70cff81f154fc6bb8173f65ea319bb1e5f04b85a90a569694dfb21e2f56556f9a5cb7fbd25fbf68ab8f84f877
        account-personal \
                    size=748 time=1781922586.539909125 cksum=3401678405 \
                    md5=1d7f2d8760f942b1c7da7e07350663f3 \
                    rmd160=4ccaf116731af623a1ce72ec5f8fa74c94308100 \
                    sha1=4aa1ccc461ed62d4fee5471d2f779ab61bb8eb20 \
                    sha256=f8dde45bb37b0230620f901912c01a8a25ac9c539e890885aaa4b6ca3e5e03f1 \
                    sha384=fc9d78f069cde024f4328ce36c125fad85e7f3a9afb919aa529d96973b9cc5e90fcbbb8793378405b9c19342df97dd4b \
                    sha512=2079cab3ab8a0cdb25f7f971a1462d08547b7f34ac86218dbd8db8a3a98e984e1b8df0a76173ccf6c0c51862e69089f2a71b34344d08aeaa2b968d579fc9f721
        address     size=1394 time=1781922586.539934643 cksum=2912450449 \
                    md5=9b50065b538730ff5fe17e837f87f190 \
                    rmd160=89f07390674a957a5ad03ee711c0f1eaaa78d6cc \
                    sha1=778732f63a3ddca15cfff52b4b3f6b4fe0bbe9d6 \
                    sha256=3431576d359ba83c273623e495bf2b98b549d0c8dc5fdb1f41aef73017482592 \
                    sha384=18d1fdb72c6e4c496b31b68e3990f92e87e33508107eac450a28f5a7d414a52de5faa8c389de30c5fed3ec5d64f36cea \
                    sha512=b96d8356999272f60478ce74a0ad461b5a40f7f9ac78fb547a5422544f73625c9a28e40d03144f39029786fb7b3713e90e2e9250daf85a7f836fdfd368a7792d
        crypto      size=352 time=1781922586.539961583 cksum=1441591471 \
                    md5=83fe65f352054a4855b7aabadd462f3b \
                    rmd160=7e86c83de27ce6f162d9b17b428c7ac8fd9f476f \
                    sha1=aa021737e8cf94b77dec10d6f54e0cea72db9396 \
                    sha256=440422c036482e17fac75478dfa0654cbfa245b6dba344de9686768562533884 \
                    sha384=288ec37bd023e7ea6558dfafe695367ca28dc775e82ed969095077e7abfb6f8aaf03822506d396481bf8643857c1dd76 \
                    sha512=6d41ab072f34c66718599fd87967af45357ee3511e177a35c05bb183a0c19059473b7117797a9cb780ca30b50cf0275732bce6c2b60a8c73af5fe0eeaa001bd9
        iface       size=703 time=1781922586.539986630 cksum=1952966797 \
                    md5=4a2ad1d8553983b2f24b134326cfc4bd \
                    rmd160=8e216c0371688006510b0db3b9e31b4865c8202a \
                    sha1=f7f87b34216af474ed02f597a9a333caa8404fb7 \
                    sha256=788a1b48de0b25e03ac4b1db9f8137d361dee0b8c979a6c9d05d27351a5645fc \
                    sha384=574ce51c3f84a92cc1c4b66febc47991cbc0c6a785315d7002ca7cf1c51fceba4cdb089b2597a829aaf54a468226fb59 \
                    sha512=a0f46666287acedd9dfe37adb93bf5e30d30192f453c7955a4e0592190ddd726ddf2f6b9ba75cbb8e098970806552248e04a9cd26ebaff7b825464d2ea44ab92
        keys        size=705 time=1781922586.540012158 cksum=3871402869 \
                    md5=6024d7ebd37ec18e06c11bae60279c78 \
                    rmd160=fd6b635c1346e6cd6774faf39f70bc55513cd715 \
                    sha1=9984f51ca90f206e69bd8c20aa1dff840f70783d \
                    sha256=c0ac6122f56f47594eca84c522528e4b54fb3542ce0d97d5c0cca84cc43a19e1 \
                    sha384=7cac54f7f39275fcb1941cb9718c850244564d5c03622565acc44d5796cbf08b88684dff11c8a2e015b37a2005b4bac6 \
                    sha512=e4544ed2d843493f9109af82d4063faebdf66d7c60e4afcefc6cf9d09449846a1f858af0fcaac2c1e1013701c1ae0e2894017ca6bd77778c1149c3c58393a56c
        mime        size=1043 time=1781922586.540035973 cksum=1286077258 \
                    md5=51b609d3f0aa21e071e978ff9acaa5a2 \
                    rmd160=aef4b2bfce53496c5c3284dec68b9c93e0988524 \
                    sha1=9e87573830c6796b30662ecc98ddcd9bc9733323 \
                    sha256=af76b3ca74a2b0416075e8309e0f4e1b0dd5430da7aedfec462c80830cf985a7 \
                    sha384=0f71b88fcb76881293c01a7b2a795e5c354b2c5af19fe38ccff8bbb753316b89f693be03b0a0b880baec64be7438c879 \
                    sha512=84ee863a11c59d04494e81e440abc14755273749aa4ead399c9504ca71fc68ce9d197e80072b47126e4d2a698d8e1a330d35ca3d559035f95fad54df3593a951
        muttlike    size=215 time=1781922586.540062443 cksum=36626399 \
                    md5=5f6336d9199c7f37746e90a47129013a \
                    rmd160=dbd2ebac1b12e9373352e14b6cba82e6129d11ff \
                    sha1=61f0f2cc3c3a63c65d4ee73c9d4a5e3c958839e7 \
                    sha256=3a6d73566ae945ba0e23e0d5925af81f4b74163446082d425d6ccec155055c72 \
                    sha384=947dde050a29c67d1706b8731205f3c8888249a3be0fe361784521e9ebda1d4c239ac71814eeccf1efe9d7144d09281b \
                    sha512=26dcc4164915a3b9215aec4ec430cf95778aa21c1c8ea33274f0abf3b1ab1173e3abdb7e3a6b14d62fba34249c3dd562206d29881468293caa39ed63b050379d
    # ./mutt/config.d
    ..

    # ./mutt
    ..


    # ./neovide
    /set type=file uname=bmc gname=bmc mode=0640 nlink=1 flags=none
    neovide         type=dir mode=0750 time=1781922575.840965402
        config.toml size=72 time=1781922586.537806403 cksum=2691964525 \
                    md5=d9f099524b17ab6cb6cc5805755f21bd \
                    rmd160=df60d4d011ebfe2de77107f8b5a62ef8637ed94f \
                    sha1=389d9829cba6747706f1732f00f4ced02de22138 \
                    sha256=67933d0c276e448cac2ebc30d34e5d8772cbba2e3bfb4fc85a1f1bed38230670 \
                    sha384=9ccd53a661987c685292072ba50e09eab3d3429e68198b40ba23b16f6687c67633b0d40c096f991644d6b351f73a8233 \
                    sha512=eea656e2b9292762355757c57bea2d3dd61352d989456b1dc3370fe2d2df08cdf24d6d04296e2fe79ec7def32e6a9635e4b7b8232db9f5dd2dccaf9acbc1ce1f
    # ./neovide
    ..


    # ./signature
    /set type=file uname=bmc gname=bmc mode=0600 nlink=1 flags=none
    signature       type=dir mode=0700 time=1781922575.844473816
        auricblue   size=155 time=1781922586.541021075 cksum=1939657664 \
                    md5=c835d358fb601a59eba6c0930768bb65 \
                    rmd160=163472d40b196bc40e9613863af079580871cf72 \
                    sha1=3e7fd093e2b5cccc0999805acbd2baed4c6985ad \
                    sha256=07bd3ba5e0c1c4975b325ce2e605d4bbc6831829b9d7d23b8751a81c4ba6c25f \
                    sha384=0d6bbc64a8b8a803e1301ecd7a5ecc1d131902df707d45b0e921e546b1e947a8ef12375c50e0a32b50faa8cfa5151297 \
                    sha512=03f96324802218bc1e45900fdb644cc8b33003aa3b967f434a3893a7b13996cd040dc37bd1af0a843c45847a0ebad2acca6d8b5869df221f55a4e4a18f58e599
        personal    size=50 time=1781922586.541341246 cksum=1993897367 \
                    md5=21913ecff0a4e5946b43f3121bdfa97d \
                    rmd160=08c82d8cabeb3fc98cb96fa91da78121e79f8517 \
                    sha1=f0fb257573721b021199c13a3a1edaa6873e9c68 \
                    sha256=ee708cc5c8fa63e7ef2cfc9efe5ae686d39c545540d4291e0a6d3c3c5f3440bf \
                    sha384=012616f935d8d3f416d6a8460418e56571f3ce71f39363b19fe1853b7a6adafb2e5ed8a9265bd14363c1143d6050a792 \
                    sha512=3ea7c9dfd02e875bf87631e416a15ba158fa6c874022d11f768e295d53e510f0e0ec8374f3b402127a8e27f9e37351217ba8290a89a1f5559dc90e069cf5a0b2
    # ./signature
    ..


    # ./supercalifragilisticexpialidocious
    supercalifragilisticexpialidocious \
                    type=dir mode=0775 time=1781923297.961531301
    # ./supercalifragilisticexpialidocious
    ..


    # ./tmux
    tmux            type=dir mode=0750 time=1781922575.847673881
        theme.conf  size=2428 time=1781922586.543912098 cksum=3366606526 \
                    md5=86d654dcb7f48b6d3018199b5969b443 \
                    rmd160=1c35acc59831e5a38fc335c092b42eb7d70dfc37 \
                    sha1=11d61118d2a062af79ae22d57e3854660204adb2 \
                    sha256=e6f75fd2029c0a9c2e7e4b39d49201bf8ecd2fcdd24a5c0799e340c2fb1275e0 \
                    sha384=677f2e6281cae539a5e050666e91010bb223b03ead2864d7871f4b5d8d6bf8ce12e9de33f8a3c6c597654037ce9db2c0 \
                    sha512=fc371aeed399eaec09b65cfc56d9ad3be648b2b0d9ae2e65d32aece250174f74f4f234f19b6c4e905ed54eeb360c0d7ccf5ecadb9b126eabd31f94afb3fb48d4
        tmux.conf   size=1915 time=1781922586.543763730 cksum=773649027 \
                    md5=db8853297ee00c99b4910fb1bd95e23c \
                    rmd160=8ab18b4fc7e675b9b39b1008160045af96d4ccab \
                    sha1=b498c0cca43c751fb480eb220da2549cc56cad78 \
                    sha256=4b17318795db84b06b3fbcab340dde197d49c15c7a81c5a4c14047342fea5f1e \
                    sha384=6113aef2bbda6012130228e3a06a90146531ec5ca610c5941b95ae7fd218a457ceaeda30ea65eb83d189f8b8cb3bf492 \
                    sha512=d43664c03f15803ea15e93fe43e56b9775e30a0a647af92cff1c1d4205003eae7e3c4781d7d935e66493ee2109d045f37d4d2b14caaf3d398e2ce8fd2fc3ef03
    # ./tmux
    ..


    # ./tmuxinator
    tmuxinator      type=dir mode=0700 time=1781922575.848277225
        home.yaml   size=665 time=1781922586.544243030 cksum=4443008 \
                    md5=7a86ed4afa35c5cab29da24c950967de \
                    rmd160=f835e52c4ed367eef50ad973faf9d4677fe26c07 \
                    sha1=c1cb46e0ea444180cf7de97afb3e3d132bfa7164 \
                    sha256=89ca3d276865856a846fdfc8e34ebdeca4b88b6430988e9702e0089b5a356764 \
                    sha384=b05fc0348cd837999fcd5220013961eda44ed69ecbe775b8afd26fa0ff35a000c15dcc70d741b4530dd62d9a44e1b562 \
                    sha512=55eebc4a2576b041ed44e71f16bd9b29c2c75175cf2aa02921056c6e1f6a60ffb03020794111ef169e4039cfb987f1abcbbd3e7fae15525ba167138047d6eac9
        misc.yaml   size=105 time=1781922586.544269460 cksum=2632264848 \
                    md5=739ad0c8803d5a203d8348a9fa68e1e4 \
                    rmd160=557b8ba7549ad72f5c26246d3bf2d7b08059eb65 \
                    sha1=5091d0f997c91088f519b3ae3f40ac1af46fe613 \
                    sha256=5e3d59b44f70c4ed968739739e868f3528a010410b494cff0d687bf13d3e37b6 \
                    sha384=c11938881280d2912c6e3f827bd025ee57d6dacf82ecd3fd3951aee4879d2131624b8b37772f377c77ccc2faca1242e0 \
                    sha512=8b28c6d4b00e3575e44b72a22199faa44c641b8136c29c3a67992741c5d4f67318b37290909cf8ffadcbcc2516e97f6925b8bd6a4b6181e1f0d618ce0c3518c7
        writing.yaml \
                    size=122 time=1781922586.544297122 cksum=1052548573 \
                    md5=5a475edea6123fc4b4ba4c2200ff357c \
                    rmd160=1dfda5e4229ca217a5c4a68bd496005ffc45e07f \
                    sha1=1b50c5c875d300b544f6a02313540692d63cfc1d \
                    sha256=b464d33f03b869e58b36653c2c36f34e928089e78fa4ba21a65aac687ffd4689 \
                    sha384=3c05dd87491901d4f5c7eb25c90fce255f9eb74edbb0a2a40644db5500e7ef729db6ba5631c5276182d0c9d3ff7bf833 \
                    sha512=dcad1283ca51e908e567a0586a87b79032cddefb2d70498484f74c192bd1df01be5cf37f63a27dc009bfa6b7a2260b73ab0fbcfcf5cb3bdaf320386812c386b7
    # ./tmuxinator
    ..


    # ./tridactyl
    tridactyl       type=dir mode=0700 time=1781922575.848306620
        tridactylrc size=508 time=1781922586.544963474 cksum=3695358515 \
                    md5=54fe329371288d8454670a5fae198928 \
                    rmd160=2af71927baacb8cbc71100e8edb74f23dbb23758 \
                    sha1=a1f95e2184435a7004d98d8c7e2b179069659a30 \
                    sha256=acdef8d6318c125bf54ffbee9a94536925b2404a2124e545eae71de67c19291c \
                    sha384=014307456ee1d778cb44588a363601bb7b9ae8c388e822166716008337f1db36c3accbadd0b48253545291a29a3fa9ee \
                    sha512=16d8d7da89aa85e73cea05727b05b46273c0c9eb5339e481c67baab35cd89aad186be95a466a8cc1ed7631c59765f1a1163f1d31e40cf84441b03184fe239969
        tridactylrc.private \
                    size=56 time=1781922586.643558397 cksum=2746738677 \
                    md5=c6a33794bb4798590e352e70867d6ae4 \
                    rmd160=ea96e7f4c884974a8e927741af20e97e73e6ab2f \
                    sha1=1fdd9ff6b9528e47e0d4a4e3c57a0ee8e26a1aef \
                    sha256=3deed809fa4e978683b7137feee52eb76305eb675a799659382088c943fea3a2 \
                    sha384=de482b654e50dcfe731d554dd1f70e6de0feba327856b079838145cef10670525dcc76164bfb6b19532974676512951e \
                    sha512=cd898f9693196f076f9e08c6350d7a139293cb2e5d357e2c18f96d44992f04fdbf32182f4df05ff6f2f2ea67df4978ecd1d1ec32745d2ecd13a6004adab4653d
    # ./tridactyl
    ..


    # ./xkb
    /set type=file uname=bmc gname=bmc mode=0700 nlink=1 flags=none
    xkb             type=dir time=1781922575.961445868

    # ./xkb/compat
    compat          type=dir time=1781922575.961445868
    # ./xkb/compat
    ..


    # ./xkb/keycodes
    keycodes        type=dir time=1781922575.961445868
    # ./xkb/keycodes
    ..


    # ./xkb/rules
    /set type=file uname=bmc gname=bmc mode=0600 nlink=1 flags=none
    rules           type=dir mode=0700 time=1781922575.963234860
        evdev       size=61 time=1781922586.639783633 cksum=701877747 \
                    md5=cb2a1d3af6f28039ef9338b4b77c9ff8 \
                    rmd160=61795c8e1537eca564eaf6d2d517b08d61aa79fa \
                    sha1=0125309558bc770c3c4e931e07f6e694cbf2e85a \
                    sha256=37f49672439a444e8cdb4db03bbe3adc47060c3425bd21bf7a83d7157958704c \
                    sha384=c5072b498bee74acd94277802dd713ae773d66f382cbf56a8d95bf31cef905ad9dbdb092adedab8cf91cfd416909d48d \
                    sha512=fef22cfb70d481bbc63bf3bbc1eca5d97300957598b599277d651558523cbf2d938bde5eb148e70320cdeae2f3dded9634a67487ee08a64a3e0a5d3e47780d8b
        evdev.xml   size=565 time=1781922586.639935709 cksum=1593295626 \
                    md5=42877913d6f33799c8ebc642fdcead51 \
                    rmd160=7a1968430732aabd6a567def4041456f5006531e \
                    sha1=dfdcd19c787f4e29ca812d0a8c15a89eb0685036 \
                    sha256=707a151c39874ee997800ca710999b9067a2857833aa612cea3f7915ff0bff91 \
                    sha384=29a7b21e85bf183f318b0497113ba30bf61e8bca0f9c71818a2173da839d6e8c46b0d8e190e048104daa5a9e865ccd5f \
                    sha512=9f5d0c6826d1763612ce5a6c7f0c68bb175c0819fad931af105d7288d4e5c8b0f4c3e8d1e36891db8a043b360de668014644a7bebf7dcfda07af4fc16cb39ba2
    # ./xkb/rules
    ..


    # ./xkb/symbols
    symbols         type=dir mode=0700 time=1781922575.961445868
        bmc         size=681 time=1781922586.639575853 cksum=3870813416 \
                    md5=68e9529854e0c025473b0b15c999f983 \
                    rmd160=f0b8d63c08296e0f05be5f35e339e5fe662fc967 \
                    sha1=d8009becf88d03d80818d3e6a8219b41253453d0 \
                    sha256=337ecfd6407eb13dea03a843b5b0673bfad032f9e6fe27e62207d119fcca2200 \
                    sha384=a6619bb05b0ce969f00fdc0198cb2365ef8135f0acca79c1a82140bcd316edc9b1aaf2a6fd127161262484088c1b8f9d \
                    sha512=1fdfdcb3dfd61a24a856bb195f9d3a9d7869f609c687227acefe4633d421cbce26e4c2b7bda18ff8cf85b50c766bac8434729f5346dca645341c450577a27bae
    # ./xkb/symbols
    ..


    # ./xkb/types
    types           type=dir mode=0700 time=1781922575.961445868
    # ./xkb/types
    ..

    # ./xkb
    ..


    # ./zsh
    zsh             type=dir mode=0700 time=1781922575.965468969
        editors     size=1950 time=1781922586.640623682 cksum=1180611980 \
                    md5=dc79cd50f023a0f4f380ca2405f51f24 \
                    rmd160=bfbb032485dd5238e5698d2df49e24eb3a71ff29 \
                    sha1=c2dcd9ae185eaf95c4553cd6869640e64ee5e205 \
                    sha256=097bc8d35d65e8f585927720472b2797304c7ebf6d0f054a818bc10305120b78 \
                    sha384=8a077513294d1c981755bbdc5f555205a922ddcd7e3279991a542104a229756a37ba2646c3bcbd6a51f5f84c4bbf8b97 \
                    sha512=9760e4cb780d1d55f23972083fed6db4d606cf64d83b2e71541dbea5e2694ec0acf7cb24467f7e1444a3f19f43aa3a020f195606a74e72ced91060f8d115fb02
        zlogout     size=206 time=1781922586.641137217 cksum=982024255 \
                    md5=1b6d95368c17c76771a8621817b23c13 \
                    rmd160=c26971923b4f1d8b4a8ba54e4871bf1cce27af0e \
                    sha1=d4bfda00d0d64f415140ad031b87164b1276a49d \
                    sha256=8444dcfad1c73653f47d34db26611d3ff8bac9b2de39072105db3fba5fec820e \
                    sha384=0e7c1fd0f8036452f675274a6884407dee5de0c4d7169f5e4b6ef46ffed985cb0a903df4b289ba9c66e3fe122d797b44 \
                    sha512=e0e801671bc2e2c75bb13b894fc88b6bfb4f46c3a16c22ca9f5e0595903dfe67827101d5f996c09a34f805ddf0955ac4277808e32df9f74d11402bb692add8df
        zprofile    size=295 time=1781922586.641283271 cksum=3483402022 \
                    md5=49ef4776601fbc8599a0519073396b63 \
                    rmd160=284ef4a010f2930b01b0f796682a013b88884e5f \
                    sha1=1e9a3d4032c054415e28957874f98ecf702a1307 \
                    sha256=b76312d52fb528d294c0ea8459a07880059d0f0af3d2ae418f2d11f47236e65f \
                    sha384=d9eebd5b8dbf7f66300939dbd4c0bca19aa13abbde7e17fbcb3a59fa90df3804a576da948447f33fa5dafa5b3a0b5de3 \
                    sha512=a4bbcb08ee987465d2f9203df9d4ed88289d7c1813d49cd968d520ea74d6b769ea2132b30dee94ae40197a50c4b9980c1554815a017162f0c33a0198a5fe3e82
        zshenv      size=8987 time=1781922586.640781889 cksum=3923260385 \
                    md5=11e9c14ddf3bb5f2028f9d1fba51085e \
                    rmd160=6085817dd9102718384988307386b2a69519b7b1 \
                    sha1=9b2c20d4df95682ab5bdb60660f5df48c0ea05fd \
                    sha256=99886bb04c9e7b17b642c0be833e47ce7c795e895c0ef64bf1a1e092c822df0f \
                    sha384=28423a19a5ce43b1ac9950f013eca43a8ee04d056d0e82e35a3a7e3da30c968908d44b7f8e3ce96f5dd3b2a1ba151a71 \
                    sha512=c48bff91eb3a3b32dd3b3e0df8d3e2500067d3b0440a0bfeb32b66da3db487022fe2651c38bdc56de5551677c8487a0d2d134c1fa8ade47f55749132175c394c
        zshenvlocal size=129 time=1781922586.642894049 cksum=1315654377 \
                    md5=40f4bc3f1574b2ac74ead9e68157db95 \
                    rmd160=a0e3760e286aa5caadde176384b497827f58c1d8 \
                    sha1=e18898a1758ff5e01a1e289b6893a69aee5ea183 \
                    sha256=37c19828a10099c53986e5d385eb9b59c46ce929f6e9926cdccd26822b90b6cf \
                    sha384=024bb5cad7d286e5b6b3f7c1093a28a924e22359f056aab4ed7047c0ebca61e993068ccb6c743e0a6e6e3afb4ce87538 \
                    sha512=a2e9152db833ce3796bd2c63a6fd804763458af6a56aa3d1bc1a6feb4148be79fab72aa5b686b172311e8328ac3ae0c7226c554a0df5a8967f5429fcc826103b
        zshrc       size=9271 time=1781922586.640987115 cksum=3461762020 \
                    md5=7e220bbddb8ea720c481202e9cae2b0e \
                    rmd160=1fd36bf92bd8bb29dbf2f84bd909defcb38c9284 \
                    sha1=11dd432572c451d2d93e8e3782ae2257c1c453d7 \
                    sha256=73c5a637a2d8c12bec1c0be09356474c2a83c66ed634ddd1e68c4b13a67d80f7 \
                    sha384=7fccdaca9cc4a9564d1e6b312b7921b93d9a0d4b0901a49d692b33f478c84fbb421c63c39b56cbbae538f6b9dfc9fb36 \
                    sha512=f7ec61005415aa7411d7bbde0d44eb89244a41754052634ba04de1328177353538e9da516fc6c2c97be91147641a4bddf071ad509c67732ebce4e8327345ca5f

    # ./zsh/functions
    functions       type=dir mode=0700 time=1781922575.965436638
        bmc_palette size=2373 time=1781922586.641461026 cksum=382594786 \
                    md5=460e77728cf006d150a585783084bd44 \
                    rmd160=8eadf044db050bbeaa560778ee2f553f36ebb9fb \
                    sha1=4c117ab75deefec1821315fd1465b4c8c3fc07fc \
                    sha256=7497b60a2814a9f994db7149647db82b7c3386b4838aa8061a75c85e7bbbd8af \
                    sha384=77a8aa141ea5d338571f5b5f6b0735aff278d30ec791ffd40f4f0b413f8f543c1463d3e508c0f1d3b25f06efcc951a8d \
                    sha512=0e53b7c3c8144fd8a0fbdda1116f55f253e4d5a262e4f2943cc6e88f010da0dbc19996cad0c789623a2560a0cbcf42f1fea2472244621d84ea0889185bc1fd51
        bmc_palette_ansi \
                    size=340 time=1781922586.641489259 cksum=3633915147 \
                    md5=a0adf2dd0bfc556f8596fdb1020a38fb \
                    rmd160=b5ea3d0f9e7cab207131c8e28576cf4e4f6fd166 \
                    sha1=325029a5eb625dc43c442ae0a13df81565567356 \
                    sha256=cf86d42719375ce8c4ed4532d1e04b95b8018b32691359417e74e669ed723e81 \
                    sha384=af912efe5e9069541a3543a9095d8b201d12c9e88c0b2f24261d1d6942e048d40b7dbacc0ba5bc78202536852f65f9d0 \
                    sha512=8b7922d303813ab2dcb99a5f9f1202929cfac0c2625239dde27daae948c84c95ddc25e5a9ebdfd5c27284627e355a09083b87c5c3f2c1eea8a03c7b1bc78a389
        color_bg    size=1263 time=1781922586.641512773 cksum=694624075 \
                    md5=0494e5efefa6c03547710a75ecb4cd79 \
                    rmd160=ad960f359b13b9319efad827a4234d9e8b1a61e1 \
                    sha1=46798cd7f54671b80c0c6e40253993027848a367 \
                    sha256=8eb9dcb597896aab51e89d66721f6ac4e3b466cc616c83766ac3b68aded5cf76 \
                    sha384=76264e67b43bbd01bad773605a8af65bbb403ba4e7c8041d76ee9bf975e7f8cc891dd62222d089c1759ff324effaaa15 \
                    sha512=cd8e2eace3bdb46b594ad02ad24df82cfb515b5358795011ca63ffcac87ac1d5627ea2aba67cd1888d37fabc240a226e9077361471f22ea802f8298509f3287d
        color_count_for \
                    size=753 time=1781922586.641539142 cksum=3073800257 \
                    md5=8ecbb4d0784bd5f97af3d0ab0afe2474 \
                    rmd160=343520dc14a27dc5e74abbae57994f971ff0cb4d \
                    sha1=209b0544d250dab7eb3f916746888ff23cc2e9b9 \
                    sha256=cb2079cd43c7b8a4d883c7929ed786bb045350b89f7f3840b7ce1e1b32965cf7 \
                    sha384=098f69642de0f6be8a876b75fe77749b629d622c8461a35ce8e9ca19f2434bd7401a6317b733f8048e17371db3eddb70 \
                    sha512=d524dea324c8e63ce1739ddad44d81698f8dd1a114e5bd08a6865b081873e2bb4ea40a67178f8bb6bd0b6e2babc5468d710b8a2b907be03aad8357066a5cd135
        color_fg    size=1263 time=1781922586.641562306 cksum=809388496 \
                    md5=a77e5fa911693ec12481d129fe38b232 \
                    rmd160=5a8de78ae443da3c5d0976dd2a4a9eb5e73f15a3 \
                    sha1=7331fd0e0a3db9f7212ac16896b64574b69f40e9 \
                    sha256=a95c9921af58b434fbeeeb883a179b5de09c30d6e16dc1f71680323d0ed14faa \
                    sha384=d7022169c28af893e63db419d598e4187c42924bc984e1ae8ab3c9a5fd4f26d0a1d4a936a920bc7698fa368d37256d21 \
                    sha512=b1981fca480fbc36fc9ef9126920da07df8b1f4bb6cf8d806c4b78829e9a7872e0fae33d06d15e4778218c0bc19b7990dc6fe0ac3ef35c6a339a576f28fc131b
        color_fg_ansi \
                    size=305 time=1781922586.641589096 cksum=144891780 \
                    md5=d1b06e00c8c4452ff55a296db2ce738e \
                    rmd160=aff301143010158cdff15690a8d0c751901a2d75 \
                    sha1=29c1b09b787255a122a1a03c69afcfd522caf7f2 \
                    sha256=d9e254060400254baff50bc0809c11e472207bb4f36effa8ea8247ffe3cce21d \
                    sha384=1002a315df27550d3005ce088293f368ce0ea2ded341029da46caebe4ddb1222899cda4340fb8575908a7be593dfa05f \
                    sha512=283bd3a78827f2e13645ac09de6beb695d6fb73c6d79ddf10c24bbadca319a6c6cd51d462f331aec97ecdb4063cd73577a7993d648ef3b56e84b1a267cb85b15
        color_reset size=124 time=1781922586.641612029 cksum=1170187585 \
                    md5=632ac391da120885fbcf3f772005ae66 \
                    rmd160=84c917386266dde087c572abbcb0a52c42b3cca6 \
                    sha1=94d0acfd1d1f4232fd91365ff1ec2f2dcaa8b9a5 \
                    sha256=94d17328f0b998b44d1d9b8054f72cbb594330c6ecf6b178cdd11d9bbcf51e14 \
                    sha384=df23ece8fd0f97abc9447a7fef927750f497980839062a64356d7a03750e643ac9bf19926e6a7d54b92ffccfb999e3d6 \
                    sha512=947ab55b0867601f232f9820ed7f371575fdb145690e060c5cc46cb0593a6ed25b84f26b9e8f84ff2518cb6201aaefd1c28746ddac087d8e8b0036ed52d78b50
        prompt_bmc_setup \
                    size=5984 time=1781922586.641636435 cksum=490608105 \
                    md5=ccdfc96e053bf025327e736813501e7e \
                    rmd160=cc20d6b68a069d72dc6dcc5eb69244dffd643562 \
                    sha1=5473908ea13e55124a56741a39e7a9c67e30106b \
                    sha256=ec78026ed4610ea6315d1095f67323fc71c370344592b69a161b90c45dab2212 \
                    sha384=595f2d70ca23b0859334db5c82e75e557d7d1f8d9ae78d6f2da57153d1268a7400b2ebcb323b7295c99f559acffdb2c0 \
                    sha512=764484d856e53b5c6f6317d3957e03e06af88b131cbfea9b2e6bdf8070fafc55e78228b2564f339aa6336ceabab7a3a63a7582d5e0067fa358f10cb972d6641c
        set_keybindings \
                    size=2502 time=1781922586.641669537 cksum=846717864 \
                    md5=3cfedc9aa6539ce567b1b7215140630b \
                    rmd160=ecf1a2a4d2c82396cbd28137dd796cf9d4bb0667 \
                    sha1=ea507e3d72d1ecf957c31522ef91681012ac0f12 \
                    sha256=b7ebfb34b0cda816bc11fbd04713d0593917c0ce80d12f19ddc07a39916a1078 \
                    sha384=ab460e73872a224b8a7dce946348bea6b80d8101dae4a05e6074afe3abfdf8ff2c3f7734cb9330539055be11ee8aec36 \
                    sha512=099db60792669360674a4824c403d6990eb7a7608d2387ac56a206734c8c1a35d7ef1d5bd051b500ebaa325df879fe78fefc2420e22ffab3b0e696ba5c435661
        setup_completion \
                    size=6066 time=1781922586.641705194 cksum=441958056 \
                    md5=cfc72b8785759774def313ba868aa02f \
                    rmd160=2a2e9577d156234c57c44f92df3ea97bf9c856d5 \
                    sha1=c9024ab255ae1aca241798d35a9a226cf3037082 \
                    sha256=b7e8ea74dc2b1efa54f4fe09d4aadc1ebd0e412d9859847b90e8408c7111bc2c \
                    sha384=ccbdc260fe0454d58926e479699e81eab7d3e03825661133619b5d0165a6c74090ceffa0776ce0eb2cf7161f602387a5 \
                    sha512=7a423a72312ab0f78e1ace31b0bfa64f8e9bc754108117da77b66c51e90cef1b88d21d9cf290eb0c24fd722b4fb59bb18b6d4539b3a4204762edb4159c2b284f
    # ./zsh/functions
    ..

    # ./zsh
    ..

    EOF

    EXPECTED = <<~'EOF'
    . type=dir uname=bmc gname=bmc mode=0700 nlink=1 time=1781923390.867878812 flags=none
    ./nvim type=link uname=bmc gname=bmc mode=0777 nlink=1 link=../.vim time=1781922586.544963474 flags=none
    ./abcd\\ type=dir uname=bmc gname=bmc mode=0775 nlink=1 time=1781923384.527988155 flags=none
    ./alacritty type=dir uname=bmc gname=bmc mode=0700 nlink=1 time=1781922575.840764324 flags=none
    ./alacritty/alacritty.toml type=file uname=bmc gname=bmc mode=0640 nlink=1 size=1657 time=1781922586.537646622 cksum=3019338482 md5=1bb596f0a2462fc982227ca38e361953 rmd160=279bca3c5544fe288720cd2a20c6f94d5b906c51 sha1=2615cba7b4f382abf9f4e4c3e93099dff8222333 sha256=8af6915c6a29481b6fe101ad88272bcb666bc9d4f5275452cff1b68d71e3aeaf sha384=1ced4c8a3d53bf80fa1f6189ef54a8362ce39adceb73d1320c7965fc155daa5e5d7c8ced6963505be469908d80f577a8 sha512=c1057037b486dd3466a8f445091bc6e8e8a31bcc9d61048f8700f0f864e1d6a785abe0f7a0a69310b0df6ecc41db30f97e46489e81621d3c0ab5018c45ccc732 flags=none
    ./alacritty/alacritty.yml type=file uname=bmc gname=bmc mode=0640 nlink=1 size=1810 time=1781922586.537450193 cksum=1984605283 md5=331f4f8ba154d04036507fbaba4127dd rmd160=2a68592f18139e4b76a176890630d19288d7b63b sha1=94516ed79fa8fbd62d42fb7a87d9b7cee56e8a3a sha256=5b504be024805065b0f639c09501078b31d733115b005009098364dd623b7709 sha384=64fa3f4c7df676cab8d2087751bca665a1738e5c949c851a5a7102ec43ad18a754d2ca772bfbfd670241dcf6aa5dc50e sha512=b57aa042fd4af00a18e787594dafb7a56d415f48c3abf0319275f6aefa03c4e8bf1d0a25e8898df79a849a56c9338cbaf93d7567c2f24f061c8b0cd16b4f0194 flags=none
    ./dct-jump type=dir uname=bmc gname=bmc mode=0700 nlink=1 time=1781922575.841113711 flags=none
    ./dct-jump/config type=file uname=bmc gname=bmc mode=0600 nlink=1 size=2157 time=1781922586.537966333 cksum=3349588464 md5=66f48dc2158e42cd15f45cbc6cc53dde rmd160=984fc1f68bbbc1c4dcebc4d70e8baeeaeabd445e sha1=f9f767ee034a7489a0f1d83489da9d81cadadf10 sha256=b50e725ff04d8343d60ec65b96e8f16f83d863c8dbce4310d85e012496d0be83 sha384=5027c382cf8479d9d19130e168401e17d4252050083bfb7a04197e3af4e37b66b76dbbb6aaff4311427fce336d9e98b4 sha512=623d6e464401b978b394ad3f096e432cb410a2b5f851d5cf7255fc3aeaf84d29ef398f3902e9f90f22ce8556719cda15f3debdfd77ae46c50c32fd887ece8cea flags=none
    ./efgh\s\\ type=dir uname=bmc gname=bmc mode=0775 nlink=1 time=1781923390.867878812 flags=none
    ./git type=dir uname=bmc gname=bmc mode=0755 nlink=1 time=1781922575.836762122 flags=none
    ./git/config type=file uname=bmc gname=bmc mode=0644 nlink=1 size=6973 time=1781922586.532964423 cksum=3167949394 md5=98970a2d7e36fac13ae968b960b0261d rmd160=9e3f34a411f9172cf584eeaa29ed5fc495454cd7 sha1=62396a7b48796a572b784507baf8578b0776008a sha256=acb50991cf397a1b6a9ae06c2ed6dd9c0ec9ab17fa94efc588c38058694ff502 sha384=66a2cd95c64c56b71e139f6cbaadf2150c772207e09b39b6d0e18c96dc7ef692b551584b9469b15a3c63b470ed5e4b34 sha512=09f7d1116d82dc3dee83d9f7891137f44df43134039d3bd37ba93c1a0823e404d713648f39960cee581c148fd04b1f97e38cb44691d6bb59736ad6e22684aac6 flags=none
    ./kitty type=dir uname=bmc gname=bmc mode=0700 nlink=1 time=1781922575.837534414 flags=none
    ./kitty/kitty.conf type=file uname=bmc gname=bmc mode=0640 nlink=1 size=941 time=1781922586.534766360 cksum=362245594 md5=b2b091a8a0883cc4fdcf74e41e603a1d rmd160=3e94572b8cc8297ee1f6bb30e5769e922e3ccfd0 sha1=9b4f8902a74bb217a8d5f305941d7975062dce6e sha256=874f3c9733bd616c68bb5c5c52d44f0171d3d457b87d8e1c782e2c1fc492f26a sha384=f474b232ac68b87c7b8b3aea16c404dd12f629ece74cd0d2e9d5551568443b9c2dc5f0f8bd182a0ce655951b9fa762c9 sha512=fbcff876ba05105b92e6222da65c28cf46a347e1df1e95efd8b0eca5433fb98f9c36cb6d52997ec0fc16f29ccce7bbf32293638be25ee9a3d6efd62d9ebfac52 flags=none
    ./kitty/conf.d type=dir uname=bmc gname=bmc mode=0700 nlink=1 time=1781922575.838360366 flags=none
    ./kitty/conf.d/fonts.conf type=file uname=bmc gname=bmc mode=0640 nlink=1 size=50 time=1781922586.535091931 cksum=1850747784 md5=e38451fccf09bebbef7fd37641fb51e4 rmd160=4d1f6b4c3aae4175920cdc3e37f01bcabc56b5a2 sha1=03040468b3234e3c9d133899a91f7d8204166341 sha256=13def07a922567b7e384110dfd3ac60098a921436c081cc57363c055b4cade87 sha384=01d23941dd48635c1537de4c8bc9f86d367baaa4428c40171277c0395ffc2873de0602674a416bbf2422760dd0e10b69 sha512=fc3c5bc793dbbff175d187997f8c4a4f6cf107c6228bb2bc089c48301d1589fbd584c10ba75a3bb7004a76090b9418c43f6a3720218153c5a8c2672cebbe5b3f flags=none
    ./lawn type=dir uname=bmc gname=bmc mode=0700 nlink=1 time=1781922575.840289261 flags=none
    ./lawn/config.yaml type=file uname=bmc gname=bmc mode=0600 nlink=1 size=1245 time=1781922586.537295442 cksum=165022565 md5=210fc66b4abadaafa3a832b552e096c4 rmd160=8ce53bd412114528833d6db2429843aeeaedd7f8 sha1=f8d457019d6c489c175747f38f2c45db6ba47b1b sha256=c31b14ee8fcd2e47b07cf3491a496d19d10402f98ec61388eec04907775f9c7d sha384=fe90374540ad0a8f83369988da6c95df312db872b97a306cce0cb4ea25b0f2a7278e46612a37230c7651d08b7525a391 sha512=173f2141ffb64487d947cef2d06461381acab4f7131dc0c1956eb20d052b679603648d835d2260084cf60e28dc5b09d7e0c5150741ee9b98813eb06833ef6dbc flags=none
    ./mutt type=dir uname=bmc gname=bmc mode=0700 nlink=1 time=1781922575.843890249 flags=none
    ./mutt/aliases type=file uname=bmc gname=bmc mode=0600 nlink=1 size=2490 time=1781922586.643047226 cksum=89445784 md5=f484c7e9d4aad8ad82aab83cb0c3adbe rmd160=c629b767694ce2c0571882274aecd56d4bb3a5e4 sha1=7fb5a308ce196ca68755a805f06e34d6c59dbfc6 sha256=52c3e6fbd28bc8d8120c3c435e4c2d58ad6dbb41d15885dba93d5e18b17bb108 sha384=d65f1ea4d9c0b19d8713bb09844a882e61f8d4432b0c03452b97484c20f72211d412fb57b96b8d5ebe2eece8ad9b3c3d sha512=27114c4833861eabdd7a80a5cb140918be6dc6caa2b8a726bf3fedda370bce26070a88e20639dc75b0964e4ecc0bba5520077a2b45414982c2221967752abdbd flags=none
    ./mutt/muttrc type=file uname=bmc gname=bmc mode=0600 nlink=1 size=190 time=1781922586.539500918 cksum=3618234492 md5=add11fbb467e3aa8f31d4b4318f9449d rmd160=6c4b1ead1b7e9e79649b106a496f403873951cc0 sha1=3671ce5e1ea9f62a20e22d56f8eca60b1693936c sha256=e201fbafee48bec6afe71fddf50d9acad030e34158be1b3d1d4a0a87a28a33c8 sha384=f3f0c093cce0f68656d5e4c165dfa1e4587fba26cc99b00acbbccb8ba5abf6141f81b6ded129bcf8824138ad47691cb9 sha512=51065d804c856d57d4114b427ecb30dd974edfcc44237222ae64e585818aba742ae872f3318238fe64e7cf25f5421a0f3872c1e2f037ff051bbfa524882a997a flags=none
    ./mutt/profile.auricblue type=file uname=bmc gname=bmc mode=0600 nlink=1 size=68 time=1781922586.540213236 cksum=2487727371 md5=4e0e2c61d8b2783f99bd7fbbfef6a9dc rmd160=4e67f086a7f6252dfd40015117a79bef38d76aaf sha1=36f0fa57575dc6547310c9167eb219f78450ae9c sha256=8915064169104448ef65594273119832076f2c5854d32bb2260bd6fe1aa56445 sha384=4ff2adbfcc65b93b36b7eede3927551b284921577688f9bc65d4317d5af6ea44c4cf3e08854e57b3a7a7ce8cade64c69 sha512=13035bf77642b1f3777b9864ef2ca38ec986e180ba895d0cfd220a620defd38aa2f1c2e5319a8f385af37aaae53d5a447f19a0fc04d4ec01cb1e6c9232b4af8e flags=none
    ./mutt/profile.gmail type=file uname=bmc gname=bmc mode=0600 nlink=1 size=59 time=1781922586.540408233 cksum=42659435 md5=1bfb245d5ce979ec099d4086195bb3f6 rmd160=d67840e7f565a42a6c3d840806b14e96a01b725d sha1=64d3cf729e119462b02b3ab4e3a4df06257a2589 sha256=cee4a531d44ccb5bf3f49b27915c3d7b232f940f73b1f46e71c3151013b03db0 sha384=c5dc1ab2ba719d6c9af7615b896697e86cb0a98caad78930f7aebdd339279bfa28d755068dd714505808c9f877a2791a sha512=efaf77a39bf553d6f673e8a1c6c38fa0019f459729c7fd31b2514616f3bf941a1ed81005cb7ab1a0b248649b3bbbbb3bd94beeda5a9101bb849ec41aed61b8c7 flags=none
    ./mutt/profile.personal type=file uname=bmc gname=bmc mode=0600 nlink=1 size=65 time=1781922586.540570678 cksum=114662987 md5=3ef88f7851209fe8c53f782571f8f3cf rmd160=aeaf879cf800269117e640fcc0f9eb7c6762a090 sha1=9d66f2bcc6a76c637d35bac254f3ca5343a25560 sha256=554fe55a9e7a8030ffd8da418bba0b09d9e7e0c23eafa1843564bbf07c148d61 sha384=9bdffe05f9e6c64d616eb24deeef74b212352b1f4b015ca8ebc76eda384d515e13077d7d83461934afc1dff22357bcf0 sha512=8c7bcc35650464a7dd3528fb8e6e7b331b1f2096af39655c0cd94504c2ae41776f5f1a36ceebfde6aa2407cd67a9a4eab31a144593341a69672ea20495c52e3e flags=none
    ./mutt/config.d type=dir uname=bmc gname=bmc mode=0700 nlink=1 time=1781922575.843537687 flags=none
    ./mutt/config.d/account-auricblue type=file uname=bmc gname=bmc mode=0600 nlink=1 size=766 time=1781922586.539855965 cksum=3681985873 md5=5f69870d613d2b2fa7c32ea04f1c6e20 rmd160=07312810f59311b3e5ccd98a5c9704e951f80e15 sha1=e76cc98729f5eede46c76480f9668d964f55d379 sha256=16543652c623ed7b7a74d46d1b3dddb7ffd91674d809a5ab68bd388310ca7127 sha384=6c1a73af61aa539845a34ac2df2005ac79df07aaa835eb8ebf961b9a111d40372add937d315cef494f9db57e8f9d8aca sha512=2156988ed54287de66256a8d25d8412fee66c3c6b464e1817f559df2c48d4dc105343fb17b99808bdbadfc4198906d623a148aded0b1640e396c94985c0f3b84 flags=none
    ./mutt/config.d/account-gmail type=file uname=bmc gname=bmc mode=0600 nlink=1 size=891 time=1781922586.539882825 cksum=2792356538 md5=e2a598179bd539cdb532a207e4b1bfec rmd160=9e3577b6516c3bd8ac41341c9b8428da8be0120b sha1=9d5a1f1ee4c9a0df0b106bd093778e6dd510f0b6 sha256=c65dcd9ee9a5ff0c89d012f8b516f4d2ea1bfb4291a632090a774d8afdd1848a sha384=5c922662e54646e23769d0cadf218daad765219000f36f39422b600beca4c380b70994130102fc13c669f8868986d5d0 sha512=8741e4dd80cff026a136a3ef5027fb3dd58636d70cff81f154fc6bb8173f65ea319bb1e5f04b85a90a569694dfb21e2f56556f9a5cb7fbd25fbf68ab8f84f877 flags=none
    ./mutt/config.d/account-personal type=file uname=bmc gname=bmc mode=0600 nlink=1 size=748 time=1781922586.539909125 cksum=3401678405 md5=1d7f2d8760f942b1c7da7e07350663f3 rmd160=4ccaf116731af623a1ce72ec5f8fa74c94308100 sha1=4aa1ccc461ed62d4fee5471d2f779ab61bb8eb20 sha256=f8dde45bb37b0230620f901912c01a8a25ac9c539e890885aaa4b6ca3e5e03f1 sha384=fc9d78f069cde024f4328ce36c125fad85e7f3a9afb919aa529d96973b9cc5e90fcbbb8793378405b9c19342df97dd4b sha512=2079cab3ab8a0cdb25f7f971a1462d08547b7f34ac86218dbd8db8a3a98e984e1b8df0a76173ccf6c0c51862e69089f2a71b34344d08aeaa2b968d579fc9f721 flags=none
    ./mutt/config.d/address type=file uname=bmc gname=bmc mode=0600 nlink=1 size=1394 time=1781922586.539934643 cksum=2912450449 md5=9b50065b538730ff5fe17e837f87f190 rmd160=89f07390674a957a5ad03ee711c0f1eaaa78d6cc sha1=778732f63a3ddca15cfff52b4b3f6b4fe0bbe9d6 sha256=3431576d359ba83c273623e495bf2b98b549d0c8dc5fdb1f41aef73017482592 sha384=18d1fdb72c6e4c496b31b68e3990f92e87e33508107eac450a28f5a7d414a52de5faa8c389de30c5fed3ec5d64f36cea sha512=b96d8356999272f60478ce74a0ad461b5a40f7f9ac78fb547a5422544f73625c9a28e40d03144f39029786fb7b3713e90e2e9250daf85a7f836fdfd368a7792d flags=none
    ./mutt/config.d/crypto type=file uname=bmc gname=bmc mode=0600 nlink=1 size=352 time=1781922586.539961583 cksum=1441591471 md5=83fe65f352054a4855b7aabadd462f3b rmd160=7e86c83de27ce6f162d9b17b428c7ac8fd9f476f sha1=aa021737e8cf94b77dec10d6f54e0cea72db9396 sha256=440422c036482e17fac75478dfa0654cbfa245b6dba344de9686768562533884 sha384=288ec37bd023e7ea6558dfafe695367ca28dc775e82ed969095077e7abfb6f8aaf03822506d396481bf8643857c1dd76 sha512=6d41ab072f34c66718599fd87967af45357ee3511e177a35c05bb183a0c19059473b7117797a9cb780ca30b50cf0275732bce6c2b60a8c73af5fe0eeaa001bd9 flags=none
    ./mutt/config.d/iface type=file uname=bmc gname=bmc mode=0600 nlink=1 size=703 time=1781922586.539986630 cksum=1952966797 md5=4a2ad1d8553983b2f24b134326cfc4bd rmd160=8e216c0371688006510b0db3b9e31b4865c8202a sha1=f7f87b34216af474ed02f597a9a333caa8404fb7 sha256=788a1b48de0b25e03ac4b1db9f8137d361dee0b8c979a6c9d05d27351a5645fc sha384=574ce51c3f84a92cc1c4b66febc47991cbc0c6a785315d7002ca7cf1c51fceba4cdb089b2597a829aaf54a468226fb59 sha512=a0f46666287acedd9dfe37adb93bf5e30d30192f453c7955a4e0592190ddd726ddf2f6b9ba75cbb8e098970806552248e04a9cd26ebaff7b825464d2ea44ab92 flags=none
    ./mutt/config.d/keys type=file uname=bmc gname=bmc mode=0600 nlink=1 size=705 time=1781922586.540012158 cksum=3871402869 md5=6024d7ebd37ec18e06c11bae60279c78 rmd160=fd6b635c1346e6cd6774faf39f70bc55513cd715 sha1=9984f51ca90f206e69bd8c20aa1dff840f70783d sha256=c0ac6122f56f47594eca84c522528e4b54fb3542ce0d97d5c0cca84cc43a19e1 sha384=7cac54f7f39275fcb1941cb9718c850244564d5c03622565acc44d5796cbf08b88684dff11c8a2e015b37a2005b4bac6 sha512=e4544ed2d843493f9109af82d4063faebdf66d7c60e4afcefc6cf9d09449846a1f858af0fcaac2c1e1013701c1ae0e2894017ca6bd77778c1149c3c58393a56c flags=none
    ./mutt/config.d/mime type=file uname=bmc gname=bmc mode=0600 nlink=1 size=1043 time=1781922586.540035973 cksum=1286077258 md5=51b609d3f0aa21e071e978ff9acaa5a2 rmd160=aef4b2bfce53496c5c3284dec68b9c93e0988524 sha1=9e87573830c6796b30662ecc98ddcd9bc9733323 sha256=af76b3ca74a2b0416075e8309e0f4e1b0dd5430da7aedfec462c80830cf985a7 sha384=0f71b88fcb76881293c01a7b2a795e5c354b2c5af19fe38ccff8bbb753316b89f693be03b0a0b880baec64be7438c879 sha512=84ee863a11c59d04494e81e440abc14755273749aa4ead399c9504ca71fc68ce9d197e80072b47126e4d2a698d8e1a330d35ca3d559035f95fad54df3593a951 flags=none
    ./mutt/config.d/muttlike type=file uname=bmc gname=bmc mode=0600 nlink=1 size=215 time=1781922586.540062443 cksum=36626399 md5=5f6336d9199c7f37746e90a47129013a rmd160=dbd2ebac1b12e9373352e14b6cba82e6129d11ff sha1=61f0f2cc3c3a63c65d4ee73c9d4a5e3c958839e7 sha256=3a6d73566ae945ba0e23e0d5925af81f4b74163446082d425d6ccec155055c72 sha384=947dde050a29c67d1706b8731205f3c8888249a3be0fe361784521e9ebda1d4c239ac71814eeccf1efe9d7144d09281b sha512=26dcc4164915a3b9215aec4ec430cf95778aa21c1c8ea33274f0abf3b1ab1173e3abdb7e3a6b14d62fba34249c3dd562206d29881468293caa39ed63b050379d flags=none
    ./neovide type=dir uname=bmc gname=bmc mode=0750 nlink=1 time=1781922575.840965402 flags=none
    ./neovide/config.toml type=file uname=bmc gname=bmc mode=0640 nlink=1 size=72 time=1781922586.537806403 cksum=2691964525 md5=d9f099524b17ab6cb6cc5805755f21bd rmd160=df60d4d011ebfe2de77107f8b5a62ef8637ed94f sha1=389d9829cba6747706f1732f00f4ced02de22138 sha256=67933d0c276e448cac2ebc30d34e5d8772cbba2e3bfb4fc85a1f1bed38230670 sha384=9ccd53a661987c685292072ba50e09eab3d3429e68198b40ba23b16f6687c67633b0d40c096f991644d6b351f73a8233 sha512=eea656e2b9292762355757c57bea2d3dd61352d989456b1dc3370fe2d2df08cdf24d6d04296e2fe79ec7def32e6a9635e4b7b8232db9f5dd2dccaf9acbc1ce1f flags=none
    ./signature type=dir uname=bmc gname=bmc mode=0700 nlink=1 time=1781922575.844473816 flags=none
    ./signature/auricblue type=file uname=bmc gname=bmc mode=0600 nlink=1 size=155 time=1781922586.541021075 cksum=1939657664 md5=c835d358fb601a59eba6c0930768bb65 rmd160=163472d40b196bc40e9613863af079580871cf72 sha1=3e7fd093e2b5cccc0999805acbd2baed4c6985ad sha256=07bd3ba5e0c1c4975b325ce2e605d4bbc6831829b9d7d23b8751a81c4ba6c25f sha384=0d6bbc64a8b8a803e1301ecd7a5ecc1d131902df707d45b0e921e546b1e947a8ef12375c50e0a32b50faa8cfa5151297 sha512=03f96324802218bc1e45900fdb644cc8b33003aa3b967f434a3893a7b13996cd040dc37bd1af0a843c45847a0ebad2acca6d8b5869df221f55a4e4a18f58e599 flags=none
    ./signature/personal type=file uname=bmc gname=bmc mode=0600 nlink=1 size=50 time=1781922586.541341246 cksum=1993897367 md5=21913ecff0a4e5946b43f3121bdfa97d rmd160=08c82d8cabeb3fc98cb96fa91da78121e79f8517 sha1=f0fb257573721b021199c13a3a1edaa6873e9c68 sha256=ee708cc5c8fa63e7ef2cfc9efe5ae686d39c545540d4291e0a6d3c3c5f3440bf sha384=012616f935d8d3f416d6a8460418e56571f3ce71f39363b19fe1853b7a6adafb2e5ed8a9265bd14363c1143d6050a792 sha512=3ea7c9dfd02e875bf87631e416a15ba158fa6c874022d11f768e295d53e510f0e0ec8374f3b402127a8e27f9e37351217ba8290a89a1f5559dc90e069cf5a0b2 flags=none
    ./supercalifragilisticexpialidocious type=dir uname=bmc gname=bmc mode=0775 nlink=1 time=1781923297.961531301 flags=none
    ./tmux type=dir uname=bmc gname=bmc mode=0750 nlink=1 time=1781922575.847673881 flags=none
    ./tmux/theme.conf type=file uname=bmc gname=bmc mode=0600 nlink=1 size=2428 time=1781922586.543912098 cksum=3366606526 md5=86d654dcb7f48b6d3018199b5969b443 rmd160=1c35acc59831e5a38fc335c092b42eb7d70dfc37 sha1=11d61118d2a062af79ae22d57e3854660204adb2 sha256=e6f75fd2029c0a9c2e7e4b39d49201bf8ecd2fcdd24a5c0799e340c2fb1275e0 sha384=677f2e6281cae539a5e050666e91010bb223b03ead2864d7871f4b5d8d6bf8ce12e9de33f8a3c6c597654037ce9db2c0 sha512=fc371aeed399eaec09b65cfc56d9ad3be648b2b0d9ae2e65d32aece250174f74f4f234f19b6c4e905ed54eeb360c0d7ccf5ecadb9b126eabd31f94afb3fb48d4 flags=none
    ./tmux/tmux.conf type=file uname=bmc gname=bmc mode=0600 nlink=1 size=1915 time=1781922586.543763730 cksum=773649027 md5=db8853297ee00c99b4910fb1bd95e23c rmd160=8ab18b4fc7e675b9b39b1008160045af96d4ccab sha1=b498c0cca43c751fb480eb220da2549cc56cad78 sha256=4b17318795db84b06b3fbcab340dde197d49c15c7a81c5a4c14047342fea5f1e sha384=6113aef2bbda6012130228e3a06a90146531ec5ca610c5941b95ae7fd218a457ceaeda30ea65eb83d189f8b8cb3bf492 sha512=d43664c03f15803ea15e93fe43e56b9775e30a0a647af92cff1c1d4205003eae7e3c4781d7d935e66493ee2109d045f37d4d2b14caaf3d398e2ce8fd2fc3ef03 flags=none
    ./tmuxinator type=dir uname=bmc gname=bmc mode=0700 nlink=1 time=1781922575.848277225 flags=none
    ./tmuxinator/home.yaml type=file uname=bmc gname=bmc mode=0600 nlink=1 size=665 time=1781922586.544243030 cksum=4443008 md5=7a86ed4afa35c5cab29da24c950967de rmd160=f835e52c4ed367eef50ad973faf9d4677fe26c07 sha1=c1cb46e0ea444180cf7de97afb3e3d132bfa7164 sha256=89ca3d276865856a846fdfc8e34ebdeca4b88b6430988e9702e0089b5a356764 sha384=b05fc0348cd837999fcd5220013961eda44ed69ecbe775b8afd26fa0ff35a000c15dcc70d741b4530dd62d9a44e1b562 sha512=55eebc4a2576b041ed44e71f16bd9b29c2c75175cf2aa02921056c6e1f6a60ffb03020794111ef169e4039cfb987f1abcbbd3e7fae15525ba167138047d6eac9 flags=none
    ./tmuxinator/misc.yaml type=file uname=bmc gname=bmc mode=0600 nlink=1 size=105 time=1781922586.544269460 cksum=2632264848 md5=739ad0c8803d5a203d8348a9fa68e1e4 rmd160=557b8ba7549ad72f5c26246d3bf2d7b08059eb65 sha1=5091d0f997c91088f519b3ae3f40ac1af46fe613 sha256=5e3d59b44f70c4ed968739739e868f3528a010410b494cff0d687bf13d3e37b6 sha384=c11938881280d2912c6e3f827bd025ee57d6dacf82ecd3fd3951aee4879d2131624b8b37772f377c77ccc2faca1242e0 sha512=8b28c6d4b00e3575e44b72a22199faa44c641b8136c29c3a67992741c5d4f67318b37290909cf8ffadcbcc2516e97f6925b8bd6a4b6181e1f0d618ce0c3518c7 flags=none
    ./tmuxinator/writing.yaml type=file uname=bmc gname=bmc mode=0600 nlink=1 size=122 time=1781922586.544297122 cksum=1052548573 md5=5a475edea6123fc4b4ba4c2200ff357c rmd160=1dfda5e4229ca217a5c4a68bd496005ffc45e07f sha1=1b50c5c875d300b544f6a02313540692d63cfc1d sha256=b464d33f03b869e58b36653c2c36f34e928089e78fa4ba21a65aac687ffd4689 sha384=3c05dd87491901d4f5c7eb25c90fce255f9eb74edbb0a2a40644db5500e7ef729db6ba5631c5276182d0c9d3ff7bf833 sha512=dcad1283ca51e908e567a0586a87b79032cddefb2d70498484f74c192bd1df01be5cf37f63a27dc009bfa6b7a2260b73ab0fbcfcf5cb3bdaf320386812c386b7 flags=none
    ./tridactyl type=dir uname=bmc gname=bmc mode=0700 nlink=1 time=1781922575.848306620 flags=none
    ./tridactyl/tridactylrc type=file uname=bmc gname=bmc mode=0600 nlink=1 size=508 time=1781922586.544963474 cksum=3695358515 md5=54fe329371288d8454670a5fae198928 rmd160=2af71927baacb8cbc71100e8edb74f23dbb23758 sha1=a1f95e2184435a7004d98d8c7e2b179069659a30 sha256=acdef8d6318c125bf54ffbee9a94536925b2404a2124e545eae71de67c19291c sha384=014307456ee1d778cb44588a363601bb7b9ae8c388e822166716008337f1db36c3accbadd0b48253545291a29a3fa9ee sha512=16d8d7da89aa85e73cea05727b05b46273c0c9eb5339e481c67baab35cd89aad186be95a466a8cc1ed7631c59765f1a1163f1d31e40cf84441b03184fe239969 flags=none
    ./tridactyl/tridactylrc.private type=file uname=bmc gname=bmc mode=0600 nlink=1 size=56 time=1781922586.643558397 cksum=2746738677 md5=c6a33794bb4798590e352e70867d6ae4 rmd160=ea96e7f4c884974a8e927741af20e97e73e6ab2f sha1=1fdd9ff6b9528e47e0d4a4e3c57a0ee8e26a1aef sha256=3deed809fa4e978683b7137feee52eb76305eb675a799659382088c943fea3a2 sha384=de482b654e50dcfe731d554dd1f70e6de0feba327856b079838145cef10670525dcc76164bfb6b19532974676512951e sha512=cd898f9693196f076f9e08c6350d7a139293cb2e5d357e2c18f96d44992f04fdbf32182f4df05ff6f2f2ea67df4978ecd1d1ec32745d2ecd13a6004adab4653d flags=none
    ./xkb type=dir uname=bmc gname=bmc mode=0700 nlink=1 time=1781922575.961445868 flags=none
    ./xkb/compat type=dir uname=bmc gname=bmc mode=0700 nlink=1 time=1781922575.961445868 flags=none
    ./xkb/keycodes type=dir uname=bmc gname=bmc mode=0700 nlink=1 time=1781922575.961445868 flags=none
    ./xkb/rules type=dir uname=bmc gname=bmc mode=0700 nlink=1 time=1781922575.963234860 flags=none
    ./xkb/rules/evdev type=file uname=bmc gname=bmc mode=0600 nlink=1 size=61 time=1781922586.639783633 cksum=701877747 md5=cb2a1d3af6f28039ef9338b4b77c9ff8 rmd160=61795c8e1537eca564eaf6d2d517b08d61aa79fa sha1=0125309558bc770c3c4e931e07f6e694cbf2e85a sha256=37f49672439a444e8cdb4db03bbe3adc47060c3425bd21bf7a83d7157958704c sha384=c5072b498bee74acd94277802dd713ae773d66f382cbf56a8d95bf31cef905ad9dbdb092adedab8cf91cfd416909d48d sha512=fef22cfb70d481bbc63bf3bbc1eca5d97300957598b599277d651558523cbf2d938bde5eb148e70320cdeae2f3dded9634a67487ee08a64a3e0a5d3e47780d8b flags=none
    ./xkb/rules/evdev.xml type=file uname=bmc gname=bmc mode=0600 nlink=1 size=565 time=1781922586.639935709 cksum=1593295626 md5=42877913d6f33799c8ebc642fdcead51 rmd160=7a1968430732aabd6a567def4041456f5006531e sha1=dfdcd19c787f4e29ca812d0a8c15a89eb0685036 sha256=707a151c39874ee997800ca710999b9067a2857833aa612cea3f7915ff0bff91 sha384=29a7b21e85bf183f318b0497113ba30bf61e8bca0f9c71818a2173da839d6e8c46b0d8e190e048104daa5a9e865ccd5f sha512=9f5d0c6826d1763612ce5a6c7f0c68bb175c0819fad931af105d7288d4e5c8b0f4c3e8d1e36891db8a043b360de668014644a7bebf7dcfda07af4fc16cb39ba2 flags=none
    ./xkb/symbols type=dir uname=bmc gname=bmc mode=0700 nlink=1 time=1781922575.961445868 flags=none
    ./xkb/symbols/bmc type=file uname=bmc gname=bmc mode=0600 nlink=1 size=681 time=1781922586.639575853 cksum=3870813416 md5=68e9529854e0c025473b0b15c999f983 rmd160=f0b8d63c08296e0f05be5f35e339e5fe662fc967 sha1=d8009becf88d03d80818d3e6a8219b41253453d0 sha256=337ecfd6407eb13dea03a843b5b0673bfad032f9e6fe27e62207d119fcca2200 sha384=a6619bb05b0ce969f00fdc0198cb2365ef8135f0acca79c1a82140bcd316edc9b1aaf2a6fd127161262484088c1b8f9d sha512=1fdfdcb3dfd61a24a856bb195f9d3a9d7869f609c687227acefe4633d421cbce26e4c2b7bda18ff8cf85b50c766bac8434729f5346dca645341c450577a27bae flags=none
    ./xkb/types type=dir uname=bmc gname=bmc mode=0700 nlink=1 time=1781922575.961445868 flags=none
    ./zsh type=dir uname=bmc gname=bmc mode=0700 nlink=1 time=1781922575.965468969 flags=none
    ./zsh/editors type=file uname=bmc gname=bmc mode=0600 nlink=1 size=1950 time=1781922586.640623682 cksum=1180611980 md5=dc79cd50f023a0f4f380ca2405f51f24 rmd160=bfbb032485dd5238e5698d2df49e24eb3a71ff29 sha1=c2dcd9ae185eaf95c4553cd6869640e64ee5e205 sha256=097bc8d35d65e8f585927720472b2797304c7ebf6d0f054a818bc10305120b78 sha384=8a077513294d1c981755bbdc5f555205a922ddcd7e3279991a542104a229756a37ba2646c3bcbd6a51f5f84c4bbf8b97 sha512=9760e4cb780d1d55f23972083fed6db4d606cf64d83b2e71541dbea5e2694ec0acf7cb24467f7e1444a3f19f43aa3a020f195606a74e72ced91060f8d115fb02 flags=none
    ./zsh/zlogout type=file uname=bmc gname=bmc mode=0600 nlink=1 size=206 time=1781922586.641137217 cksum=982024255 md5=1b6d95368c17c76771a8621817b23c13 rmd160=c26971923b4f1d8b4a8ba54e4871bf1cce27af0e sha1=d4bfda00d0d64f415140ad031b87164b1276a49d sha256=8444dcfad1c73653f47d34db26611d3ff8bac9b2de39072105db3fba5fec820e sha384=0e7c1fd0f8036452f675274a6884407dee5de0c4d7169f5e4b6ef46ffed985cb0a903df4b289ba9c66e3fe122d797b44 sha512=e0e801671bc2e2c75bb13b894fc88b6bfb4f46c3a16c22ca9f5e0595903dfe67827101d5f996c09a34f805ddf0955ac4277808e32df9f74d11402bb692add8df flags=none
    ./zsh/zprofile type=file uname=bmc gname=bmc mode=0600 nlink=1 size=295 time=1781922586.641283271 cksum=3483402022 md5=49ef4776601fbc8599a0519073396b63 rmd160=284ef4a010f2930b01b0f796682a013b88884e5f sha1=1e9a3d4032c054415e28957874f98ecf702a1307 sha256=b76312d52fb528d294c0ea8459a07880059d0f0af3d2ae418f2d11f47236e65f sha384=d9eebd5b8dbf7f66300939dbd4c0bca19aa13abbde7e17fbcb3a59fa90df3804a576da948447f33fa5dafa5b3a0b5de3 sha512=a4bbcb08ee987465d2f9203df9d4ed88289d7c1813d49cd968d520ea74d6b769ea2132b30dee94ae40197a50c4b9980c1554815a017162f0c33a0198a5fe3e82 flags=none
    ./zsh/zshenv type=file uname=bmc gname=bmc mode=0600 nlink=1 size=8987 time=1781922586.640781889 cksum=3923260385 md5=11e9c14ddf3bb5f2028f9d1fba51085e rmd160=6085817dd9102718384988307386b2a69519b7b1 sha1=9b2c20d4df95682ab5bdb60660f5df48c0ea05fd sha256=99886bb04c9e7b17b642c0be833e47ce7c795e895c0ef64bf1a1e092c822df0f sha384=28423a19a5ce43b1ac9950f013eca43a8ee04d056d0e82e35a3a7e3da30c968908d44b7f8e3ce96f5dd3b2a1ba151a71 sha512=c48bff91eb3a3b32dd3b3e0df8d3e2500067d3b0440a0bfeb32b66da3db487022fe2651c38bdc56de5551677c8487a0d2d134c1fa8ade47f55749132175c394c flags=none
    ./zsh/zshenvlocal type=file uname=bmc gname=bmc mode=0600 nlink=1 size=129 time=1781922586.642894049 cksum=1315654377 md5=40f4bc3f1574b2ac74ead9e68157db95 rmd160=a0e3760e286aa5caadde176384b497827f58c1d8 sha1=e18898a1758ff5e01a1e289b6893a69aee5ea183 sha256=37c19828a10099c53986e5d385eb9b59c46ce929f6e9926cdccd26822b90b6cf sha384=024bb5cad7d286e5b6b3f7c1093a28a924e22359f056aab4ed7047c0ebca61e993068ccb6c743e0a6e6e3afb4ce87538 sha512=a2e9152db833ce3796bd2c63a6fd804763458af6a56aa3d1bc1a6feb4148be79fab72aa5b686b172311e8328ac3ae0c7226c554a0df5a8967f5429fcc826103b flags=none
    ./zsh/zshrc type=file uname=bmc gname=bmc mode=0600 nlink=1 size=9271 time=1781922586.640987115 cksum=3461762020 md5=7e220bbddb8ea720c481202e9cae2b0e rmd160=1fd36bf92bd8bb29dbf2f84bd909defcb38c9284 sha1=11dd432572c451d2d93e8e3782ae2257c1c453d7 sha256=73c5a637a2d8c12bec1c0be09356474c2a83c66ed634ddd1e68c4b13a67d80f7 sha384=7fccdaca9cc4a9564d1e6b312b7921b93d9a0d4b0901a49d692b33f478c84fbb421c63c39b56cbbae538f6b9dfc9fb36 sha512=f7ec61005415aa7411d7bbde0d44eb89244a41754052634ba04de1328177353538e9da516fc6c2c97be91147641a4bddf071ad509c67732ebce4e8327345ca5f flags=none
    ./zsh/functions type=dir uname=bmc gname=bmc mode=0700 nlink=1 time=1781922575.965436638 flags=none
    ./zsh/functions/bmc_palette type=file uname=bmc gname=bmc mode=0600 nlink=1 size=2373 time=1781922586.641461026 cksum=382594786 md5=460e77728cf006d150a585783084bd44 rmd160=8eadf044db050bbeaa560778ee2f553f36ebb9fb sha1=4c117ab75deefec1821315fd1465b4c8c3fc07fc sha256=7497b60a2814a9f994db7149647db82b7c3386b4838aa8061a75c85e7bbbd8af sha384=77a8aa141ea5d338571f5b5f6b0735aff278d30ec791ffd40f4f0b413f8f543c1463d3e508c0f1d3b25f06efcc951a8d sha512=0e53b7c3c8144fd8a0fbdda1116f55f253e4d5a262e4f2943cc6e88f010da0dbc19996cad0c789623a2560a0cbcf42f1fea2472244621d84ea0889185bc1fd51 flags=none
    ./zsh/functions/bmc_palette_ansi type=file uname=bmc gname=bmc mode=0600 nlink=1 size=340 time=1781922586.641489259 cksum=3633915147 md5=a0adf2dd0bfc556f8596fdb1020a38fb rmd160=b5ea3d0f9e7cab207131c8e28576cf4e4f6fd166 sha1=325029a5eb625dc43c442ae0a13df81565567356 sha256=cf86d42719375ce8c4ed4532d1e04b95b8018b32691359417e74e669ed723e81 sha384=af912efe5e9069541a3543a9095d8b201d12c9e88c0b2f24261d1d6942e048d40b7dbacc0ba5bc78202536852f65f9d0 sha512=8b7922d303813ab2dcb99a5f9f1202929cfac0c2625239dde27daae948c84c95ddc25e5a9ebdfd5c27284627e355a09083b87c5c3f2c1eea8a03c7b1bc78a389 flags=none
    ./zsh/functions/color_bg type=file uname=bmc gname=bmc mode=0600 nlink=1 size=1263 time=1781922586.641512773 cksum=694624075 md5=0494e5efefa6c03547710a75ecb4cd79 rmd160=ad960f359b13b9319efad827a4234d9e8b1a61e1 sha1=46798cd7f54671b80c0c6e40253993027848a367 sha256=8eb9dcb597896aab51e89d66721f6ac4e3b466cc616c83766ac3b68aded5cf76 sha384=76264e67b43bbd01bad773605a8af65bbb403ba4e7c8041d76ee9bf975e7f8cc891dd62222d089c1759ff324effaaa15 sha512=cd8e2eace3bdb46b594ad02ad24df82cfb515b5358795011ca63ffcac87ac1d5627ea2aba67cd1888d37fabc240a226e9077361471f22ea802f8298509f3287d flags=none
    ./zsh/functions/color_count_for type=file uname=bmc gname=bmc mode=0600 nlink=1 size=753 time=1781922586.641539142 cksum=3073800257 md5=8ecbb4d0784bd5f97af3d0ab0afe2474 rmd160=343520dc14a27dc5e74abbae57994f971ff0cb4d sha1=209b0544d250dab7eb3f916746888ff23cc2e9b9 sha256=cb2079cd43c7b8a4d883c7929ed786bb045350b89f7f3840b7ce1e1b32965cf7 sha384=098f69642de0f6be8a876b75fe77749b629d622c8461a35ce8e9ca19f2434bd7401a6317b733f8048e17371db3eddb70 sha512=d524dea324c8e63ce1739ddad44d81698f8dd1a114e5bd08a6865b081873e2bb4ea40a67178f8bb6bd0b6e2babc5468d710b8a2b907be03aad8357066a5cd135 flags=none
    ./zsh/functions/color_fg type=file uname=bmc gname=bmc mode=0600 nlink=1 size=1263 time=1781922586.641562306 cksum=809388496 md5=a77e5fa911693ec12481d129fe38b232 rmd160=5a8de78ae443da3c5d0976dd2a4a9eb5e73f15a3 sha1=7331fd0e0a3db9f7212ac16896b64574b69f40e9 sha256=a95c9921af58b434fbeeeb883a179b5de09c30d6e16dc1f71680323d0ed14faa sha384=d7022169c28af893e63db419d598e4187c42924bc984e1ae8ab3c9a5fd4f26d0a1d4a936a920bc7698fa368d37256d21 sha512=b1981fca480fbc36fc9ef9126920da07df8b1f4bb6cf8d806c4b78829e9a7872e0fae33d06d15e4778218c0bc19b7990dc6fe0ac3ef35c6a339a576f28fc131b flags=none
    ./zsh/functions/color_fg_ansi type=file uname=bmc gname=bmc mode=0600 nlink=1 size=305 time=1781922586.641589096 cksum=144891780 md5=d1b06e00c8c4452ff55a296db2ce738e rmd160=aff301143010158cdff15690a8d0c751901a2d75 sha1=29c1b09b787255a122a1a03c69afcfd522caf7f2 sha256=d9e254060400254baff50bc0809c11e472207bb4f36effa8ea8247ffe3cce21d sha384=1002a315df27550d3005ce088293f368ce0ea2ded341029da46caebe4ddb1222899cda4340fb8575908a7be593dfa05f sha512=283bd3a78827f2e13645ac09de6beb695d6fb73c6d79ddf10c24bbadca319a6c6cd51d462f331aec97ecdb4063cd73577a7993d648ef3b56e84b1a267cb85b15 flags=none
    ./zsh/functions/color_reset type=file uname=bmc gname=bmc mode=0600 nlink=1 size=124 time=1781922586.641612029 cksum=1170187585 md5=632ac391da120885fbcf3f772005ae66 rmd160=84c917386266dde087c572abbcb0a52c42b3cca6 sha1=94d0acfd1d1f4232fd91365ff1ec2f2dcaa8b9a5 sha256=94d17328f0b998b44d1d9b8054f72cbb594330c6ecf6b178cdd11d9bbcf51e14 sha384=df23ece8fd0f97abc9447a7fef927750f497980839062a64356d7a03750e643ac9bf19926e6a7d54b92ffccfb999e3d6 sha512=947ab55b0867601f232f9820ed7f371575fdb145690e060c5cc46cb0593a6ed25b84f26b9e8f84ff2518cb6201aaefd1c28746ddac087d8e8b0036ed52d78b50 flags=none
    ./zsh/functions/prompt_bmc_setup type=file uname=bmc gname=bmc mode=0600 nlink=1 size=5984 time=1781922586.641636435 cksum=490608105 md5=ccdfc96e053bf025327e736813501e7e rmd160=cc20d6b68a069d72dc6dcc5eb69244dffd643562 sha1=5473908ea13e55124a56741a39e7a9c67e30106b sha256=ec78026ed4610ea6315d1095f67323fc71c370344592b69a161b90c45dab2212 sha384=595f2d70ca23b0859334db5c82e75e557d7d1f8d9ae78d6f2da57153d1268a7400b2ebcb323b7295c99f559acffdb2c0 sha512=764484d856e53b5c6f6317d3957e03e06af88b131cbfea9b2e6bdf8070fafc55e78228b2564f339aa6336ceabab7a3a63a7582d5e0067fa358f10cb972d6641c flags=none
    ./zsh/functions/set_keybindings type=file uname=bmc gname=bmc mode=0600 nlink=1 size=2502 time=1781922586.641669537 cksum=846717864 md5=3cfedc9aa6539ce567b1b7215140630b rmd160=ecf1a2a4d2c82396cbd28137dd796cf9d4bb0667 sha1=ea507e3d72d1ecf957c31522ef91681012ac0f12 sha256=b7ebfb34b0cda816bc11fbd04713d0593917c0ce80d12f19ddc07a39916a1078 sha384=ab460e73872a224b8a7dce946348bea6b80d8101dae4a05e6074afe3abfdf8ff2c3f7734cb9330539055be11ee8aec36 sha512=099db60792669360674a4824c403d6990eb7a7608d2387ac56a206734c8c1a35d7ef1d5bd051b500ebaa325df879fe78fefc2420e22ffab3b0e696ba5c435661 flags=none
    ./zsh/functions/setup_completion type=file uname=bmc gname=bmc mode=0600 nlink=1 size=6066 time=1781922586.641705194 cksum=441958056 md5=cfc72b8785759774def313ba868aa02f rmd160=2a2e9577d156234c57c44f92df3ea97bf9c856d5 sha1=c9024ab255ae1aca241798d35a9a226cf3037082 sha256=b7e8ea74dc2b1efa54f4fe09d4aadc1ebd0e412d9859847b90e8408c7111bc2c sha384=ccbdc260fe0454d58926e479699e81eab7d3e03825661133619b5d0165a6c74090ceffa0776ce0eb2cf7161f602387a5 sha512=7a423a72312ab0f78e1ace31b0bfa64f8e9bc754108117da77b66c51e90cef1b88d21d9cf290eb0c24fd722b4fb59bb18b6d4539b3a4204762edb4159c2b284f flags=none
    EOF

    it 'should format files correctly' do
      expect(@dir.stream([@mtree, '--backend=ruby', '--format'], DEFAULT, chdir: @tempdir)).to eq EXPECTED
    end

    it 'should round-trip formatted files correctly' do
      expect(@dir.stream([@mtree, '--backend=ruby', '--format'], EXPECTED, chdir: @tempdir)).to eq EXPECTED
    end
  end
end
