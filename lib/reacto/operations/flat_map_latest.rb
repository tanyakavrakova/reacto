require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class FlatMapLatest
      def initialize(transform)
        @transform = transform
        @last_active = nil
      end

      def call(tracker)
        subscription = Subscriptions::FlatMapSubscription.new(tracker)
        value = lambda do |v|
          trackable = @transform.call(v)

          @last_active.unsubscribe if @last_active

          sub = subscription.subscription!
          trackable.do_track sub
          @last_active = sub
        end

        close = lambda do
          subscription.source_closed = true
          return unless subscription.closed?

          tracker.on_close
        end

        Subscriptions::OperationSubscription.new(
          tracker, value: value, close: close
        )
      end
    end
  end
end
