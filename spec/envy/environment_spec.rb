require "spec_helper"

describe Envy::Environment do
  subject { Envy::Environment.new({}) }

  describe "configure" do
    it "loads the envfile" do
      subject.configure(fixture_path("Envfile"))
      expect(subject).to respond_to(:from_envfile)
    end

    it "returns the environment" do
      expect(subject.configure(fixture_path("Envfile"))).to be(subject)
    end

    it "evaluates the block" do
      subject.configure { string :from_block }
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
      subject.configure { string :app_url }
      subject.source["APP_URL"] = "https://example.com"
      subject.validate
    end

    it "raises an ArgumentError if required variables are missing" do
      subject.configure { string :app_url }
      expect { subject.validate }.to raise_error(RuntimeError, /Missing.*APP_URL/)
    end
  end
end
