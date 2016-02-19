require_relative 'nodes/list_command'
require_relative 'nodes/remove_command'
require_relative 'nodes/show_command'
require_relative 'nodes/update_command'
require_relative 'nodes/ssh_command'

require_relative 'nodes/add_label_command'
require_relative 'nodes/remove_label_command'

require_relative 'nodes/vagrant_command'
require_relative 'nodes/digital_ocean_command'
require_relative 'nodes/aws_command'
require_relative 'nodes/azure_command'

class Kontena::Cli::NodeCommand < Clamp::Command

  subcommand "list", "List grid nodes", Kontena::Cli::Nodes::ListCommand
  subcommand "show", "Show node", Kontena::Cli::Nodes::ShowCommand
  subcommand "ssh", "Ssh into node", Kontena::Cli::Nodes::SshCommand
  subcommand "update", "Update node", Kontena::Cli::Nodes::UpdateCommand
  subcommand ["remove","rm"], "Remove node", Kontena::Cli::Nodes::RemoveCommand

  subcommand "add-label", "Add label to node", Kontena::Cli::Nodes::AddLabelCommand
  subcommand "remove-label", "Remove label from node", Kontena::Cli::Nodes::RemoveLabelCommand

  subcommand "vagrant", "Vagrant specific commands", Kontena::Cli::Nodes::VagrantCommand
  subcommand "digitalocean", "DigitalOcean specific commands", Kontena::Cli::Nodes::DigitalOceanCommand
  subcommand "aws", "AWS specific commands", Kontena::Cli::Nodes::AwsCommand
  subcommand "azure", "Azure specific commands", Kontena::Cli::Nodes::AzureCommand

  def execute
  end
end
