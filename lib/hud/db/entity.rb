require 'sdbm'
require 'securerandom'
require 'date'

module Hud
  module DB
    module Entity
      def self.included(base)
        base.extend(ClassMethods)
      end

      attr_accessor :uid, :created_at, :last_updated_at

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

              alias_method :create, :add
              alias_method :insert, :add
              alias_method :put, :add
              alias_method :append, :add
              alias_method :store, :add

              def update(entity)
                entity.last_updated_at = DateTime.now.to_s
                SDBM.open(@name) do |db|
                  db[entity.uid] = Marshal.dump(entity.to_hash)
                end
                entity
              end

              alias_method :modify, :update
              alias_method :change, :update
              alias_method :edit, :update
              alias_method :revise, :update
              alias_method :alter, :update

              def delete(entity)
                SDBM.open(@name) do |db|
                  db.delete(entity.uid)
                end
              end

              alias_method :remove, :delete
              alias_method :erase, :delete
              alias_method :discard, :delete
              alias_method :destroy, :delete
              alias_method :wipe, :delete

              def get(uid)
                all.find { |e| e.uid == uid }
              end

              alias_method :fetch, :get
              alias_method :retrieve, :get
              alias_method :find, :get
              alias_method :acquire, :get
              alias_method :obtain, :get

              def reset!
                puts "Warning: This will delete all records. Are you sure? (y/n)"
                confirmation = gets.chomp

                if confirmation.downcase == 'y'
                  puts "Type 'reset' to confirm."
                  final_confirmation = gets.chomp

                  if final_confirmation.downcase == 'reset'
                    all.map { |e| delete(e) }
                    puts "All records have been deleted."
                  else
                    puts "Reset cancelled."
                  end
                else
                  puts "Reset cancelled."
                end
              end

              def count
                all.count
              end

              def all
                result = []
                SDBM.open(@name) do |db|
                  db.each do |key, value|
                    data = Marshal.load(value)
                    entity = @entity_class.new
                    entity.from_hash(key, data)
                    result << entity
                  end
                end
                result
              end
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

      def to_hash
        result = {}
        instance_variables.each do |var_name|
          attribute_name = var_name.to_s[1..].to_sym
          result[attribute_name] = instance_variable_get(var_name)
        end
        result
      end

      def new?
        return true if created_at.nil?
        false
      end

      def from_hash(uid, data_hash)
        self.uid = uid
        data_hash.each do |attribute, value|
          attribute = attribute.to_sym
          if self.respond_to?("#{attribute}=")
            self.send("#{attribute}=", value)
          end
        end
      end

    end
  end
end
