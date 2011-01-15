module ActiveSupport
  module Cache
    class RedisStore < Store
      def initialize(options = {})
        require 'redis'
        super
        @data = options[:cache] || Redis.new(options)
      end

      #xxx Implement me!!!
      def delete_matched(matcher, options = nil)
        raise NotImplementedError.new(
          "#{self.class.name} does not support delete_matched")
      end

      # Make sure you only do this on numbers stored as raw data.
      def increment(name, amount = 1, options = nil)
        @data.incrby(_scope(name, options), amount)
      rescue Errno::ECONNREFUSED
        nil
      end

      # Make sure you only do this on numbers stored as raw data.
      def decrement(name, amount = 1, options = nil)
        @data.decrby(_scope(name, options), amount)
      rescue Errno::ECONNREFUSED
        nil
      end

      def clear(options = nil)
        if (key = _scope('', options)).blank?
          @data.flushdb
        else
          @data.keys(key + "*").each { |key| @data.del(key) }
        end
        true
      rescue Errno::ECONNREFUSED
        false
      end

      protected

      def read_entry(key, options) # :nodoc:
        entry = @data.get(key)
        entry = Marshal.load(entry) rescue Entry.new(entry)
      rescue Errno::ECONNREFUSED
        nil
      end

      def write_entry(key, entry, options) # :nodoc:
        entry = options[:raw] ? entry.value.to_s : Marshal.dump(entry)
        @data.set(key, entry) == 'OK'
      rescue Errno::ECONNREFUSED
        false
      end

      def delete_entry(key, options) # :nodoc:
        @data.del(key)
      rescue Errno::ECONNREFUSED
        false
      end

      def _scope(name, options)
        namespaced_key(name, merged_options(options))
      end
    end
  end
end
