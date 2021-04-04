# Zaya

Zaya is a simple, minimalist, and unpretentious queue processor for Ruby and
RabbitMQ, à la Sneakers.

The public API is **not stable**. This is an early draft for now. Expect major
design changes.

## Minimal example

1. Touch `boot.rb`:

```rb
require "zaya"

class MinimalWorker
  include Zaya::Worker

  self.queue_name = "greetings"
  self.max_priority = 10

  def perform(ctx)
    puts ctx.payload
    ctx.ack!
  end
end
```

2. Start up the server:

```sh
FORMATION="MinimalWorker=5" zaya --require boot.rb
```

3. Open up an IRB session:

```rb
require "bunny"

connection = Bunny.new
connection.start

ch = connection.create_channel

ch.default_exchange.publish("Hello, world", routing_key: "greetings", priority: 10)
ch.default_exchange.publish("Здравствуй, мир", routing_key: "greetings")
ch.default_exchange.publish("Witaj, świecie", routing_key: "greetings")
```

This is the expected output:

```
/\ /\
( . .) zaya

Starting processing, hit Ctrl-C to stop

2021-04-02T18:00:16Z PID-38057 [MinimalWorker-PID:P38057-CID:W26c] up (x5)
Hello, world
Здравствуй, мир
Witaj, świecie
```

4. Stop the worker:

```bash
kill -s SIGTERM 38057
```

Zaya will pause all consumers and wait 25 seconds to allow workers to finish
off their tasks.

```
[...]
2021-04-02T18:00:16Z PID:38057 Received graceful stop
2021-04-02T18:00:16Z PID:38057 Pausing to allow consumers to finish...
2021-04-02T18:00:16Z PID:38057 Done
```

## Middleware-centered

```rb
# Naive instrumentation middleware. Use your favorite provider, e.g.
# dry-monitor, activesupport notifications, and so on.
class Instrumentation
  EVENT_NAME = "zaya.perform"

  def call(ctx)
    Skylight.instrument(title: EVENT_NAME) do
      yield
    end
  end
end

class Stats
  PROCESSED_KEY = "zaya:stat:processed"
  FAILED_KEY = "zaya:stat:failed"
  TIMESTAMP_FORMAT = "%Y-%m-%dT%H:00Z"

  def call(ctx)
    yield

    # Might be used to draw a chart of processed tasks per hour,
    # like the Sidekiq UI.
    timestamp = Time.new.utc.strftime(TIMESTAMP_FORMAT)

    $redis.multi do |conn|
      conn.incr(PROCESSED_KEY)
      conn.incr("#{PROCESSED_KEY}:#{timestamp}")
      conn.incr(FAILED_KEY) if !ctx.success?
    end
  end
end

class ContentType
  def call(ctx)
    # Deserialize the payout (e.g. MessagePack).
  end
end

class ExponentialBackoff
  def call(ctx)
    # Re-enqueue to a retry exchange.
  end
end

Zaya.configure do |config|
  config.prepend Instrumentation
  config.use ContentType
  config.use Stats
  config.use ExponentialBackoff
end

class MyWorker
  include Zaya::Worker

  self.queue_name = "best_effort_scraper"

  def perform(ctx)
    # ...
  end
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem "zaya"
```

And then execute:

```sh
$ bundle install
```

Or install it yourself as:

```sh
$ gem install zaya
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kandayo/zaya.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
