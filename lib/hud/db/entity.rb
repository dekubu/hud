module Hud
    module DB
      class Entity
        attr_accessor :uid,:created_at,:last_updated_at
        def self.queries(&block)
          const_set(:Queries, Module.new(&block))
          include const_get(:Queries)
        end
        def self.associations(repository, &block)
          const_set(:AssociationMethod, Module.new(&block))
          repository.include const_get(:AssociationMethod)
        end
        # Define a method to serialize an entity object to a hash
        def to_hash
          result = {}
          instance_variables.each do |var_name|
            attribute_name = var_name.to_s[1..-1].to_sym
            result[attribute_name] = instance_variable_get(var_name)
          end
          result
        end
        # Define a class method to create an entity object from a hash
        def self.from_hash(uid,data_hash)
          entity = new
  
          entity.uid = uid
  
          data_hash.each do |attribute, value|
            # Convert the attribute name to a symbol and check if it's an attribute of the object
            attribute = attribute.to_sym
            if entity.respond_to?("#{attribute}=")
              entity.send("#{attribute}=", value)
            end
          end
  
          entity
        end
        def self.const_missing(name)
          @@context = self
  
          if defined?(self::Queries)
            @@queries =self::Queries
          end
  
          if name == :Repository
            # Define the repository class dynamically
            repository_class = Class.new do
  
              def initialize(entity_class=@@context)
                @entity_class = entity_class
                `mkdir -p ./.data`
                @name = "./.data/#{entity_class.name}"
  
  
                @entities = []
              end
  
              def add(entity)
                uid = SecureRandom.uuid
  
                entity.created_at = DateTime.now.to_s
                entity.last_updated_at = entity.created_at
  
                SDBM.open(@name) do |db|
                  db[uid] = entity.to_hash.to_msgpack
                end
  
                uid
              end
  
              def update(entity)
                entity.last_updated_at = DateTime.now.to_s
  
                SDBM.open(@name) do |db|
                  db.update entity.uid => entity.to_hash.to_msgpack
                end
  
                entity
              end
  
              def delete(entity)
                SDBM.open(@name) do |db|
                  db.delete(entity.uid)
                end
              end
  
              def reset!
                all.map{|e| delete(e)}
              end
  
              def get(uid)
                all.find{|e| e.uid == uid}
              end
  
              def count
                all.count
              end
  
              def all
                result = []
  
                SDBM.open(@name) do |db|
                  db.each do |key, value|
                    data = MessagePack.unpack(value)
                    result << @entity_class.from_hash(key,data)
                  end
                end
  
                result
              end
            end
  
  
            if defined?(@@queries)
              repository_class.include @@queries
            end
            # Set the Repository class as a constant within the entity class
            const_set(name, repository_class)
  
          else
            super
          end
        end
      end
    end
  end