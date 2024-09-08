require_relative 'spec_helper'

describe :playbooks do
  context 'docker' do
    before(:all) do
      skip "No docker image set" unless TestConfig.docker_tests?
      @img = TestDockerImage.new(TestConfig.docker_image)
    end

    it 'should bootstrap and deploy dotfiles correctly' do
      @img.run
      expect(@img.setup).to be true
      expect(@img.exec("DEBIAN_FRONTEND=noninteractive apt-get update")).to be true
      expect(@img.exec("DEBIAN_FRONTEND=noninteractive apt-get install -y git gnupg ansible")).to be true
      expect(@img.exec("ansible-playbook -i localhost, --connection=local playbooks/bootstrap.yaml")).to be true
      expect(@img.exec("ansible-playbook -i localhost, --connection=local playbooks/deploy-dotfiles.yaml")).to be true
    end
  end
end
