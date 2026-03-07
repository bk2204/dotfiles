require_relative 'spec_helper'

describe :vader do
  context 'vader tests' do
    it 'should pass all the Vader tests successfully correctly with Neovim' do
      expect(status(['nvim', '-es', '-u', 'vim/vimrc', '-i', 'NONE', '-c' 'Vader! vim/vader/*.vader'], "TERM" => "dumb")).to eq 0
    end

    it 'should pass all the Vader tests successfully correctly with Vim' do
      expect(status(['vim', '-es', '-u', 'vim/vimrc', '-i', 'NONE', '-c' 'Vader! vim/vader/*.vader'], "TERM" => "dumb")).to eq 0
    end
  end
end
