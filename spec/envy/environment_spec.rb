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
  end
end
