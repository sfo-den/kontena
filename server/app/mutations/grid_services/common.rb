module GridServices
  module Common

    ##
    # @param [Grid] grid
    # @param [Array<Hash>] links
    # @return [Array<GridServiceLink>]
    def build_grid_service_links(grid, links)
      grid_service_links = []
      links.each do |link|
        linked_service = grid.grid_services.find_by(name: link[:name])
        if linked_service
          grid_service_links << GridServiceLink.new(
              linked_grid_service: linked_service,
              alias: link[:alias]
          )
        end
      end
      grid_service_links
    end

    # @param [Array<GridServiceHook>] existing_hooks
    # @return [Array<GridServiceHook>]
    def build_grid_service_hooks(existing_hooks)
      service_hooks = []
      self.hooks.each do |type, hooks|
        hooks.each do |hook|
          service_hook = existing_hooks.find{|h|
            h.name == hook['name'] && h.type == type
          }
          unless service_hook
            service_hook = GridServiceHook.new(
              type: type,
              name: hook['name']
            )
          end
          service_hook.attributes = {
            cmd: hook['cmd'],
            instances: hook['instances'].split(','),
            oneshot: hook['oneshot']
          }
          service_hooks << service_hook
        end
      end

      service_hooks
    end
  end
end
