require "spec_helper"

describe Envy::DSL do
  let(:env) { {} }
  let(:config) { Envy::Environment.new(env) }
  let(:dsl) { Envy::DSL.new(config) }

  describe "desc" do
    it "adds a description to a variable" do
      dsl.desc "a description"
      dsl.string :described
      expect(config[:described].description).to eql("a description")
    end
  end

  describe "string" do
    before { dsl.string :str }

    it "returns the value" do
      env["STR"] = "a string"
      expect(config.str).to eql("a string")
    end
  end

  describe "integer" do
    before { dsl.integer :int, required: false }

    it "returns nil if not defined" do
      expect(config.int).to be(nil)
    end

    it "casts a string to an integer" do
      env["INT"] = "1"
      expect(config.int).to be(1)
    end

    it "raises an error if it can't cast it" do
      env["INT"] = "nope"
      expect { config.int }.to raise_error(ArgumentError, /invalid value for Integer()/)
    end
  end

  describe "boolean" do
    before { dsl.boolean :bool, required: false }

    ["0", "false", false, "off", "no", "f", "n"].each do |input|
      it "casts #{input.inspect} to false" do
        env["BOOL"] = input
        expect(config.bool?).to be(false)
      end
    end

    ["1", "true", true, "on", "yes", "t", "y"].each do |input|
      it "casts #{input.inspect} to true" do
        env["BOOL"] = input
        expect(config.bool?).to be(true)
      end
    end

    [nil, "", " "].each do |input|
      it "casts #{input.inspect} to nil" do
        env["BOOL"] = input
        expect(config.bool?).to be(nil)
      end
    end

    it "raises an error if it can't cast it" do
      env["BOOL"] = "nope"
      expect { config.bool? }.to raise_error(ArgumentError, /invalid value for boolean/)
    end
  end

  describe "uri" do
    before { dsl.uri :app_url, required: false }

    it "returns nil if not defined" do
      expect(config.app_url).to be(nil)
    end

    it "returns a URI" do
      env["APP_URL"] = "http://example.com"
      expect(config.app_url).to be_instance_of(Addressable::URI)
      expect(config.app_url.to_s).to eq("http://example.com")
    end
  end

  describe "decimal" do
    before { dsl.decimal :price, required: false }
    it "returns nil if not defined" do
      expect(config.price).to be(nil)
    end

    it "returns a decimal" do
      env["PRICE"] = "1.23"
      expect(config.price).to be_instance_of(BigDecimal)
      expect(config.price).to eq(BigDecimal("1.23"))
    end
  end

  describe ":default option" do
    it "returns the default if no value is provided" do
      dsl.string :blank, default: "not blank"
      expect(config.blank).to eql("not blank")
    end

    it "does not return the default if a value is provided" do
      dsl.boolean :bool, default: true
      env["BOOL"] = 'false'
      expect(config.bool?).to be(false)
    end

    it "instance evals block for default value" do
      self_in_block = nil
      dsl.integer(:magic_number) do
        self_in_block = self
        10
      end
      expect(config.magic_number).to be(10)
      expect(self_in_block).to be(config)
    end

    it "gets value from other variable with a symbol" do
      dsl.string :default_from_other_var, default: :other_var
      expect(config).to receive(:other_var).and_return("default")
      expect(config.default_from_other_var).to eql("default")
    end
  end

  describe "eval" do
    it "evaluates the given file" do
      dsl.eval(fixture_path("Envfile"))
      config.respond_to?(:from_envfile)
    end

    it "works with a Pathname" do
      dsl.eval(Pathname.new(fixture_path("Envfile")))
      config.respond_to?(:from_envfile)
    end

    it "raises Errno::ENOENT if file does not exist" do
      expect { dsl.eval(fixture_path("notfound")) }.to raise_error(Errno::ENOENT)
    end
  end
end
