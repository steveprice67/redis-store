module ActionDispatch
  module Session
    class RedisStore < AbstractStore
      def initialize(app, options = {})
        require 'redis'
        options[:expire_after] ||= options[:expires]
        options = { :namespace => 'rack:session' }.merge(options)
        super
        @redis = options[:cache] || Redis.new(options)
      end

      private

      def get_session(env, sid)
        begin
          session = Marshal.load(@redis.get(_scope(sid))) rescue nil
        rescue Errno::ECONNREFUSED
          # ignore
        end
        [sid, session || {}]
      end

      def set_session(env, sid, session_data)
        options = env['rack.session.options'] || {}
        ttl = options[:expire_after] || 0
        @redis.set(scope = _scope(sid), Marshal.dump(session_data))
        @redis.expire(scope, ttl) if ttl > 0
        sid
      rescue Errno::ECONNREFUSED
        false
      end

      def destroy(env)
        @redis.del(_scope(current_session_id(env)))
      rescue Errno::ECONNREFUSED
        false
      end

      def _scope(sid)
        [@default_options[:namespace], sid].compact.join(':')
      end
    end
  end
end
