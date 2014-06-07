require 'helper'

class Redis_SlowlogInputTest < Test::Unit::TestCase

  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
      tag redis-slowlog
      host localhost
      port 6379
      logsize 128
      interval 10
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::InputTestDriver.new(Fluent::Redis_SlowlogInput).configure(conf)
  end

  def test_configure
  end

end
