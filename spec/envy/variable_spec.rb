require "spec_helper"

describe Envy::Type::Variable do
  let(:env) { {} }
  let(:environment) { Envy::Environment.new(env) }
  let(:dsl) { Envy::DSL.new(environment) }
  let(:options) { {} }

  subject do
    described_class.new(dsl, :test, **options)
  end

  describe "value" do
    before { options[:default] = -> { rand } }

    it "memoizes default values" do
      expect(subject.value).to equal(subject.value)
    end

    it "memoizes cast values" do
      env["TEST"] = "42"
      value = subject.value
      expect(subject).not_to receive(:cast)
      expect(subject.value).to be(value)
    end
  end

  describe "reset" do
    before { options[:default] = -> { rand } }

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
      env["TEST"] = "not used"
      env["OTHER_VAR"] = "the real slim shady"

      expect(subject.value).to eql("the real slim shady")
    end
  end

  describe "required?" do
    it "defaults to true" do
      expect(subject).to be_required
    end

    it "returns result of symbol" do
      options[:required] = :conditional?

      expect(environment).to receive(:conditional?).and_return(true)
      expect(subject).to be_required

      expect(environment).to receive(:conditional?).and_return(false)
      expect(subject).not_to be_required
    end

    it "calls block" do
      options[:required] = -> { false }
      expect(subject).not_to be_required
    end
  end

  describe "missing?" do
    it "returns true if required and value is nil" do
      expect(subject).to be_missing
    end

    it "returns false if not required" do
      options[:required] = false
      expect(subject).not_to be_missing
    end

    it "returns false if a default is defined" do
      options[:default] = "default"
      expect(subject).not_to be_missing
    end

    it "returns false if a value is provided" do
      env["TEST"] = "value"
      expect(subject).not_to be_missing
    end
  end
end
