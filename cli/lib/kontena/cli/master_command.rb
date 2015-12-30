require_relative 'master/vagrant_command'
require_relative 'master/aws_command'
require_relative 'master/digital_ocean_command'
require_relative 'master/azure_command'
require_relative 'master/use_command'
require_relative 'master/list_command'

class Kontena::Cli::MasterCommand < Clamp::Command

  subcommand "vagrant", "Vagrant specific commands", Kontena::Cli::Master::VagrantCommand
  subcommand "aws", "AWS specific commands", Kontena::Cli::Master::AwsCommand
  subcommand "digitalocean", "DigitalOcean specific commands", Kontena::Cli::Master::DigitalOceanCommand
  subcommand "azure", "Azure specific commands", Kontena::Cli::Master::AzureCommand
  subcommand ["list", "ls"], "List masters where client has logged in", Kontena::Cli::Master::ListCommand
  subcommand "use", "Switch to use selected master", Kontena::Cli::Master::UseCommand

  def execute
  end
end
