class Fluent::Redis_SlowlogInput < Fluent::Input
  Fluent::Plugin.register_input('redis_slowlog', self)

  config_param :tag,      :string
  config_param :host,     :string,  :default => nil
  config_param :port,     :integer, :default => 6379
  config_param :logize,   :integer,  :default => 0
  config_param :interval, :integer,  :default => 10


  def initialize
    super
    require 'redis'
  end

  def configure(conf)
    super
    @log_id = 0
    @get_interval = @interval
  end

  def start
    super
    @redis = Redis.new(
      :host => @host,
      :port => @port,
      :thread_safe => true
    )
    pong = @redis.ping
    begin
        unless pong == 'PONG'
            raise "fluent-plugin-redis-slowlog: cannot connect redis"
        end
    end
    @watcher = Thread.new(&method(:watch))
  end

  def shutdown
    super
    @redis.quit
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

    if @logize > 0
    slow_logs = @redis.slowlog('get', @logsize)
    else
    slow_logs = @redis.slowlog('get')
    end

    log_id = last_id
    slow_logs.reverse.each do |log|
      unless log[0] > last_id
        next
      end

      log_id = log[0]
      timestamp = log[1]
      exec_time = log[2]
      command = log[3]

      log_hash = { "id" => log_id, "exec_time" => exec_time, "command" => command }
      Fluent::Engine.emit(tag, timestamp, log_hash)
    end

    return log_id
  end
end
