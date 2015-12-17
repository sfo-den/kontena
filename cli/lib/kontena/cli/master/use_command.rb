module Kontena::Cli::Master
  class UseCommand < Clamp::Command
    include Kontena::Cli::Common

    parameter "NAME", "Master name to use"

    def execute
      master = find_master_by_name(name)
      if !master.nil?
        self.current_master = master['name']
        puts "Using master: #{master['name'].cyan}"
        puts "URL: #{master['url'].cyan}"
      else
        abort "Could not resolve master by name [#{name}]. For a list of known masters please run: kontena master list".colorize(:red)
      end
    end

    def find_master_by_name(name)
      settings['servers'].each do |server|
        return server if server['name'] == name
      end
    end

  end

end
