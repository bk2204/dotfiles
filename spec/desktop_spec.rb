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
      Running kwriteconfig6 --file TEMPDIR/.config/kwinrc --group Desktops --key Number 5
      Running kwriteconfig6 --file TEMPDIR/.config/kwinrc --group Desktops --key Rows 1
      Running kwriteconfig6 --file TEMPDIR/.config/kwinrc --group Windows --key AutoRaise --type=bool true
      Running kwriteconfig6 --file TEMPDIR/.config/kwinrc --group Windows --key ClickRaise --type=bool false
      Running kwriteconfig6 --file TEMPDIR/.config/kwinrc --group Windows --key FocusPolicy FocusFollowsMouse
      Running kwriteconfig6 --file TEMPDIR/.config/kwinrc --group Windows --key FocusStealingPreventionLevel 0
      EOF
      filename = File.join(@tempdir, "foo.yaml")
      File.write(filename, input)
      expected = output.gsub(/TEMPDIR/, @dir.tempdir)
      expect(@dir.stream([@cmd, '--file', filename, '--dry-run', '--verbose'], '', err: [:child, :out])).to eq expected
    end
  end

  context 'macOS config generation' do
    it 'should process an expected config file' do
      input = <<~EOF
      ---
      domains:
          com.apple.menuextra.clock:
              keys:
                  ShowSeconds: true
          Apple Global Domain:
              keys:
                  AppleICUForce24HourTime: true
                  com.apple.sound.beep.sound: /System/Library/Sounds/Sosumi.aiff
      EOF
      output = <<~EOF
      Running defaults write com.apple.menuextra.clock ShowSeconds -bool TRUE
      Running defaults write Apple Global Domain AppleICUForce24HourTime -bool TRUE
      Running defaults write Apple Global Domain com.apple.sound.beep.sound /System/Library/Sounds/Sosumi.aiff
      EOF
      filename = File.join(@tempdir, "foo.yaml")
      File.write(filename, input)
      expected = output.gsub(/TEMPDIR/, @dir.tempdir)
      expect(@dir.stream([@cmd, '--desktop=macos', '--file', filename, '--dry-run', '--verbose'], '', err: [:child, :out])).to eq expected
    end
  end
end
