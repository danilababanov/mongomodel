module MongoModel
  module DocumentExtensions
    module CollectionModifiers
      extend ActiveSupport::Concern
      
      module ClassMethods
        # Post.increase!(:hits => 1, :available => -1)
        def increase!(args)
          collection_modifier_update('$inc', args)
        end

        # Post.set!(:hits => 0, :available => 100)
        def set!(args)
          collection_modifier_update('$set', args)
        end

        # Post.unset!(:hits, :available)
        def unset!(*args)
          values = args.each_with_object({}) { |key, hash| hash[key.to_s] = 1 }
          collection_modifier_update('$unset', values)
        end

        # Post.push!(:tags => 'xxx')
        def push!(args)
          collection_modifier_update('$push', args)
        end

        # Post.push_all!(:tags => ['xxx', 'yyy', 'zzz'])
        def push_all!(args)
          collection_modifier_update('$pushAll', args)
        end
        
        # Post.add_to_set!(:tags => 'xxx')
        def add_to_set!(args)
          collection_modifier_update('$addToSet', args)
        end

        # Post.pull!(:tags => 'xxx')
        def pull!(args)
          collection_modifier_update('$pull', args)
        end

        # Post.pull_all!(:tags => ['xxx', 'yyy', 'zzz'])
        def pull_all!(args)
          collection_modifier_update('$pullAll', args)
        end

        # Post.pop!(:tags)
        def pop!(*args)
          values = args.each_with_object({}) { |key, hash| hash[key.to_s] = 1 }
          collection_modifier_update('$pop', values)
        end

        # Post.shift!(:tags, :data)
        def shift!(*args)
          values = args.each_with_object({}) { |key, hash| hash[key.to_s] = -1 }
          collection_modifier_update('$pop', values)
        end

        # requires mongodb 1.7.2
        # Post.rename!(:tags => :tag_collection)
        def rename!(args)
          collection_modifier_update('$rename', args)
        end

      private
        def collection_modifier_update(modifier, args)
          selector = MongoModel::MongoOptions.new(self, scoped.finder_options).selector
          collection.update(selector, { modifier => args.stringify_keys! }, :multi => true)
        end
      end

      module InstanceMethods
        delegate :increase!, :set!, :unset!, :push!, :push_all!, :add_to_set!, :pull!, :pull_all!, :pop!, :shift!, :rename!, :to => :instance_scope
        
      private
        def instance_scope
          self.class.where(:id => id)
        end
      end
    end
  end
end