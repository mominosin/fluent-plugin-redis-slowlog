class Fluent::Redis_SlowlogInput < Fluent::Input
  Fluent::Plugin.register_output('redis_slowlog', self)

  config_param :tag,      :string
  config_param :host,     :string,  :default => nil
  config_param :port,     :integer, :default => 6379
  config_param :logsize,  :integer,  :default => 128
  config_param :interval, :integer,  :default => 128


  # config_param :hoge, :string, :default => 'hoge'

  def initialize
    super
    require 'redis'
  end

  def configure(conf)
    super
    @redis = Redis.new(
      :host => @host, 
      :port => @port
    )
  end

  def start
    super
    # init
  end

  def shutdown
    super
    # destroy
  end

  private
  def watch
    while true
      sleep interval
      id = output( id )
    end
  end

  def output( last_id = 0) 
    id = 0
    slow_logs = []
    slow_logs = @redis.slowlog('get', logsize)

    slow_logs.each do |log|
      if log[0] <= last_id
        break
      end
      log_hash = { id: log[0], timestamp: log[1], exec_time: log[2], command: log[3] }
      Fluent::Engine.emit(tag, Fluent::Engine.now, log_hash)
      id = log_hash[:id]
    end
  end
end

