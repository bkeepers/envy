require "spec_helper"

describe Envy::Environment do
  subject { Envy::Environment.new({}) }

  describe "reset" do
    it "resets each variable" do
      variable = Envy::Variable.new(subject, :test)
      subject.add variable
      expect(variable).to receive(:reset)
      subject.reset
    end
  end
end
