require_relative "spec_helper"  # Adjust the path accordingly

RSpec.describe Hud::DB::Entity do
  class DummyEntity
    include Hud::DB::Entity
    attr_accessor :name
  end

  let(:repository) { DummyEntity::Repository.new }

  describe 'Entity' do
    it 'should set uid, created_at, last_updated_at' do
      entity = DummyEntity.new
      entity.uid = 'some_uid'
      entity.created_at = 'some_date'
      entity.last_updated_at = 'some_date'

      expect(entity.uid).to eq('some_uid')
      expect(entity.created_at).to eq('some_date')
      expect(entity.last_updated_at).to eq('some_date')
    end

    it 'should convert to hash' do
      entity = DummyEntity.new
      entity.uid = 'some_uid'
      expect(entity.to_hash).to eq({uid: 'some_uid'})
    end

    it 'should identify new entities' do
      entity = DummyEntity.new
      expect(entity.new?).to be true
      entity.created_at = 'some_date'
      expect(entity.new?).to be false
    end
  end

  describe 'Repository' do
    it 'should add entity' do
      entity = DummyEntity.new
      uid = repository.add(entity)
      expect(uid).not_to be_nil
    end

    it 'should update entity' do
      entity = DummyEntity.new
      uid = repository.add(entity)
      entity.uid = uid
      entity.name = 'NewName'
      updated_entity = repository.update(entity)
      expect(updated_entity.name).to eq('NewName')
    end

    it 'should delete entity' do
      entity = DummyEntity.new
      entity.uid = SecureRandom.uuid
      uid = repository.add(entity)
      repository.delete(entity)
      expect(repository.get(uid)).to be_nil
    end

    it 'should fetch entity by uid' do
      entity = DummyEntity.new
      uid = repository.add(entity)
      fetched_entity = repository.get(uid)
      expect(fetched_entity.uid).to eq(uid)
    end

    it 'should count entities' do
      3.times { repository.add(DummyEntity.new) }
      expect(repository.count => 3).to be_truthy
    end
  end
end
