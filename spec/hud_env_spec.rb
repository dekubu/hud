require_relative 'spec_helper'  # Adjust the path accordingly

RSpec.describe Hud::Env do
  class DummyClass; end
  class AnotherDummyClass; end

  before do
    DummyClass.include(Hud::Env)
    AnotherDummyClass.include(Hud::Env)
  end

  describe '.included' do
    it 'sets the folder name for the included class' do
      expect(Hud::Env.folder_name_for(DummyClass)).to eq('dummyclass')
    end

    it 'sets the folder name for another included class' do
      expect(Hud::Env.folder_name_for(AnotherDummyClass)).to eq('anotherdummyclass')
    end
  end

  describe '.folder_name_for' do
    it 'retrieves the folder name for a given class' do
      expect(Hud::Env.folder_name_for(DummyClass)).to eq('dummyclass')
    end

    it 'returns nil if the class has not included Env' do
      expect(Hud::Env.folder_name_for(String)).to be_nil
    end
  end
end
