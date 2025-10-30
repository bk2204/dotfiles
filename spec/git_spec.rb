require_relative 'spec_helper'

describe :git do
  context 'gitconfig' do
    def main_config
      return @main_config if @main_config
      @main_config = File.read(File.join(@dir.tempdir, 'src', 'git', 'gitconfig'))
    end

    def complete_config(val)
      val + main_config
    end

    it 'should generate expected values for config file with no values' do
      @dir = TestDir.new(config_yaml: "---\n{}\n")
      gitconfig = File.join(@dir.tempdir, ".config", "git", "config")
      actual = File.read(gitconfig)
      expect(actual).to eq complete_config("")
    end

    it 'should generate expected values for OpenPGP signing and libsecret' do
      # Fake OpenPGP fingerprint is created from the SHA-256 initial values and
      # the SSH key is GitHub's.
      yaml = <<~EOM
      ---
      git:
          credential-helper: libsecret
          sign-commits: gpg
      gpg:
          key: 6A09E667BB67AE853C6EF372A54FF53A510E527F
      ssh:
          key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"
      EOM
      @dir = TestDir.new(config_yaml: yaml)
      gitconfig = File.join(@dir.tempdir, ".config", "git", "config")
      actual = File.read(gitconfig)
      expected = <<~EOM
      [commit]
          gpgsign = true
      [credential]
          helper = "libsecret"
      [gpg]
          format = openpgp
          program = gpg
      [user]
          signingkey = "6A09E667BB67AE853C6EF372A54FF53A510E527F!"
      EOM
      expect(actual).to eq complete_config(expected)
    end

    it 'should generate expected values for OpenPGP signing with gpg-sq' do
      # Fake OpenPGP fingerprint is created from the SHA-256 initial values and
      # the SSH key is GitHub's.
      yaml = <<~EOM
      ---
      git:
          credential-helper: libsecret
          sign-commits: gpg-sq
      gpg:
          key: 6A09E667BB67AE853C6EF372A54FF53A510E527F
      ssh:
          key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"
      EOM
      @dir = TestDir.new(config_yaml: yaml)
      gitconfig = File.join(@dir.tempdir, ".config", "git", "config")
      actual = File.read(gitconfig)
      expected = <<~EOM
      [commit]
          gpgsign = true
      [credential]
          helper = "libsecret"
      [gpg]
          format = openpgp
          program = gpg-sq
      [user]
          signingkey = "6A09E667BB67AE853C6EF372A54FF53A510E527F!"
      EOM
      expect(actual).to eq complete_config(expected)
    end

    it 'should generate expected values for SSH signing and osxkeychain' do
      yaml = <<~EOM
      ---
      git:
          credential-helper: osxkeychain
          sign-commits: ssh
      gpg:
          key: 6A09E667BB67AE853C6EF372A54FF53A510E527F
      ssh:
          key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"
      EOM
      @dir = TestDir.new(config_yaml: yaml)
      gitconfig = File.join(@dir.tempdir, ".config", "git", "config")
      actual = File.read(gitconfig)
      expected = <<~EOM
      [commit]
          gpgsign = true
      [credential]
          helper = "osxkeychain"
      [gpg]
          format = ssh
      [user]
          signingkey = "key::ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"
      EOM
      expect(actual).to eq complete_config(expected)
    end
  end
end
