module GenCache
  module AttributeCache
    def with_attribute(*attributes)
      self.cached_indices ||= {}
      self.cached_indices = self.cached_indices.merge(attributes.each_with_object({}) {
        |attribute, indices| indices[attribute] = {}
      })

      attributes.each do |attribute|
        define_singleton_method("find_cached_by_#{attribute}") do |value|
          self.cached_indices["#{attribute}"] ||= []
          self.cached_indices["#{attribute}"] << value
          cache_key = GenCache.attribute_key(self, attribute, value)
          GenCache.fetch(cache_key) do
            self.send("find_by_#{attribute}", value)
          end
        end

        define_singleton_method("find_cached_all_by_#{attribute}") do |value|
          self.cached_indices["#{attribute}"] ||= []
          self.cached_indices["#{attribute}"] << value
          cache_key = GenCache.attribute_key(self, attribute, value, all: true)
          GenCache.fetch(cache_key) do
            self.send("find_all_by_#{attribute}", value)
          end
        end
      end
    end
  end
end