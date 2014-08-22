require "spec_helper"

describe Envy do
  describe "configure" do
    it "loads the envfile" do
      Envy.configure(fixture_path("Envfile"))
      expect(Envy.env).to respond_to(:from_envfile)
    end
  end
end
