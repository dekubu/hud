require_relative ""
require 'hud/db/entity'
require 'rspec'

describe Hud::DB::Entity do
  let(:entity) { described_class.new }
  
  describe "Attributes" do
    it "has an uid" do
      entity.uid = "12345"
      expect(entity.uid).to eq("12345")
    end
    
    it "has a created_at timestamp" do
      time = Time.now.to_s
      entity.created_at = time
      expect(entity.created_at).to eq(time)
    end
    
    it "has a last_updated_at timestamp" do
      time = Time.now.to_s
      entity.last_updated_at = time
      expect(entity.last_updated_at).to eq(time)
    end
  end
  
  describe ".queries" do
    # Stubbing a basic entity to test queries
    class TestEntity < Hud::DB::Entity
      queries do
        def self.test_query
          "test"
        end
      end
    end

    it "allows adding custom query methods" do
      expect(TestEntity.test_query).to eq("test")
    end
  end
  
  describe ".associations" do
    # Stubbing to test associations
    module TestRepository; end

    class TestEntity < Hud::DB::Entity
      associations(TestRepository) do
        def self.test_association
          "association"
        end
      end
    end

    it "allows adding custom association methods" do
      expect(TestRepository).to respond_to(:test_association)
    end
  end

  describe "#to_hash" do
    it "converts the entity object into a hash representation" do
      entity.uid = "12345"
      expect(entity.to_hash).to eq({ uid: "12345", created_at: nil, last_updated_at: nil })
    end
  end
  
  describe ".from_hash" do
    let(:hash_representation) { { uid: "12345", created_at: "time1", last_updated_at: "time2" } }

    it "creates an entity instance from a given hash" do
      entity_instance = described_class.from_hash("12345", hash_representation)
      expect(entity_instance.uid).to eq("12345")
      expect(entity_instance.created_at).to eq("time1")
      expect(entity_instance.last_updated_at).to eq("time2")
    end
  end
  
  # ... more tests for other methods and the dynamic Repository creation ...

end