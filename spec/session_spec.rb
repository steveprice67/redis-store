require 'spec_helper'

describe ActionDispatch::Session::RedisStore do
  before do
    @app = Object.new
    @sid = '_session_08efe7c6'
    @env = {'rack.session.options' => {:id => @sid}}
    @session = 'qwerty'
  end

  it 'should raise NoMethodError when get_session is called' do
    @data = ActionDispatch::Session::RedisStore.new(@app)
    lambda {@data.set_session(@env, @sid, @session)}.should raise_error(NoMethodError)
  end

  it 'should raise NoMethodError when set_session is called' do
    @data = ActionDispatch::Session::RedisStore.new(@app)
    lambda {@data.get_session(@env, @sid)}.should raise_error(NoMethodError)
  end

  it 'should raise NoMethodError when destroy is called' do
    @data = ActionDispatch::Session::RedisStore.new(@app)
    lambda {@data.destroy(@env)}.should raise_error(NoMethodError)
  end

  { 'with default namespace' => {},
    'with redis namespace'   => {:namespace => 'redis'},
    'with no namespace'      => {:namespace => nil}
  }.each do |c, options|
    context c do
      before do
        @data = ActionDispatch::Session::RedisStore.new(@app, options)
        publicize_methods
      end

      it 'should set and get session data' do
        @data.set_session(@env, @sid, @session)
        @data.get_session(@env, @sid).should === [@sid, @session]
      end

      it 'should expire session data' do
        env = {'rack.session.options' => {:expire_after => 1}}
        @data.set_session(env, @sid, @session)
        @data.get_session(env, @sid).should === [@sid, @session]
        sleep 2
        @data.get_session(env, @sid).should === [@sid, {}]
      end

      it 'should destroy session data' do
        @data.set_session(@env, @sid, @session)
        @data.get_session(@env, @sid).should === [@sid, @session]
        @data.destroy(@env)
        @data.get_session(@env, @sid).should === [@sid, {}]
      end
    end
  end

  private

  def publicize_methods
    class << @data
      public :get_session, :set_session, :destroy
    end
  end
end
