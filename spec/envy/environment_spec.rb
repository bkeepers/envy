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
      variable = Envy::Variable.new(subject, :test)
      subject.add variable
      expect(variable).to receive(:reset)
      subject.reset
    end
  end
end
