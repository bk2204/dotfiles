require_relative 'spec_helper'

describe :git do
  context 'kitty/conf.d/fonts.conf' do
    it 'should generate expected values for config file with no values' do
      @dir = TestDir.new(config_yaml: "---\n{}\n")
      config = File.join(@dir.tempdir, ".config", "kitty", "conf.d", "fonts.conf")
      actual = File.read(config)
      expect(actual).to eq ""
    end

    it 'should generate expected values for default value' do
      yaml = <<~EOM
      ---
      fonts:
          monospace:
              default:
                  family: Source Code Pro
                  size: 10
      EOM
      @dir = TestDir.new(config_yaml: yaml)
      config = File.join(@dir.tempdir, ".config", "kitty", "conf.d", "fonts.conf")
      actual = File.read(config)
      expected = <<~EOM
      font_family family="Source Code Pro"
      font_size 10
      EOM
      expect(actual).to eq expected
    end

    it 'should generate expected values for kitty-specific values' do
      yaml = <<~EOM
      ---
      fonts:
          monospace:
              kitty:
                  family: Source Code Pro
                  size: 10
      EOM
      @dir = TestDir.new(config_yaml: yaml)
      config = File.join(@dir.tempdir, ".config", "kitty", "conf.d", "fonts.conf")
      actual = File.read(config)
      expected = <<~EOM
      font_family family="Source Code Pro"
      font_size 10
      EOM
      expect(actual).to eq expected
    end

    it 'should generate expected values for conflicting values' do
      yaml = <<~EOM
      ---
      fonts:
          monospace:
              default:
                  family: Monaspace Neon
                  size: 11
              kitty:
                  family: Source Code Pro
                  size: 10
      EOM
      @dir = TestDir.new(config_yaml: yaml)
      config = File.join(@dir.tempdir, ".config", "kitty", "conf.d", "fonts.conf")
      actual = File.read(config)
      expected = <<~EOM
      font_family family="Source Code Pro"
      font_size 10
      EOM
      expect(actual).to eq expected
    end
  end
end
