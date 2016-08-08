# before start test - add new two single metrics to api by method create_metric (test_metric and test_metric1)

# def create_metric
#   start_date = (Time.now - 1.days).strftime('%Y-%m-%d')
#   hours = (5..23).to_a
#   minutes = [0, 10, 20, 30, 40, 50]
#   hours.each do |x|
#     minutes.each do |y|
#       value = rand(1..15)
#       %x( curl -i -H "Content-Type: application/json" -X POST -d '{"format":"json","metric":{"name":"test_metric"},"metric_values":[{"value":#{value},"created_at":"#{start_date}T#{x}:#{y}:00Z","custom_timestamp":null}]}' http://localhost:3000/v1/metrics\?access_token\=8fb4fad2c433e2910c058eab58bae56a )
#     end
#   end
# end
#
# start_date = (Time.now - 1.days).strftime('%Y-%m-%d')
# hours = (5..23).to_a
# minutes = [0, 10, 20, 30, 40, 50]
# hours.each do |x|
#   minutes.each do |y|
#     value = rand(1..15)
#     %x( curl -i -H "Content-Type: application/json" -X POST -d '{"format":"json","metric":{"name":"APPS-04232, APPS-04233 and XRE-03090 errors coun", "description":"APPS-04232, APPS-04233 and XRE-03090 errors count\n\nAPPS-04232: Editorial Notification service is down  \nAPPS-04233: Program Picker failure within the X1 Sports App\nXRE-03090: IP Linear tuning failure"},"metric_values":[{"value":#{value},"created_at":"#{start_date}T#{x}:#{y}:00Z","custom_timestamp":null}]}' http://96.119.145.130/v1/metrics\?access_token\=8fb4fad2c433e2910c058eab58bae56a )
#   end
# end

require 'spec_helper'

