require "spec_helper"

describe Envy::Environment do
  let(:env) { {} }
  subject { Envy::Environment.new(env) }

  describe "setup" do
    it "loads the envfile" do
      subject.setup(fixture_path("Envfile"))
      expect(subject).to respond_to(:from_envfile)
    end

    it "returns the environment" do
      expect(subject.setup(fixture_path("Envfile"))).to be(subject)
    end

    it "evaluates the block" do
      subject.setup { string :from_block }
      expect(subject).to respond_to(:from_block)
    end
  end

  describe "reset" do
    it "resets each variable" do
      variable = Envy::Type::Variable.new(subject, :test)
      subject.add variable
      expect(variable).to receive(:reset)
      subject.reset
    end
  end

  describe "validate" do
    it "does not raise an error if all required variables are present" do
      env["APP_URL"] = "https://example.com"
      subject.setup { string :app_url }
      subject.validate
    end

    it "raises an ArgumentError if required variables are missing" do
      subject.setup { string :app_url }
      expect { subject.validate }.to raise_error(RuntimeError, /Missing.*APP_URL/)
    end
  end
end
