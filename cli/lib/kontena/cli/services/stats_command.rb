require_relative 'services_helper'

module Kontena::Cli::Services
  class StatsCommand < Clamp::Command
    include Kontena::Cli::Common
    include ServicesHelper

    parameter "NAME", "Service name"
    option ["-f", "--follow"], :flag, "Follow stats in real time", default: false

    def execute
      require_api_url
      token = require_token
      if follow?
        system('clear')
        render_header
      end
      loop do
        fetch_stats(token, name, follow?)
        break unless follow?
        sleep(2)
      end
    end

    private

    def fetch_stats(token, service_id, follow)
      result = client(token).get("services/#{current_grid}/#{service_id}/stats")
      system('clear') if follow
      render_header
      result['stats'].each do |stat|
        render_stat_row(stat)
      end
    end

    def render_header
      puts '%-30.30s %-15s %-20s %-15s %-15s' % ['CONTAINER', 'CPU %', 'MEM USAGE/LIMIT', 'MEM %', 'NET I/O']
    end

    def render_stat_row(stat)
      memory = stat['memory'].nil? ? 'N/A' : filesize_to_human(stat['memory']['usage'])
      if !stat['memory'].nil? && stat['memory']['limit'] != 1.8446744073709552e+19
        memory_limit = filesize_to_human(stat['memory']['limit'])
        memory_pct = "#{(stat['memory']['usage'].to_f / stat['memory']['limit'].to_f * 100).round(2)}%"
      else
        memory_limit = 'N/A'
        memory_pct = 'N/A'
      end

      cpu = stat['cpu'].nil? ? 'N/A' : stat['cpu']['usage']
      network_in = stat['network'].nil? ? 'N/A' : filesize_to_human(stat['network']['rx_bytes'])
      network_out = stat['network'].nil? ? 'N/A' : filesize_to_human(stat['network']['tx_bytes'])
      puts '%-30.30s %-15s %-20s %-15s %-15s' % [ stat['container_id'], "#{cpu}%", "#{memory} / #{memory_limit}", "#{memory_pct}", "#{network_in}/#{network_out}"]
    end

    ##
    # @param [Integer] size
    # @return [String]
    def filesize_to_human(size)
      units = %w{B K M G T}
      e = (Math.log(size) / Math.log(1000)).floor
      s = '%.2f' % (size.to_f / 1000**e)
      s.sub(/\.?0*$/, units[e])
    rescue FloatDomainError
      'N/A'
    end
  end
end
