module Envy
  class Railtie < Rails::Railtie
    def envfile
      ENV["ENVFILE"] || Rails.root.join('Envfile')
    end

    config.before_configuration do |app|
      begin
        Envy.env = Envy::Environment.new(ENV).configure(envfile)
      rescue Envy::EnvfileNotFound => e
        # re-raise if ENVFILE is explicitly defined.
        raise if ENV["ENVFILE"]
      end
    end

    rake_tasks do
      require "envy/tasks"
    end
  end
end
