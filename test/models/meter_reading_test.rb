require 'test_helper'

class MeterReadingTest < ActiveSupport::TestCase

  setup do
    @meter_reading = meter_readings(:one_first_reading)
  end

  test "has a valid factory" do
    assert @meter_reading.valid?
  end

  test "invalid without a meter" do
    @meter_reading.meter = nil
    assert @meter_reading.invalid?
  end

  test "invalid wihtout a value" do
    @meter_reading.value = nil
    assert @meter_reading.invalid?
  end

  test "invalid without a date" do
    @meter_reading.date = nil
    assert @meter_reading.invalid?
  end

  test "invalid without a source" do
    @meter_reading.source = nil
    assert @meter_reading.invalid?
  end

  test "invalid when its date is prior to the meter installation date" do
    @meter_reading.date = @meter_reading.meter.installation_date - 1.day
    assert @meter_reading.invalid?
  end

  test "invalid when a import tries to override a user reading" do
    @meter_reading.update(source: MeterReading.sources[:import])
    assert @meter_reading.invalid?
  end

  test "invalid when a calculated tries to override a user reading" do
    @meter_reading.update(source: MeterReading.sources[:calculated])
    assert @meter_reading.invalid?
  end

  test "invalid when a calculated tries to override a imported reading" do
    @meter_reading.source = MeterReading.sources[:imported]
    @meter_reading.update(source: MeterReading.sources[:calculated])
    assert @meter_reading.invalid?
  end

  test "invalid when value is smaller than previous readings value" do
    meter = @meter_reading.meter
    new_reading = meter.readings.create({value: 5, date: 3.days.ago})

    assert new_reading.invalid?
  end

end
