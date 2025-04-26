require_relative 'spec_helper'

describe :bootstrap do
  context 'docker' do
    before(:all) do
      skip 'No docker image set' unless TestConfig.docker_tests?
      @img = TestDockerImage.new(TestConfig.docker_image)
    end

    it 'should bootstrap with minimal dependencies correctly' do
      @img.run
      expect(@img.setup).to be true
      expect(@img.exec('DEBIAN_FRONTEND=noninteractive apt-get update')).to be true
      expect(@img.exec('DEBIAN_FRONTEND=noninteractive apt-get install -y make git')).to be true
      expect(@img.exec('rm -f rules-overlay.mk')).to be true
      expect(@img.exec('make clean')).to be true
      expect(@img.exec('make install')).to be true
    end
  end
end
