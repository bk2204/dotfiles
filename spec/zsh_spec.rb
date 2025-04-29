require_relative 'spec_helper'

describe :zsh do
  before(:all) do
    @dir = TestDir.new
  end

  context 'editor' do
    it 'should set EDITOR to nvim-gtk with DISPLAY' do
      @dir = TestDir.new
      exes = %w[lawn nvim-gtk gvim mvim ex nvim vimx vim vi]
      expect(@dir.cmd_with_exes(exes, ['zsh', '-c', 'echo $EDITOR'], 'DISPLAY' => 'something')).to eq "nvim-gtk --no-fork --\n"
    end

    it 'should set VISUAL to nvim-gtk with DISPLAY' do
      @dir = TestDir.new
      exes = %w[lawn nvim-gtk gvim mvim ex nvim vimx vim vi]
      expect(@dir.cmd_with_exes(exes, ['zsh', '-c', 'echo $VISUAL'], 'DISPLAY' => 'something')).to eq "nvim-gtk --no-fork --\n"
    end

    it 'should set set detachable editor to nvim-gtk with DISPLAY' do
      @dir = TestDir.new
      exes = %w[lawn nvim-gtk gvim mvim ex nvim vimx vim vi]
      expect(@dir.cmd_with_exes(exes, ['zsh', '-c', 'bmc_editor --detach --no-fallback'], 'DISPLAY' => 'something')).to eq "nvim-gtk --"
    end

    it 'should set EDITOR to lawn with REMOTE_ENV' do
      @dir = TestDir.new
      exes = %w[lawn nvim-gtk gvim mvim ex nvim vimx vim vi]
      expect(@dir.cmd_with_exes(exes, ['zsh', '-c', 'echo $EDITOR'], 'REMOTE_ENV' => 'something')).to eq "lawn run -- gvi --no-fork\n"
    end

    it 'should set VISUAL to lawn with REMOTE_ENV' do
      @dir = TestDir.new
      exes = %w[lawn nvim-gtk gvim mvim ex nvim vimx vim vi]
      expect(@dir.cmd_with_exes(exes, ['zsh', '-c', 'echo $VISUAL'], 'REMOTE_ENV' => 'something')).to eq "lawn run -- gvi --no-fork\n"
    end

    it 'should set set detachable editor to lawn with REMOTE_ENV' do
      @dir = TestDir.new
      exes = %w[lawn nvim-gtk gvim mvim ex nvim vimx vim vi]
      expect(@dir.cmd_with_exes(exes, ['zsh', '-c', 'bmc_editor --detach --no-fallback'], 'REMOTE_ENV' => 'something')).to eq "lawn run -- gvi"
    end

    it 'should set BROWSER to lawn with REMOTE_ENV' do
      @dir = TestDir.new
      exes = %w[lawn nvim-gtk gvim mvim ex nvim vimx vim vi]
      expect(@dir.cmd_with_exes(exes, ['zsh', '-c', 'echo $BROWSER'], 'REMOTE_ENV' => 'something')).to eq "dct-browser\n"
    end

    it 'should prefer gvim with DISPLAY and no nvim-gtk' do
      @dir = TestDir.new
      exes = %w[gvim mvim ex nvim vimx vim vi]
      expect(@dir.cmd_with_exes(exes, ['zsh', '-c', 'echo $VISUAL; echo $EDITOR; bmc_editor --detach --no-fallback'], 'DISPLAY' => 'something')).to eq "gvim -f\ngvim -f\ngvim"
    end

    it 'should set EDITOR to nex with non-empty TERM' do
      @dir = TestDir.new
      exes = %w[nvim-gtk gvim mvim nex ex nvim vimx vim vi]
      expect(@dir.cmd_with_exes(exes, ['zsh', '-c', 'echo $EDITOR'], 'TERM' => 'xterm-256color')).to eq "nex\n"
    end

    it 'should set EDITOR to ex with non-empty TERM' do
      @dir = TestDir.new
      exes = %w[nvim-gtk gvim mvim ex nvim vimx vim vi]
      expect(@dir.cmd_with_exes(exes, ['zsh', '-c', 'echo $EDITOR'], 'TERM' => 'xterm-256color')).to eq "ex\n"
    end

    it 'should set VISUAL to nvim with non-empty TERM' do
      @dir = TestDir.new
      exes = %w[nvim-gtk gvim mvim ex nvim vimx vim vi]
      expect(@dir.cmd_with_exes(exes, ['zsh', '-c', 'echo $VISUAL'], 'TERM' => 'xterm-256color')).to eq "nvim\n"
    end

    it 'should not pick a detachable editor with no display' do
      @dir = TestDir.new
      exes = %w[nvim-gtk gvim ex nvim vimx vim vi]
      expect(@dir.cmd_with_exes(exes, ['zsh', '-c', 'bmc_editor --detach --no-fallback'], 'TERM' => 'xterm-256color')).to eq ""
    end

    it 'should set VISUAL to nvim with DISPLAY, non-empty TERM, and no graphical editors' do
      @dir = TestDir.new
      exes = %w[ex nvim vimx vim vi]
      expect(@dir.cmd_with_exes(exes, ['zsh', '-c', 'echo $VISUAL'],
                                'DISPLAY' => 'something',
                                'TERM' => 'xterm-256color')).to eq "nvim\n"
    end

    it 'should set VISUAL to vim with non-empty TERM and no nvim or vimx' do
      @dir = TestDir.new
      exes = %w[gvim mvim ex vim vi]
      expect(@dir.cmd_with_exes(exes, ['zsh', '-c', 'echo $VISUAL'], 'TERM' => 'xterm-256color')).to eq "vim\n"
    end

    it 'should set EDITOR to nex with SSH session and terminal multiplexor' do
      expect(@dir.cmd(['zsh', '-c', 'source .zshrc; echo $EDITOR'],
                      'DISPLAY' => 'something',
                      'SSH_TTY' => 'tty',
                      'TERM' => 'screen-256color')).to eq "nex\n"
    end

    it 'should set VISUAL to vim with SSH session and terminal multiplexor' do
      expect(@dir.cmd(['zsh', '-c', 'source .zshrc; echo $VISUAL'],
                      'DISPLAY' => 'something',
                      'SSH_TTY' => 'tty',
                      'TERM' => 'screen-256color')).to eq "nvim\n"
    end

    it 'should set EDITOR to nex with TERM=dumb' do
      @dir = TestDir.new
      exes = %w[gvim mvim nex ex vim vi]
      expect(@dir.cmd_with_exes(exes, ['zsh', '-c', 'echo $EDITOR'], 'TERM' => 'dumb')).to eq "nex\n"
    end

    it 'should set EDITOR to ex with TERM=dumb' do
      @dir = TestDir.new
      exes = %w[gvim mvim ex vim vi]
      expect(@dir.cmd_with_exes(exes, ['zsh', '-c', 'echo $EDITOR'], 'TERM' => 'dumb')).to eq "ex\n"
    end

    it 'should set VISUAL to nex with TERM=dumb' do
      @dir = TestDir.new
      exes = %w[gvim mvim nex ex vim vi]
      expect(@dir.cmd_with_exes(exes, ['zsh', '-c', 'echo $VISUAL'], 'TERM' => 'dumb')).to eq "nex\n"
    end

    it 'should set VISUAL to ex with TERM=dumb' do
      @dir = TestDir.new
      exes = %w[gvim mvim ex vim vi]
      expect(@dir.cmd_with_exes(exes, ['zsh', '-c', 'echo $VISUAL'], 'TERM' => 'dumb')).to eq "ex\n"
    end

    it 'should set EDITOR to nex with no TERM' do
      @dir = TestDir.new
      exes = %w[gvim mvim nex ex vim vi]
      expect(@dir.cmd_with_exes(exes, ['zsh', '-c', 'echo $EDITOR'])).to eq "nex\n"
    end

    it 'should set EDITOR to ex with no TERM' do
      @dir = TestDir.new
      exes = %w[gvim mvim ex vim vi]
      expect(@dir.cmd_with_exes(exes, ['zsh', '-c', 'echo $EDITOR'])).to eq "ex\n"
    end

    it 'should set VISUAL to nex with no TERM' do
      @dir = TestDir.new
      exes = %w[gvim mvim nex ex vim vi]
      expect(@dir.cmd_with_exes(exes, ['zsh', '-c', 'echo $VISUAL'])).to eq "nex\n"
    end

    it 'should set VISUAL to ex with no TERM' do
      @dir = TestDir.new
      exes = %w[gvim mvim ex vim vi]
      expect(@dir.cmd_with_exes(exes, ['zsh', '-c', 'echo $VISUAL'])).to eq "ex\n"
    end
  end

  context 'prompt' do
    it 'should not print escape characters with a dumb terminal' do
      expect(@dir.cmd(['zsh', '-c', 'source .zshrc; echo $PS1'])).not_to match(/\x1b/)
      expect(@dir.cmd(['zsh', '-c', 'source .zshrc; echo $PS1'], 'TERM' => 'dumb')).not_to match(/\x1b/)
    end
  end

  context 'term' do
    it 'should set COLORTERM when using a -direct terminal type' do
      expect(@dir.cmd(['zsh', '-c', 'source .zshrc; echo $COLORTERM'], 'TERM' => 'xterm-direct')).to eq "truecolor\n"
      expect(@dir.cmd(['zsh', '-c', 'source .zshrc; echo $COLORTERM'], 'TERM' => 'tmux-direct')).to eq "truecolor\n"
    end
  end

  context 'path' do
    it 'should include external path components' do
      home = ENV['HOME']
      expect(@dir.cmd(['zsh', '-c', 'echo $PATH'],
                      'HOME' => home, 'PATH' => '/root/bin:/usr/games:/bin:/usr/bin')).to eq \
        "#{home}/bin:#{home}/.local/bin:/root/bin:#{home}/.rvm/bin:" \
        "#{home}/.cargo/bin:" \
        "/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:/usr/games\n"

      expect(@dir.cmd(['zsh', '-c', 'echo $PATH'],
                      'HOME' => home,
                      'PATH' => "/root/bin:#{home}/.cargo/bin:/nonexistent/bin:/opt/bin:/usr/local/bin:/nothere/bin:/bin:/usr/bin")).to eq \
        "#{home}/bin:#{home}/.local/bin:" \
        "/root/bin:#{home}/.rvm/bin:#{home}/.cargo/bin:" \
        '/nonexistent/bin:/opt/bin:/usr/local/bin:/usr/local/sbin:' \
        "/nothere/bin:/usr/bin:/usr/sbin:/bin:/sbin:/usr/games\n"

      expect(@dir.cmd(['zsh', '-c', 'echo $PATH'],
                      'HOME' => home,
                      'PATH' => "/root/bin:#{home}/.cargo/bin:/nonexistent/bin:/opt/bin:/usr/local/bin:/bin:/usr/bin:/nothere/bin")).to eq \
        "#{home}/bin:#{home}/.local/bin:" \
        "/root/bin:#{home}/.rvm/bin:#{home}/.cargo/bin:" \
        '/nonexistent/bin:/opt/bin:/usr/local/bin:/usr/local/sbin:' \
        "/usr/bin:/usr/sbin:/bin:/sbin:/usr/games:/nothere/bin\n"
    end
  end
end
