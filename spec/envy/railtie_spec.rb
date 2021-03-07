require "spec_helper"
require "rails"
require "envy/railtie"
require "rake"

describe Envy::Railtie do
  let(:application) { Class.new(Rails::Application) }

  before do
    @env = ENV.to_h
    Rails.application = nil
  end

  after do
    ENV.replace @env
    Envy.environment = nil
  end

  it "defines rake tasks" do
    application.load_tasks
    expect(Rake.application["env"]).to be_instance_of(Rake::Task)
  end

  it "sets $ENV" do
    application
    expect($ENV).to be(Envy.environment)
  end

  it "validates declared variables after initialize" do
    Envy.environment.setup { string :missing }
    expect {
      ActiveSupport.run_load_hooks(:after_initialize, application)
    }.to raise_error(RuntimeError, /MISSING/)
  end

  context "when Envfile exists" do
    it "evalates the Envfile" do
      # Rails uses existance of config.ru and falls back to Dir.pwd to set Rails.root
      Dir.chdir(fixture_path) { application }
      expect(Envy.environment).to respond_to(:from_envfile)
    end
  end

  context "with ENV['ENVFILE']" do
    it "evalates the Envfile" do
      ENV["ENVFILE"] = fixture_path("Envfile")
      application
      expect(Envy.environment).to respond_to(:from_envfile)
    end

    it "raises an error if does not exist" do
      ENV["ENVFILE"] = fixture_path("nope")
      expect { application }.to raise_error(Errno::ENOENT)
    end
  end

  context "when Envfile does not exist" do
    it "does not raise error" do
      expect(File.exists?("#{Dir.pwd}/Envfile")).to be(false)
      expect { application }.not_to raise_error
    end
  end
end
