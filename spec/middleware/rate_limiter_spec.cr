require "../spec_helper"
require "../../src/discordcr-middleware/middleware/cached_routes"
require "../../src/discordcr-middleware/middleware/rate_limiter"

describe DiscordMiddleware::RateLimiter do
  limiter = RateLimiter(Discord::Snowflake).new
  limiter.bucket(:foo, 1_u32, 1.seconds)

  describe "#call" do
    context "when not rate limited" do
      it "calls the next middleware" do
        mw = DiscordMiddleware::RateLimiter.new(
          limiter,
          :foo
        )
        ctx = Discord::Context.new
        ctx.put(Client)

        mw.call(message, ctx) { true }.should be_true
      end
    end

    context "when rate limited" do
      it "doesn't call the next middleware" do
        mw = DiscordMiddleware::RateLimiter.new(
          limiter,
          :foo
        )
        ctx = Discord::Context.new
        ctx.put(Client)

        mw.call(message, ctx) { true }
        mw.call(message, ctx) { true }.should be_falsey
      end

      context "with a new key" do
        it "calls the next middleware" do
          mw = DiscordMiddleware::RateLimiter.new(
            limiter,
            :foo
          )
          ctx = Discord::Context.new
          ctx.put(Client)
          msg_a = message(author_id: 0)
          msg_b = message(author_id: 1)

          mw.call(msg_a, ctx) { true }
          mw.call(msg_a, ctx) { true }.should be_falsey
          mw.call(msg_b, ctx) { true }.should be_true
        end
      end
    end
  end
end
