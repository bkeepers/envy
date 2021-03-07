require "spec_helper"

describe Envy::Type::URI do
  let(:environment) { Envy::Environment.new({}) }

  describe "cast" do
    subject { described_class.new(environment, :app_url) }

    it "returns Addressable::URI" do
      uri = subject.cast("https://example.com")
      expect(uri).to be_instance_of(Addressable::URI)
    end

    context "with options[:template]" do
      let(:template) { "s3://{key}:{secret}@{bucket}{/path}" }
      subject { described_class.new(environment, :s3_url, template: template) }

      it "returns the parsed URI" do
        uri = subject.cast("s3://mykey:mysecret@mybucket/mypath")
        expect(uri).to be_instance_of(Addressable::URI)
        expect(uri.user).to eql("mykey")
        expect(uri.password).to eql("mysecret")
      end

      it "raises an error if it does not match" do
        expect { subject.cast("http://nope.com") }.to raise_error(ArgumentError, /#{template}/)
      end
    end
  end
end
