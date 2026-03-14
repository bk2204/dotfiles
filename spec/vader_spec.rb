require_relative 'spec_helper'

describe :vader do
  context 'vader tests' do
    def runtimepath(command)
      rtp = nil
      IO.popen([command, '-es', '+put=$VIMRUNTIME|print|quit!'], :in => "/dev/null") do |io|
        rtp = io.read
      end
      rtp.rstrip
    end

    it 'should pass all the Vader tests successfully correctly with Neovim' do
      rtp = "#{runtimepath('nvim')},#{File.absolute_path("vim")}"
      expect(status(['nvim', '-es', '-u', 'vim/vimrc', '-i', 'NONE', '--cmd', %Q[set rtp=#{rtp}], '-c' 'Vader! vim/vader/*.vader'], "TERM" => "dumb")).to eq 0
    end

    it 'should pass all the Vader tests successfully correctly with Vim' do
      rtp = "#{runtimepath('vim')},#{File.absolute_path("vim")}"
      expect(status(['vim', '-es', '-u', 'vim/vimrc', '-i', 'NONE', '--cmd', %Q[set rtp=#{rtp}], '-c' 'Vader! vim/vader/*.vader'], "TERM" => "dumb")).to eq 0
    end
  end
end
