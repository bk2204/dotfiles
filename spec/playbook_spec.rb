require_relative 'spec_helper'

describe :playbooks do
  context 'docker' do
    before(:each) do
      skip "No docker image set" unless TestConfig.docker_tests?
      @img = TestDockerImage.new(TestConfig.docker_image)
    end

    it 'should bootstrap and deploy dotfiles correctly' do
      @img.run
      expect(@img.setup).to be true
      expect(@img.exec("DEBIAN_FRONTEND=noninteractive apt-get update")).to be true
      expect(@img.exec("DEBIAN_FRONTEND=noninteractive apt-get install -y git gnupg ansible")).to be true
      expect(@img.exec("ansible-playbook -v -i localhost, --connection=local playbooks/bootstrap.yaml")).to be true
      expect(@img.exec("ansible-playbook -v -i localhost, --connection=local -e '{\"private_dotfiles\":false}' playbooks/deploy-dotfiles.yaml")).to be true
    end

    it 'should bootstrap and deploy dotfiles correctly in a non-graphical development environment' do
      @img.run
      expect(@img.setup).to be true
      expect(@img.exec("DEBIAN_FRONTEND=noninteractive apt-get update")).to be true
      expect(@img.exec("DEBIAN_FRONTEND=noninteractive apt-get install -y git gnupg ansible")).to be true
      expect(@img.exec("ansible-playbook -v -i localhost, --connection=local -e '{\"development\":true,\"graphical\":false}' playbooks/bootstrap.yaml")).to be true
      expect(@img.exec("ansible-playbook -v -i localhost, --connection=local -e '{\"private_dotfiles\":false}' playbooks/deploy-dotfiles.yaml")).to be true
    end

    it 'should bootstrap and deploy dotfiles correctly in a graphical development environment' do
      skip if ENV['DOCKER_IMAGE'] == 'ubuntu:focal' || ENV['DOCKER_IMAGE'] == 'ubuntu:jammy'
      @img.run
      expect(@img.setup).to be true
      expect(@img.exec("DEBIAN_FRONTEND=noninteractive apt-get update")).to be true
      expect(@img.exec("DEBIAN_FRONTEND=noninteractive apt-get install -y git gnupg ansible")).to be true
      expect(@img.exec("ansible-playbook -v -i localhost, --connection=local -e '{\"development\":true,\"graphical\":true}' playbooks/bootstrap.yaml")).to be true
      expect(@img.exec("ansible-playbook -v -i localhost, --connection=local -e '{\"private_dotfiles\":false}' playbooks/deploy-dotfiles.yaml")).to be true
    end

    it 'should bootstrap and deploy dotfiles correctly in a graphical development environment with Homebrew' do
      skip if %w[ubuntu:focal ubuntu:jammy debian:bookworm].include?(ENV['DOCKER_IMAGE'])
      @img.run
      expect(@img.setup).to be true
      expect(@img.exec("DEBIAN_FRONTEND=noninteractive apt-get update")).to be true
      expect(@img.exec("DEBIAN_FRONTEND=noninteractive apt-get install -y git curl gnupg ansible")).to be true
      expect(@img.exec("ansible-playbook -v -i localhost, --connection=local -e '{\"development\":true,\"graphical\":true,\"homebrew\":true}' playbooks/bootstrap.yaml")).to be true
      expect(@img.exec("ansible-playbook -v -i localhost, --connection=local -e '{\"private_dotfiles\":false}' playbooks/deploy-dotfiles.yaml")).to be true
    end

    it 'should bootstrap a Codespace correctly' do
      @img.run
      expect(@img.setup).to be true
      expect(@img.exec("DEBIAN_FRONTEND=noninteractive apt-get update")).to be true
      expect(@img.exec("DEBIAN_FRONTEND=noninteractive apt-get install -y git curl gnupg ansible")).to be true
      expect(@img.exec("ansible-playbook -v -i localhost, --connection=local -e '{\"private_dotfiles\":false}' playbooks/codespace-setup.yaml")).to be true
    end

    it 'should deploy dotfiles correctly without bootstrapping' do
      @img.run
      expect(@img.setup).to be true
      expect(@img.exec("DEBIAN_FRONTEND=noninteractive apt-get update")).to be true
      expect(@img.exec("DEBIAN_FRONTEND=noninteractive apt-get install -y git make gnupg ansible")).to be true
      expect(@img.exec("ansible-playbook -v -i localhost, --connection=local -e '{\"private_dotfiles\":false}' playbooks/deploy-dotfiles.yaml")).to be true
    end
  end
end
