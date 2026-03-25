require_relative 'spec_helper'
require 'fileutils'
require 'securerandom'

describe :desktop do
  before(:all) do
    @dir = TestDir.new
    @cmd = File.join(@dir.tempdir, ".local", "lib", "dct-snip", "snippets", "kprocessconfig")
  end

  before(:each) do
    @tempdir = File.join(@dir.tempdir, SecureRandom.alphanumeric(20))
    Dir.mkdir @tempdir
  end

  context 'kde config generation' do
    it 'should process an expected config file' do
      input = <<~EOF
      ---
      files:
          kwinrc:
              groups:
                  Desktops:
                      Number: 5
                      Rows: 1
                  Windows:
                      AutoRaise: true
                      ClickRaise: false
                      FocusPolicy: FocusFollowsMouse
                      FocusStealingPreventionLevel: 0
      EOF
      output = <<~EOF
      Running --file TEMPDIR/.config/kwinrc --group Desktops --key Number 5
      Running --file TEMPDIR/.config/kwinrc --group Desktops --key Rows 1
      Running --file TEMPDIR/.config/kwinrc --group Windows --key AutoRaise true
      Running --file TEMPDIR/.config/kwinrc --group Windows --key ClickRaise false
      Running --file TEMPDIR/.config/kwinrc --group Windows --key FocusPolicy FocusFollowsMouse
      Running --file TEMPDIR/.config/kwinrc --group Windows --key FocusStealingPreventionLevel 0
      EOF
      filename = File.join(@tempdir, "foo.yaml")
      File.write(filename, input)
      expected = output.gsub(/TEMPDIR/, @dir.tempdir)
      expect(@dir.stream([@cmd, '--file', filename, '--dry-run', '--verbose'], '', err: [:child, :out])).to eq expected
    end
  end
end
