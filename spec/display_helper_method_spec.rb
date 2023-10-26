require "ostruct"
require_relative "spec_helper"  # Adjust the path accordingly

RSpec.describe Hud::Display::Helpers do
  include described_class  # includes the module being described into the example group

  describe "#display" do
    before do
      ENV["RACK_ENV"] = "development"
      allow(Rack::App::Utils).to receive(:pwd).and_return("./spec/apps/base")
    end

    it "from global conponents '/components" do
      result = display(:ok, locals: {key: "value"})
      expect(result).to be_a(String)
      expect(result.include?("Ok"))
    end

    it "from application conponents '/base/components" do
      result = display(:header, locals: {key: "value"})
      expect(result).to be_a(String)
      expect(result.include?("Header"))
    end
  end
end
