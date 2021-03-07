require "spec_helper"

describe Envy::DSL do
  let(:env) { {} }
  let(:envy) { Envy::Environment.new(env) }

  def procfile(&block)
    envy.setup(&block)
  end

  def self.procfile(&block)
    before { procfile(&block) }
  end

  describe "desc" do
    procfile do
      desc "a description"
      string :described

      string :undescribed
    end

    it "adds a description to a variable" do
      expect(envy[:described].description).to eql("a description")
    end

    it "leaves description blank for undescribed variable" do
      expect(envy[:undescribed].description).to be(nil)
    end
  end

  describe "string" do
    it "returns the value" do
      env["STR"] = "a string"
      procfile { string :str }

      expect(envy.str).to eql("a string")
    end
  end

  describe "integer" do
    before do
      procfile { integer :int, required: false }
    end

    it "returns nil if not defined" do
      expect(envy.int).to be(nil)
    end

    it "casts a string to an integer" do
      env["INT"] = "1"
      expect(envy.int).to be(1)
    end

    it "raises an error if it can't cast it" do
      env["INT"] = "nope"
      expect { envy.int }.to raise_error(ArgumentError, /invalid value for Integer()/)
    end
  end

  describe "boolean" do
    procfile { boolean :bool, required: false }

    ["0", "false", false, "off", "no", "f", "n"].each do |input|
      it "casts #{input.inspect} to false" do
        env["BOOL"] = input
        expect(envy.bool?).to be(false)
      end
    end

    ["1", "true", true, "on", "yes", "t", "y"].each do |input|
      it "casts #{input.inspect} to true" do
        env["BOOL"] = input
        expect(envy.bool?).to be(true)
      end
    end

    [nil, "", " "].each do |input|
      it "casts #{input.inspect} to nil" do
        env["BOOL"] = input
        expect(envy.bool?).to be(nil)
      end
    end

    it "raises an error if it can't cast it" do
      env["BOOL"] = "nope"
      expect { envy.bool? }.to raise_error(ArgumentError, /invalid value for boolean/)
    end
  end

  describe "uri" do
    procfile { uri :app_url, required: false }

    it "returns nil if not defined" do
      expect(envy.app_url).to be(nil)
    end

    it "returns a URI" do
      env["APP_URL"] = "http://example.com"
      expect(envy.app_url).to be_instance_of(Addressable::URI)
      expect(envy.app_url.to_s).to eq("http://example.com")
    end
  end

  describe "decimal" do
    procfile { decimal :price, required: false }
    it "returns nil if not defined" do
      expect(envy.price).to be(nil)
    end

    it "returns a decimal" do
      env["PRICE"] = "1.23"
      expect(envy.price).to be_instance_of(BigDecimal)
      expect(envy.price).to eq(BigDecimal("1.23"))
    end
  end

  describe ":default option" do
    it "returns the default if no value is provided" do
      procfile { string :blank, default: "not blank" }
      expect(envy.blank).to eql("not blank")
    end

    it "does not return the default if a value is provided" do
      procfile { boolean :bool, default: true }
      env["BOOL"] = 'false'
      expect(envy.bool?).to be(false)
    end

    it "gets value from other variable with a symbol" do
      procfile do
        string :default_from_other_var, default: :other_var
        string :other_var, default: "default"
      end

      expect(envy.default_from_other_var).to eql("default")
    end
  end

  describe "block" do
    it "instance evals block to transform value" do
      env["MAGIC_NUMBER"] = 5

      procfile do
        integer :multiplier, default: 2

        integer :magic_number do |value|
          value * multiplier
        end
      end

      expect(envy.magic_number).to be(10)
    end
  end

  describe "eval" do
    it "evaluates the given file" do
      procfile do
        eval File.expand_path("../../fixtures/Envfile", __FILE__)
      end

      envy.respond_to?(:from_envfile)
    end

    it "works with a Pathname" do
      procfile do
        eval Pathname.new(File.expand_path("../../fixtures/Envfile", __FILE__))
      end

      envy.respond_to?(:from_envfile)
    end

    it "raises Errno::ENOENT if file does not exist" do
      expect do
        procfile { eval "notfound" }
      end.to raise_error(Errno::ENOENT)
    end
  end
end
