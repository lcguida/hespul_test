require 'test_helper'

class MeterTest < ActiveSupport::TestCase

  setup do
    @meter = meters(:one)
  end

  test "invalid without a installation_date" do
    @meter.installation_date = nil
    assert @meter.invalid?
  end

  test "invalid without a site" do
    @meter.site = nil
    assert @meter.invalid?
  end

  test "invalid if installation date is before site created_at" do
    @meter.installation_date = @meter.site.created_at - 1.day
    assert @meter.invalid?
  end

  test "creates a initial zero reading on its creation" do
    site = sites(:two)
    meter = Meter.create({
      site: site,
      active: true,
      installation_date: site.created_at.to_date
    })
    assert_equal meter.readings.count, 1
  end

  test ".uninstall" do
    @meter.uninstall
    assert_not @meter.active
    assert_equal @meter.uninstallation_date, Date.today
  end

end
