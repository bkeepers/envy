module Envy
  class Railtie < Rails::Railtie
    config.before_configuration do |app|
      envfile = ENV["ENVFILE"] || Rails.root.join('Envfile')
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
