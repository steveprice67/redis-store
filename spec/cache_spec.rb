require 'spec_helper'

describe ActiveSupport::Cache::RedisStore do
  { 'without a namespace' => nil,
    'with redis namespace' => 'redis'}.each do |c1, namespace|
    context c1 do
      before do
        @redis = ActiveSupport::Cache::RedisStore.new(:namespace => namespace)
        @key = 'data'
        @num = rand(1000).to_i
        @obj = { :foo => ['test', 'bar', 1] }
        @pi = 3.141593
        @str = 'raw data'
      end

      { '0 items' => 0,
        '1 item' => 1,
        'many items' => 100 }.each do |c2, count|
        context "given a cache with #{c2}" do
          before do
            count.times { @redis.write("test#{count}", Object.new) }
          end

          it 'should read and write objects' do
            @redis.write(@key, @obj)
            @redis.read(@key).should == @obj
          end

          it 'should read and write strings' do
            @redis.write(@key, @str)
            @redis.read(@key).should == @str
          end

          it 'should read and write raw strings' do
            @redis.write(@key, @str, :raw => true)
            @redis.read(@key).should == @str
          end

          it 'should return a raw number as a string' do
            @redis.write(@key, @num, :raw => true)
            @redis.read(@key).should == @num.to_s
          end

          it 'should read and write integers' do
            @redis.write(@key, @num)
            @redis.read(@key).should == @num
          end

          it 'should read and write raw integers as a string' do
            @redis.write(@key, @num, :raw => true)
            @redis.read(@key).should == @num.to_s
          end

          it 'should read and write floats' do
            @redis.write(@key, @pi)
            @redis.read(@key).should == @pi
          end

          it 'should read and write raw floats as a string' do
            @redis.write(@key, @pi, :raw => true)
            @redis.read(@key).should == @pi.to_s
          end

          it 'should overwrite previous objects' do
            @redis.write(@key, @obj)
            @redis.read(@key).should == @obj
            @redis.write(@key, @str)
            @redis.read(@key).should == @str
          end

          it 'should implicitly increment raw numbers by 1' do
            @redis.write(@key, @num, :raw => true)
            @redis.read(@key).to_i.should == @num
            @redis.increment(@key)
            @redis.read(@key).to_i.should == (@num + 1)
          end

          it 'should explicitly increment raw numbers by 1' do
            @redis.write(@key, @num, :raw => true)
            @redis.read(@key).to_i.should == @num
            @redis.increment(@key, 1)
            @redis.read(@key).to_i.should == @num + 1
          end

          it 'should increment raw numbers by n' do
            inc = rand(@num).to_i
            @redis.write(@key, @num, :raw => true)
            @redis.read(@key).to_i.should == @num
            @redis.increment(@key, inc)
            @redis.read(@key).to_i.should == @num + inc
          end

          it 'should raise an error when incrementing objects' do
            @redis.write(@key, @obj)
            lambda {@redis.decrement(@key)}.should raise_error(RuntimeError)
          end

          it 'should implicitly decrement raw numbers by 1' do
            @redis.write(@key, @num, :raw => true)
            @redis.read(@key).to_i.should == @num
            @redis.decrement(@key)
            @redis.read(@key).to_i.should == @num - 1
          end

          it 'should explicitly decrement raw numbers by 1' do
            @redis.write(@key, @num, :raw => true)
            @redis.read(@key).to_i.should == @num
            @redis.decrement(@key, 1)
            @redis.read(@key).to_i.should == @num - 1
          end

          it 'should decrement raw numbers by n' do
            dec = rand(@num).to_i
            @redis.write(@key, @num, :raw => true)
            @redis.read(@key).to_i.should == @num
            @redis.decrement(@key, dec)
            @redis.read(@key).to_i.should == @num - dec
          end

          it 'should raise an error when decrementing objects' do
            @redis.write(@key, @obj)
            lambda {@redis.decrement(@key)}.should raise_error(RuntimeError)
          end

          it 'should delete matches by string pattern'
          it 'should delete matches by regular expression'

          it 'should delete objects after clear' do
            @redis.write(@key, @obj)
            @redis.read(@key).should == @obj
            @redis.clear
            @redis.read(@key).should be_nil
          end
        end
      end
    end

    after do
      @redis.clear
    end
  end
end
