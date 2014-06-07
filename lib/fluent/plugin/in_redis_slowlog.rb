class Fluent::Redis_SlowlogInput < Fluent::Input
  Fluent::Plugin.register_input('redis_slowlog', self)

  config_param :tag,      :string
  config_param :host,     :string,  :default => nil
  config_param :port,     :integer, :default => 6379
  config_param :logsize,  :integer,  :default => 128
  config_param :interval, :integer,  :default => 10


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
    pong = @redis.ping
    begin
        unless pong == 'PONG'
            raise "fluent-plugin-redis-slowlog: cannot connect redis"
        end
    end
    @log_id = 0
    @get_interval = @interval
  end

  def start
    super
    @watcher = Thread.new(&method(:watch))
  end

  def shutdown
    super
  end

  private
  def watch
    while true
      sleep @get_interval
      @log_id = output( @log_id )
    end
  end

  def output( last_id = 0) 
    slow_logs = []
    slow_logs = @redis.slowlog('get', logsize)

    log_id = slow_logs[0][0]
    slow_logs.each do |log|
      unless log[0] > last_id
        break
      end
      log_hash = { id: log[0], timestamp: log[1], exec_time: log[2], command: log[3] }
      Fluent::Engine.emit(tag, Time.now.to_i, log_hash)
    end
    return log_id
  end
end

