require 'spec_helper'

describe ActionDispatch::Session::RedisStore do
  before do
    @app = Object.new
    @sid = '_session_08efe7c6'
    @env = {'rack.session.options' => {:id => @sid}}
    @session = 'qwerty'
  end

  it 'should raise NoMethodError when get_session is called' do
    @redis = ActionDispatch::Session::RedisStore.new(@app)
    lambda {@redis.set_session(@env, @sid, @session)}.should raise_error(NoMethodError)
  end

  it 'should raise NoMethodError when set_session is called' do
    @redis = ActionDispatch::Session::RedisStore.new(@app)
    lambda {@redis.get_session(@env, @sid)}.should raise_error(NoMethodError)
  end

  it 'should raise NoMethodError when destroy is called' do
    @redis = ActionDispatch::Session::RedisStore.new(@app)
    lambda {@redis.destroy(@env)}.should raise_error(NoMethodError)
  end

  { 'with default namespace' => {},
    'with redis namespace'   => {:namespace => 'redis'},
    'with no namespace'      => {:namespace => nil}
  }.each do |c, options|
    context c do
      before do
        @redis = ActionDispatch::Session::RedisStore.new(@app, options)
        publicize_methods
      end

      it 'should set and get session data' do
        @redis.set_session(@env, @sid, @session)
        @redis.get_session(@env, @sid).should === [@sid, @session]
      end

      it 'should expire session data' do
        env = {'rack.session.options' => {:expire_after => 1}}
        @redis.set_session(env, @sid, @session)
        @redis.get_session(env, @sid).should === [@sid, @session]
        sleep 2
        @redis.get_session(env, @sid).should === [@sid, {}]
      end

      it 'should destroy session data' do
        @redis.set_session(@env, @sid, @session)
        @redis.get_session(@env, @sid).should === [@sid, @session]
        @redis.destroy(@env)
        @redis.get_session(@env, @sid).should === [@sid, {}]
      end
    end
  end

  private

  def publicize_methods
    class << @redis
      public :get_session, :set_session, :destroy
    end
  end
end
