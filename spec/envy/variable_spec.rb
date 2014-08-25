require "spec_helper"

describe Envy::Variable do
  let(:environment) { Envy::Environment.new({}) }
  let(:options) { {} }
  subject do
    Envy::Variable.new(environment, :test, options) { Time.now.to_s }
  end

  describe "accessor" do
    it "memoizes default values" do
      expect(subject.accessor).to equal(subject.accessor)
    end

    it "memoizes cast values" do
      environment.env["TEST"] = "42"
      value = subject.accessor
      expect(subject).not_to receive(:cast)
      expect(subject.accessor).to equal(value)
    end
  end

  describe "reset" do
    it "clears memoized value" do
      value = subject.accessor
      subject.reset
      expect(subject.accessor).not_to equal(value)
    end
  end

  describe "with :from option" do
    before do
      options[:from] = "OTHER_VAR"
    end

    it "fetches value from given name" do
      environment.env["TEST"] = "not used"
      environment.env["OTHER_VAR"] = "the real slim shady"

      expect(subject.accessor).to eql("the real slim shady")
    end
  end
end
