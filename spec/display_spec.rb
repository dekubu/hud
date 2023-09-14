# spec/hud/display_spec.rb

require_relative "spec_helper.rb"

describe Hud::Display do
  
  describe Hud::Display::Helpers do
    let(:component_class) { double("ComponentClass") }
    
    before do
      allow(Hud::Display).to receive(:build).and_return(component_class)
    end
    
    describe '.display' do
      it 'displays a component by its name' do
        expect(component_class).to receive(:call).with(locals: { key: 'value' })
        described_class.new.display(:test_component, locals: { key: 'value' })
      end
    end
  end
  
  describe Hud::Display::Component do
    let(:component) { described_class.new(locals: { name: 'Charlie' }) }
    
    describe '.call' do
      it 'creates a new instance of a component with the given locals' do
        result = described_class.call(locals: { test_key: 'test_value' })
        expect(result.locals.test_key).to eq('test_value')
      end
    end
    
    describe '#display' do
      it 'returns an error message if the partial component is not found' do
        allow(File).to receive(:exist?).and_return(false)
        expect(component.display(:non_existent_component)).to eq("Partial partial_name not found")
      end

      # You can add more tests here for when the partial component does exist.
    end
    
    describe '#to_s' do
      it 'renders the component as a string' do
        
        mock_template = double("Template")
        allow(Tilt::ERBTemplate).to receive(:new).and_return(mock_template)
        allow(mock_template).to receive(:render).and_return("Rendered Component")

        expect(component.to_s).to eq("Rendered Component")
      end
      
      it 'suggests to create a view if the template is missing' do
        allow(Tilt::ERBTemplate).to receive(:new).and_raise(Errno::ENOENT)
        expect(component.to_s).to eq("Create a view for #{described_class}")
      end
    end
  end
end
