require 'reacto/subscriptions/subscription'

module Reacto
  module Subscriptions
    class TrackerSubscription
      include Subscription

      def initialize(notification_tracker, trackable)
        @notification_tracker = notification_tracker
        @trackable = trackable

        @subscribed = true
      end

      def subscribed?
        @subscribed
      end

      def unsubscribe
        @trackable.off(@notification_tracker)

        @trackable = nil
        @notification_tracker = nil
        @subscribed = false
      end

      def on_open
        return unless subscribed?

        @notification_tracker.on_open
      end

      def on_value(v)
        return unless subscribed?

        @notification_tracker.on_value(v)
      end

      def on_error(e)
        return unless subscribed?

        @notification_tracker.on_error(e)
        unsubscribe
      end

      def on_close
        return unless subscribed?

        @notification_tracker.on_close
        unsubscribe
      end
    end
  end
end
