module Envy
  # Rails integration to automatically load `Envfile` and define the rake task.
  #
  # `Envfile` will automatically get loaded from the root of the Rails app when
  # the application boots. An alternate Envfile can be loaded by setting
  # `ENV["ENVFILE"]`.
  #
  # The `rake env` task also gets loaded, which will list out the Envy config.
  class Railtie < Rails::Railtie
    def envfile
      ENV["ENVFILE"] || Rails.root.join('Envfile')
    end

    config.before_configuration do
      $ENV = Envy.environment = Envy::Environment.new do |key|
        ENV[key] || Rails.application.credentials[key.downcase]
      end

      begin
        $ENV.setup(envfile)

      rescue Errno::ENOENT => e
        # re-raise if ENVFILE is explicitly defined.
        raise if ENV["ENVFILE"]
      end
    end

    config.after_initialize do
      begin
        $ENV.validate
      rescue => e
        abort e.message
      end
    end

    rake_tasks do
      require "envy/tasks"
    end
  end
end