describe 'chart series' do

  before(:all) do
    @name = 'test widgets'
    @wait = Selenium::WebDriver::Wait.new(:timeout => 10)
    # log in
    @driver = Selenium::WebDriver.for :firefox
    @driver.navigate.to 'localhost:3001'

    element = @driver.find_element(:id, 'user_groups')
    element.find_elements(:tag_name => 'option').find do |option|
      option.text == 'OIV_ADMIN'
    end.click
    @driver.find_element(:class, 'form-horizontal').find_element(:name, 'commit').click; sleep 5
    # create new dash
    @driver.find_element(:id, 'dashboards_dropdown_lite').click
    @driver.find_element(:link_text, 'Create Dashboard').click
    element = @driver.find_element(:id, 'dashboard_role_ids')
    element.find_elements(:tag_name => 'option').find do |option|
      option.text == 'OIV_ADMIN'
    end.click
    @driver.find_element(:id, 'dashboard_name').send_key(@name)
    @driver.find_element(:id, 'edit_dashboard_dialog_').find_element(:name, 'commit').click; sleep 5
    # create new chart widget with minimum params
    @driver.find_element(:link_text, 'Add widget').click
    @driver.find_element(:id, 'add_widgets_dialog').find_element(:css, 'div.modal-body > div:nth-child(1) > a').click
    @driver.find_element(:id, 'create_chart_widget_dialog').find_element(:name, 'chart_widget[name]').send_key('test chart widget')
    @driver.find_element(:id, 'create_chart_widget_dialog').find_element(:name, 'chart_widget[gap]').send_key('10')
    @driver.find_element(:id, 'create_chart_widget_dialog').find_element(:name, 'chart_widget[start_time]').send_key('1440')
    @driver.find_element(:id, 'create_chart_widget_dialog').find_element(:name, 'chart_widget[end_time]').send_key('0')
    @driver.find_element(:id, 'create_chart_widget_dialog').find_element(:name, 'commit').click; sleep 5
  end

  after(:all) do
    # delete dashboard
    @driver.find_element(:id, 'dashboards_dropdown_lite').click
    @driver.find_element(:link_text, @name).click; sleep 5
    @driver.execute_script('window.confirm = function() {return true}')
    @driver.find_element(:link_text, 'Delete').click
    @driver.quit
  end

  it 'add new chart series with empty required fields' do
    @driver.navigate.refresh
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:name, 'button').click
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:class, 'edit_series_dialog_link').click; sleep 5
    expect(@driver.find_element(:id, 'edit_series_dialog').displayed?).to be_truthy
    @driver.find_element(:id, 'edit_series_dialog').find_element(:name, 'commit').click; sleep 5
    expect(@driver.find_element(:id, 'edit_series_dialog').find_elements(:class, 'error').size).to eql(4)
    @driver.find_element(:id, 'edit_series_dialog').find_element(:class, 'close').click; sleep 5
    expect(@driver.find_element(:id, 'edit_series_dialog').displayed?).to be_falsey
  end

  it 'add new chart series' do
    @driver.navigate.refresh
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:name, 'button').click
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:link_text, 'Add series').click; sleep 5
    @driver.find_element(:id, 'edit_series_dialog').find_element(:name, 'chart_series[name]').send_key('test')
    @driver.find_element(:id, 'edit_series_dialog').find_element(:name, 'chart_series[database_name]').send_key('test_metric')
    @driver.find_element(:id, 'edit_series_dialog').find_element(:name, 'chart_series[title]').send_key('test')
    @driver.find_element(:id, 'edit_series_dialog').find_element(:name, 'chart_series[start_date]').send_key(0)
    @driver.find_element(:id, 'edit_series_dialog').find_element(:name, 'commit').click; sleep 5
    expect(@driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:class, 'highcharts-series').displayed?).to be_truthy
    expect(@driver.find_element(:class, 'highcharts-tracker').displayed?).to be_truthy
    el = @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:id, 'test_chart_widget')
    expect(el.attribute('data-widget')).to include('"chart_type":"series"')
  end

  it 'edit series' do
    @driver.navigate.refresh
    # edit series params
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:name, 'button').click
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:link_text, 'Edit test series').click; sleep 5
    expect(@driver.find_element(:id, 'edit_series_dialog').displayed?).to be_truthy
    @driver.find_element(:name, 'chart_series[name]').send_key('_test')
    @driver.find_element(:name, 'chart_series[title]').send_key('_test')
    @driver.find_element(:class, 'chart_series_value_precision').clear
    @driver.find_element(:class, 'chart_series_value_precision').send_key(3)
    @driver.find_element(:name, 'chart_series[color]').send_key('#e41111')
    @driver.find_element(:id, 'edit_series_dialog').find_element(:name, 'commit').click; sleep 5
    # check new params
    el = @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:id, 'test_chart_widget')
    expect(el.attribute('data-widget')).to include('"name":"test_test"')
    expect(el.attribute('data-widget')).to include('"title":"test_test"')
    expect(el.attribute('data-widget')).to include('"color":"#e41111"')
    expect(el.attribute('data-widget')).to include('"value_precision":3')
    expect(el.attribute('data-widget')).to include('"inner_zero_values":true')
    expect(el.attribute('data-widget')).to include('"show_source_query":true')
  end

  it 'chart_type: series' do
    @driver.navigate.refresh
    # edit widget and change all enabled params
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:name, 'button').click
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:class, 'open_edit_widget_dialog').click; sleep 5
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:css, '[id$=_daily_view]').click; sleep 5
    # check that Start Time and End Time becomes disabled
    expect(@driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[start_time]').attribute('readonly')).to be_truthy
    expect(@driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[end_time]').attribute('readonly')).to be_truthy
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:css, '[id$=_summed_totals]').click
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[primary_series_id]').send_key('test')
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[y_axis_title]').send_key('y_axis_title')
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[y_axis_min]').send_key('10')
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[y_axis_max]').send_key('30')
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:id, 'chart_widget_control_line_type_user_defined').click
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[lower_control_line]').clear
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[upper_control_line]').clear
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[lower_control_line]').send_key(10)
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[upper_control_line]').send_key(15)
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:css, '[id$=_send_notifications]').click
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:css, '[id$=_highlight_reboot_window').click
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:css, '[id$=_logarithmic').click; sleep 3
    # check that works only one of two function
    begin
      @driver.find_element(:id, 'edit_widget_dialog').find_element(:css, '[id$=_allow_zero_values').send_key('')
      raise e
    rescue Selenium::WebDriver::Error::InvalidElementStateError
      expect(true).to be_truthy
    end
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:css, '[id$=_logarithmic').click
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:css, '[id$=_allow_zero_values').click; sleep 3
    begin
      @driver.find_element(:id, 'edit_widget_dialog').find_element(:css, '[id$=_logarithmic').send_key('')
      raise e
    rescue Selenium::WebDriver::Error::InvalidElementStateError
      expect(true).to be_truthy
    end
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:class, 'series_stack_element').send_key('MIT')
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:class, 'series_incident_element').send_key('Monitoring')
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[series_sort_type]').send_key('By Values')
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'commit').click; sleep 5
    # check widget and series
    el = @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:id, 'test_chart_widget')
    expect(el.attribute('data-widget')).to include('"daily_view":true')
    expect(el.attribute('data-widget')).to include('"highlight_reboot_window":false')
    expect(el.attribute('data-widget')).to include('"summed_totals":true')
    expect(el.attribute('data-widget')).to include('"primary_series_name":"test_test"')
    expect(el.attribute('data-widget')).to include('"y_axis_title":"y_axis_title"')
    expect(el.attribute('data-widget')).to include('"send_notifications":true')
    expect(el.attribute('data-widget')).to include('"y_axis_scale":[10.0,30.0]')
    expect(el.attribute('data-widget')).to include('"element":"MIT,Tools"')
    expect(el.attribute('data-widget')).to include('"element":"Decommission,MIT"')
    expect(el.attribute('data-widget')).to include('"control_lines":[10,15]')
    expect(el.attribute('data-widget')).to include('"series_sort_type":"by_values"')
  end

  it 'notification enabled/disabled' do
    expect(@driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:class, 'widget_notifications').text).to eql('Notifications enabled')
    @driver.find_element(:class, 'widget_notifications').click; sleep 5
    expect(@driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:class, 'widget_notifications').text).to eql('Notifications disabled')
  end

  it 'chart_type: series_zoom' do
    @driver.navigate.refresh
    # edit widget and change all enabled params
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:name, 'button').click
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:class, 'open_edit_widget_dialog').click; sleep 5
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[chart_type]').send_key('series_zoom')
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:css, '[id$=_daily_view]').click
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:id, 'chart_widget_control_line_type_auto').click
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[rational_coefficient]').clear
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[rational_coefficient]').send_key(4)
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:css, '[id$=_logarithmic').click
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:css, '[id$=_allow_zero_values').click
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[series_sort_type]').send_key('Alphabetically')
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'commit').click; sleep 5
    # check widget and series
    el = @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:id, 'test_chart_widget')
    expect(el.attribute('data-widget')).to include('"chart_type":"series_zoom"')
    expect(el.attribute('data-widget')).to include('"series_sort_type":"alphabetically"')
    expect(el.attribute('data-widget')).to include('"control_lines":[1,1]')
    expect(el.attribute('data-widget')).to include('"daily_view":false')
  end

  it 'chart_type: multi_axes' do
    @driver.navigate.refresh
    # edit widget and change all enabled params
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:name, 'button').click
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:class, 'open_edit_widget_dialog').click; sleep 5
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[chart_type]').send_key('multi_axes'); sleep 5
    # check X axis scale becomes hidden
    expect(@driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[y_axis_min]').displayed?).to be_falsey
    expect(@driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[y_axis_max]').displayed?).to be_falsey
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[secondary_series_id]').send_key('test')
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:id, 'chart_widget_control_line_type_disabled').click
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'commit').click; sleep 5
    # check widget and series
    el = @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:id, 'test_chart_widget')
    expect(el.attribute('data-widget')).to include('"chart_type":"multi_axes"')
    expect(el.attribute('data-widget')).to include('"secondary_series_name":"test_test"')
  end


  it 'chart_type: multi_axes_zoom' do
    @driver.navigate.refresh
    # edit widget and change all enabled params
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:name, 'button').click
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:class, 'open_edit_widget_dialog').click; sleep 5
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[chart_type]').send_key('multi_axes_zoom')
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'commit').click; sleep 5
    # check widget and series
    el = @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:id, 'test_chart_widget')
    expect(el.attribute('data-widget')).to include('"chart_type":"multi_axes_zoom"')
  end

  it 'edit series as multi-axes' do
    @driver.navigate.refresh
    # edit series params
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:name, 'button').click
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:link_text, 'Edit test_test series').click; sleep 5
    expect(@driver.find_element(:css, '.js_series_color_1_field > div:nth-child(1) > div:nth-child(2) > span:nth-child(2) > i:nth-child(1)').
               attribute('style')).to eql('background-color: rgb(228, 17, 17);')
    @driver.find_element(:name, 'chart_series[series_type]').send_key('line')
    @driver.find_element(:name, 'chart_series[label_title]').send_key('test')
    @driver.find_element(:name, 'chart_series[label_float]').send_key('left')
    @driver.find_element(:name, 'chart_series[label_format]').send_key('test')
    @driver.find_element(:id, 'edit_series_dialog').find_element(:name, 'commit').click; sleep 5
    # check new params
    el = @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:id, 'test_chart_widget')
    expect(el.attribute('data-widget')).to include('"series_type":"line"')
    expect(el.attribute('data-widget')).to include('"label_title":"test"')
    expect(el.attribute('data-widget')).to include('"label_format":"test"')
    expect(el.attribute('data-widget')).to include('"label_float":"left"')
  end

  it 'chart_type: bar' do
    @driver.navigate.refresh
    # edit widget and change all enabled params
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:name, 'button').click
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:class, 'open_edit_widget_dialog').click; sleep 5
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[chart_type]').send_key('bar')
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'commit').click; sleep 5
    # check widget and series
    el = @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:id, 'test_chart_widget')
    expect(el.attribute('data-widget')).to include('"chart_type":"bar"')
  end

  it 'chart_type: bar_zoom' do
    @driver.navigate.refresh
    # edit widget and change all enabled params
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:name, 'button').click
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:class, 'open_edit_widget_dialog').click; sleep 5
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[chart_type]').send_key('bar_zoom')
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'commit').click; sleep 5
    # check widget and series
    el = @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:id, 'test_chart_widget')
    expect(el.attribute('data-widget')).to include('"chart_type":"bar_zoom"')
  end

  it 'chart_type: bar_stackable' do
    @driver.navigate.refresh
    # edit widget and change all enabled params
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:name, 'button').click
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:class, 'open_edit_widget_dialog').click; sleep 5
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[chart_type]').send_key('bar_stackable')
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'commit').click; sleep 5
    # check widget and series
    el = @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:id, 'test_chart_widget')
    expect(el.attribute('data-widget')).to include('"chart_type":"bar_stackable"')
  end

  it 'chart_type: area' do
    @driver.navigate.refresh
    # edit widget and change all enabled params
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:name, 'button').click
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:class, 'open_edit_widget_dialog').click; sleep 5
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[chart_type]').send_key('area')
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'commit').click; sleep 5
    # check widget and series
    el = @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:id, 'test_chart_widget')
    expect(el.attribute('data-widget')).to include('"chart_type":"area"')
  end

  it 'chart_type: area_zoom' do
    @driver.navigate.refresh
    # edit widget and change all enabled params
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:name, 'button').click
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:class, 'open_edit_widget_dialog').click; sleep 5
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[chart_type]').send_key('area_zoom')
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'commit').click; sleep 5
    # check widget and series
    el = @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:id, 'test_chart_widget')
    expect(el.attribute('data-widget')).to include('"chart_type":"area_zoom"')
  end

  it 'chart_type: area_stackable' do
    @driver.navigate.refresh
    # edit widget and change all enabled params
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:name, 'button').click
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:class, 'open_edit_widget_dialog').click; sleep 5
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[chart_type]').send_key('area_stackable')
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'commit').click; sleep 5
    # check widget and series
    el = @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:id, 'test_chart_widget')
    expect(el.attribute('data-widget')).to include('"chart_type":"area_stackable"')
  end

  it 'chart_type: area_zoom_stackable' do
    @driver.navigate.refresh
    # edit widget and change all enabled params
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:name, 'button').click
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:class, 'open_edit_widget_dialog').click; sleep 5
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[chart_type]').send_key('area_zoom_stackable')
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'commit').click; sleep 5
    # check widget and series
    el = @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:id, 'test_chart_widget')
    expect(el.attribute('data-widget')).to include('"chart_type":"area_zoom_stackable"')
  end

  it 'chart_type: spline' do
    @driver.navigate.refresh
    # edit widget and change all enabled params
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:name, 'button').click
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:class, 'open_edit_widget_dialog').click; sleep 5
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[chart_type]').send_key('spline')
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'commit').click; sleep 5
    # check widget and series
    el = @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:id, 'test_chart_widget')
    expect(el.attribute('data-widget')).to include('"chart_type":"spline"')
  end

  it 'chart_type: spline_zoom' do
    @driver.navigate.refresh
    # edit widget and change all enabled params
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:name, 'button').click
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:class, 'open_edit_widget_dialog').click; sleep 5
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[chart_type]').send_key('spline_zoom')
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'commit').click; sleep 5
    # check widget and series
    el = @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:id, 'test_chart_widget')
    expect(el.attribute('data-widget')).to include('"chart_type":"spline_zoom"')
  end

  it 'add second chart series' do
    @driver.navigate.refresh
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:name, 'button').click
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:link_text, 'Add series').click; sleep 5
    @driver.find_element(:id, 'edit_series_dialog').find_element(:name, 'chart_series[name]').send_key('test')
    @driver.find_element(:id, 'edit_series_dialog').find_element(:name, 'chart_series[database_name]').send_key('test_metric1')
    @driver.find_element(:id, 'edit_series_dialog').find_element(:name, 'chart_series[title]').send_key('test')
    @driver.find_element(:id, 'edit_series_dialog').find_element(:name, 'chart_series[start_date]').send_key(0)
    @driver.find_element(:id, 'edit_series_dialog').find_element(:name, 'commit').click; sleep 5
    expect(@driver.find_element(:css, '[id$=-test-chart-widget]').find_elements(:class, 'highcharts-series').size).to eql(2)
    expect(@driver.find_element(:class, 'highcharts-legend').find_elements(:class, 'highcharts-legend-item').size).to eql (2)
    expect(@driver.find_element(:class, 'highcharts-tracker').displayed?).to be_truthy
  end

  it 'select/deselect series' do
    @driver.navigate.refresh
    # deselect series
    @driver.find_element(:class, 'highcharts-button').click; sleep 1
    @driver.find_element(:css, 'div.highcharts-contextmenu > div > div:nth-child(3)').click; sleep 5
    expect(@driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:class, 'highcharts-series').displayed?).to be_falsey
    #select series
    @driver.find_element(:id, 'test_chart_widget').find_element(:css, 'g.highcharts-legend-item:nth-child(1) > text:nth-child(3)').click; sleep 5
    @driver.find_element(:id, 'test_chart_widget').find_element(:css, 'g.highcharts-legend-item:nth-child(1) > text:nth-child(3)').click; sleep 5
    expect(@driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:class, 'highcharts-series').displayed?).to be_truthy
  end

  it 'delete series' do
    # delete first series
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:name, 'button').click
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_elements(:class, 'edit_series_dialog_link').find do |x|
      x.click if x.text == 'Edit test series'
    end; sleep 5
    @driver.find_element(:id, 'edit_series_dialog').find_element(:link_text, 'Delete').click; sleep 5
    # check that remained one series
    expect(@driver.find_element(:class, 'highcharts-legend').find_elements(:class, 'highcharts-legend-item').size).to eql (1)
    # delete second series
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:name, 'button').click
    @driver.find_element(:css, '[id$=-test-chart-widget]').find_elements(:class, 'edit_series_dialog_link').find do |x|
      x.click if x.text == 'Edit test_test series'
    end; sleep 5
    @driver.find_element(:id, 'edit_series_dialog').find_element(:link_text, 'Delete').click; sleep 5
    begin
      @driver.find_element(:id, 'test_chart_widget').find_element(:class, 'highcharts-legend-item')
      raise e
    rescue Selenium::WebDriver::Error::NoSuchElementError
      expect(true).to be_truthy
    end
  end
end