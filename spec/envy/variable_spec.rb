require "spec_helper"

describe Envy::Type::Variable do
  let(:environment) { Envy::Environment.new({}) }
  let(:options) { {} }
  subject do
    described_class.new(environment, :test, options) { Time.now.to_s }
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

  describe "required?" do
    it "defaults to true" do
      expect(described_class.new(environment, :test)).to be_required
    end

    it "is true if symbol returns true" do
      expect(environment).to receive(:conditional?).and_return(true)
      variable = described_class.new(environment, :test, :required => :conditional?)
      expect(variable).to be_required
    end

    it "is false if symbol returns false" do
      expect(environment).to receive(:conditional?).and_return(false)
      variable = described_class.new(environment, :test, :required => :conditional?)
      expect(variable).not_to be_required
    end
  end

  describe "missing?" do
    it "returns true if required and value is nil" do
      variable = described_class.new(environment, :test)
      expect(variable).to be_missing
    end

    it "returns false if not required" do
      variable = described_class.new(environment, :test, :required => false)
      expect(variable).not_to be_missing
    end

    it "returns false if a default is defined" do
      variable = described_class.new(environment, :test) { "default" }
      expect(variable).not_to be_missing
    end

    it "returns false if a value is provided" do
      variable = described_class.new(environment, :test)
      environment.source["TEST"] = "value"
      expect(variable).not_to be_missing
    end
  end
end
