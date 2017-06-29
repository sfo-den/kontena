module Volumes
  class Create < Mutations::Command

    required do
      model :grid, class: Grid
      string :scope, in: ['instance', 'stack', 'grid']
      string :name , matches: /\A(?!-)(\w|-)+\z/ # do not allow "-" as a first character
      string :driver
    end

    optional do
      model :driver_opts, class: Hash
    end

    def validate
      if self.grid.volumes.find_by(name: self.name)
        add_error(:name, :already_exists, "Volume with given name already exists")
      end
      if self.driver.include?(':')
        add_error(:driver, :tag, "Driver version tag cannot be used")
      end
    end

    def execute
      volume = Volume.create(
        grid: self.grid,
        name: self.name,
        scope: self.scope,
        driver: self.driver,
        driver_opts: self.driver_opts
      )

      unless volume.save
        volume.errors.each do |key, message|
          add_error(key, :invalid, message)
        end
        return
      end

      volume
    end

  end

end
