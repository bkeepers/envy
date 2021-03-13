require "spec_helper"
require "rails"
require "envy/railtie"
require "rake"

describe Envy::Railtie do
  let(:application) do
    Class.new(Rails::Application) do
      config.eager_load = false
      config.logger = ActiveSupport::Logger.new($stdout)
    end
  end

  before do
    @env = ENV.to_h
    Rails.application = Envy.environment = $ENV = nil
  end

  after do
    ENV.replace @env
  end

  it "defines rake tasks" do
    application.load_tasks
    expect(Rake.application["env"]).to be_instance_of(Rake::Task)
  end

  it "sets $ENV" do
    application.initialize!
    expect($ENV).to be(Envy.environment)
  end

  context "when Envfile exists" do
    subject do
      # Rails uses existance of config.ru and falls back to Dir.pwd to set Rails.root
      Dir.chdir(fixture_path) { application.initialize! }
      application
    end

    it "evalates the Envfile" do
      ENV["FROM_ENVFILE"] = "yep"
      subject
      expect($ENV.from_envfile).to eq("yep")
    end

    it "validates declared variables" do
      expect { silence { subject } }.to raise_error(SystemExit, /FROM_ENVFILE/)
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

  context "using Rails.credentials" do
    before do
      ENV["ENVFILE"] = fixture_path("Envfile.credentials")
      ENV["FROM_ENV"] = "not secret"

      application.credentials = ActiveSupport::InheritableOptions.new(
        from_credentials: "secretz"
      )
    end

    it "merges credentials" do
      application.initialize!
      expect(Envy.environment.from_credentials).to eq("secretz")
      expect(Envy.environment.from_env).to eq("not secret")
    end

    it "gives ENV higher predence" do
      ENV["FROM_CREDENTIALS"] = "overridden"
      application.initialize!
      expect(Envy.environment.from_credentials).to eq("overridden")
    end
  end
end
