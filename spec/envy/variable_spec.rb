require "spec_helper"

describe Envy::Variable do
  let(:environment) { Envy::Environment.new({}) }
  let(:options) { {} }
  subject do
    Envy::Variable.new(environment, :test, options) { Time.now.to_s }
  end

  describe "value" do
    it "memoizes default values" do
      expect(subject.value).to equal(subject.value)
    end

    it "memoizes cast values" do
      environment.source["TEST"] = "42"
      value = subject.value
      expect(subject).not_to receive(:cast)
      expect(subject.value).to equal(value)
    end
  end

  describe "reset" do
    it "clears memoized value" do
      value = subject.value
      subject.reset
      expect(subject.value).not_to equal(value)
    end
  end

  describe "with :from option" do
    before do
      options[:from] = "OTHER_VAR"
    end

    it "fetches value from given name" do
      environment.source["TEST"] = "not used"
      environment.source["OTHER_VAR"] = "the real slim shady"

      expect(subject.value).to eql("the real slim shady")
    end
  end
end
