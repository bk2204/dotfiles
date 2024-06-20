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
  bar type=dir mode=0755 dest=barbaz recurse=true filemode=0640 dirmode=0750
  baz type=dir mode=0755 dest=foobar

  # This is a comment.
  #
  # More comment.
  file4 type=file mode=0664
  foo type=dir mode=0755
  EOF

  SAMPLE2 = <<~EOF
  bar type=dir mode=0755 dest=barbaz recurse=true filemode=0640+x dirmode=0750
  baz type=dir mode=0755 dest=foobar
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
end
