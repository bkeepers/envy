require "spec_helper"

describe Envy::Variable do
  let(:environment) { Envy::Environment.new({}) }

  describe "accessor" do
    it "memoizes default values" do
      var = Envy::Variable.new(environment, :test) { Time.now.to_s }
      expect(var.accessor).to equal(var.accessor)
    end

    it "memoizes cast values" do
      environment.env["TEST"] = "42"
      var = Envy::Variable.new(environment, :test)

      value = var.accessor
      expect(var).not_to receive(:cast)
      expect(var.accessor).to equal(value)
    end
  end

  describe "reset" do
    it "clears memoized value" do
      var = Envy::Variable.new(environment, :test) { Time.now.to_s }
      value = var.accessor
      var.reset
      expect(var.accessor).not_to equal(value)
    end
  end

end
