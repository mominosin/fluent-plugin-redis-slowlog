# fluent-plugin-redis-slowlog [![Build Status](https://travis-ci.org/mominosin/fluent-plugin-redis-slowlog.svg?branch=master)](https://travis-ci.org/mominosin/fluent-plugin-redis-slowlog)

## Installation

    $ gem install fluent-plugin-redis-slowlog

## Configuration
```config
<source>
  type redis_slowlog
  host [Redis Hostname]
  port [Redis Port (default: 63790)]
  logsize  [Redis Command(SLOWLOG get logsise) (default:128)]
  interval [Redis Command(SLOWLOG get logsize) interval (default:10)]
  tag redis.slowlog
</source>
```

### output
```
2014-06-08 05:33:51 +0900 redis.slowlog: {"id":176,"timestamp":1402173275,"exec_time":9,"command":["set","hoge","aga"]}
2014-06-08 05:33:51 +0900 redis.slowlog: {"id":175,"timestamp":1402173273,"exec_time":137,"command":["slowlog","get","128"]}
```
