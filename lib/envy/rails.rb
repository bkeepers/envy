module Envy
  class Railtie < Rails::Railtie
    config.before_configuration do |app|
      app.extend(Envy)      
      envfile = ENV["ENVFILE"] || Rails.root.join('Envfile')
      Envy.env = app.env = Envy::Environment.new(ENV).configure(envfile)
    end
end
