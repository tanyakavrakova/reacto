context Reacto::Trackable do
  context '#inject' do
    let(:test_behaviour) do
      lambda do |tracker_subscription|
        [16, 7, 2014].each do |value|
          tracker_subscription.on_value(value)
        end

        tracker_subscription.on_close
      end
    end

    it 'sends the values created by applying the `inject` operation on the ' \
      'last value and current value, using for first value the initial one' do
      trackable = source.inject(0) do |prev, v|
        prev + v
      end
      trackable.on(value: test_on_value)

      expect(test_data.size).to be(3)
      expect(test_data).to be == [16, 23, 2037]
    end

    it 'keeps the same results for multiple subscriptions' do
      trackable = source.inject(0) do |prev, v|
        prev + v
      end
      trackable.on(value: test_on_value)
      trackable.on(value: test_on_value)
      trackable.on(value: test_on_value)

      expect(test_data.size).to be(9)
      expect(test_data).to be == [16, 23, 2037] * 3
    end

    it 'sends the values created by applying the `inject` operation on the ' \
      'last value and current value, using for first value ' \
      'the first emitted by the source if no initial value provided' do
      trackable = source.inject do |prev, v|
        prev + v
      end
      trackable.on(value: test_on_value)

      expect(test_data.size).to be(3)
      expect(test_data).to be == [16, 23, 2037]
    end

    it 'sends the initial value if no value is emitted' do
      source = described_class.new(&-> (t) { t.on_close })
      trackable = source.inject(0) do |prev, v|
        prev + v
      end
      trackable.on(value: test_on_value)

      expect(test_data.size).to be(1)
      expect(test_data).to be == [0]
    end

    it 'sends nothing if no initial value and no value emitted' do
      source = described_class.new(&-> (t) { t.on_close })
      trackable = source.inject do |prev, v|
        prev + v
      end
      trackable.on(value: test_on_value)

      expect(test_data.size).to be(0)
    end

    context 'with label' do
      it 'applies the  accumulation only to the emitted values of type ' \
        'LabeledTrackable with the matching label' do
        source = described_class.enumerable((1..10)).group_by_label do |value|
          [(value % 3), value]
        end

        trackable = source.inject(12, label: 0) { |prev, curr| prev + curr }
        trackable.on(value: test_on_value)

        expect_trackable_values(test_data.first, [1, 4, 7, 10], label: 1)
        expect_trackable_values(test_data[1], [2, 5, 8], label: 2)
        expect_trackable_values(test_data.last, [15, 21, 30], label: 0)
      end
    end
  end
end
