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
      puts result
      expect(result).to be_a(String)
      expect(result.include?("Ok")).to be_truthy
    end

    it "from application conponents '/base/components" do
      result = display(:header, locals: {key: "value"})
      puts result
      expect(result).to be_a(String)
      expect(result.include?("Header")).to be_truthy
    end

    it "from alt components '/alt/components'" do
      result = display(:header, from: "alt", locals: {key: "value"})
      expect(result).to be_a(String)
      expect(result.include?("Alt")).to be_truthy
    end
    
    it "from nested components result" do
      result = render(:result)
      expect(result.include?("Ok")).to be_truthy
    end

    it "from nested components result using alias" do
      result = d(:result)
      expect(result.include?("Ok")).to be_truthy
    end

    it "from nested components result using alias" do
      result = d(:result)
      expect(result.include?("Ok")).to be_truthy
    end

    it "can call css" do
      result = d(:result, css: "#ko").text
      expect(result.include?("Ko")).to be_truthy
    end
    
  end
end
