module Hud
  module DB
    module Entity
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def queries(&block)
          const_set(:Queries, Module.new(&block))
          self::Repository.include(const_get(:Queries)) if const_defined?(:Repository)
        end

        def associations(repository, &block)
          const_set(:AssociationMethod, Module.new(&block))
          repository.include(const_get(:AssociationMethod))
        end

        def const_missing(name)
          @@context = self

          if defined?(self::Queries)
            @@queries = self::Queries
          end

          if name == :Repository
            repository_class = Class.new do
              def initialize(entity_class = @@context)
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
                  db[uid] = Marshal.dump(entity.to_hash)
                end

                uid
              end

              def update(entity)
                entity.last_updated_at = DateTime.now.to_s

                SDBM.open(@name) do |db|
                  db[entity.uid] = Marshal.dump(entity.to_hash)
                end

                entity
              end

              def persist(entity)
                if entity.new?
                  add(entity)
                else
                  update(entity)
                end
              end

              def delete(entity)
                SDBM.open(@name) do |db|
                  db.delete(entity.uid)
                end
              end

              def reset!
                all.map { |e| delete(e) }
              end

              def get(uid)
                all.find { |e| e.uid == uid }
              end

              def count
                all.count
              end

              def all
                result = []
                SDBM.open(@name) do |db|
                  db.each do |key, value|
                    data = Marshal.load(value)
                    result << @entity_class.from_hash(key, data)
                  end
                end
                result
              end

              alias_method :insert, :add
              alias_method :<<, :add
              alias_method :save, :update
            end

            if defined?(@@queries)
              repository_class.include @@queries
            end

            const_set(name, repository_class)
          else
            super
          end
        end
      end

      attr_accessor :uid, :created_at, :last_updated_at

      def to_hash
        result = {}
        instance_variables.each do |var_name|
          attribute_name = var_name.to_s[1..-1].to_sym
          result[attribute_name] = instance_variable_get(var_name)
        end
        result
      end

      def new?
        return true if created_at.nil?
        false
      end

      def self.from_hash(uid, data_hash)
        entity = new
        entity.uid = uid

        data_hash.each do |attribute, value|
          attribute = attribute.to_sym
          if entity.respond_to?("#{attribute}=")
            entity.send("#{attribute}=", value)
          end
        end

        entity
      end
    end
  end
end
