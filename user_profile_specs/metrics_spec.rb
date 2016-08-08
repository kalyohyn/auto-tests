require 'spec_helper'

describe 'Metrics' do

  before(:all) do
    @driver = Selenium::WebDriver.for :firefox
    @driver.navigate.to('localhost:3001')
    element = @driver.find_element(:id, 'user_groups')
    element.find_elements(:tag_name => 'option').find do |option|
      option.text == 'OIV_ADMIN'
    end.click
    @driver.find_element(:class, 'form-horizontal').find_element(:name, 'commit').click; sleep 5
  end

  after(:all) do
    @driver.quit
  end

  before(:each) do
    @driver.navigate.refresh
  end

  it 'view metrics' do
    @driver.find_element(:id, 'profile_dropdown').click
    @driver.find_element(:link_text, 'Metrics').click; sleep 5
    expect(@driver.current_url).to include('metrics')
    expect(@driver.page_source).to include('Metrics')
  end

  it 'sort by "Database Name"' do
    @driver.find_elements(:css, 'table > thead > tr > th').find do |x|
      x.find_element(:css, 'a').click if x.text == 'Database Name'
    end
    expect(@driver.current_url).to include('order_by=name&order_type=asc')
    @driver.find_elements(:css, 'table > thead > tr > th').find do |x|
      x.find_element(:css, 'a').click if x.text == 'Database Name'
    end
    expect(@driver.current_url).to include('order_by=name&order_type=desc')
  end

  it 'sort by "Origin"' do
    @driver.find_elements(:css, 'table > thead > tr > th').find do |x|
      x.find_element(:css, 'a').click if x.text == 'Origin'
    end
    expect(@driver.current_url).to include('order_by=origin&order_type=asc')
    @driver.find_elements(:css, 'table > thead > tr > th').find do |x|
      x.find_element(:css, 'a').click if x.text == 'Origin'
    end
    expect(@driver.current_url).to include('order_by=origin&order_type=desc')
  end

  it 'sort by "Description"' do
    @driver.find_elements(:css, 'table > thead > tr > th').find do |x|
      x.find_element(:css, 'a').click if x.text == 'Description'
    end
    expect(@driver.current_url).to include('order_by=description&order_type=asc')
    @driver.find_elements(:css, 'table > thead > tr > th').find do |x|
      x.find_element(:css, 'a').click if x.text == 'Description'
    end
    expect(@driver.current_url).to include('order_by=description&order_type=desc')
  end

  it 'sort by "Series Count"' do
    @driver.find_elements(:css, 'table > thead > tr > th').find do |x|
      x.find_element(:css, 'a').click if x.text == 'Series Count'
    end
    expect(@driver.current_url).to include('order_by=series_count&order_type=asc')
    @driver.find_elements(:css, 'table > thead > tr > th').find do |x|
      x.find_element(:css, 'a').click if x.text == 'Series Count'
    end
    expect(@driver.current_url).to include('order_by=series_count&order_type=desc')
  end

  it 'sort by "Last update at"' do
    @driver.find_elements(:css, 'table > thead > tr > th').find do |x|
      x.find_element(:css, 'a').click if x.text == 'Last update at'
    end
    expect(@driver.current_url).to include('order_by=last_value_update&order_type=asc')
    @driver.find_elements(:css, 'table > thead > tr > th').find do |x|
      x.find_element(:css, 'a').click if x.text == 'Last update at'
    end
    expect(@driver.current_url).to include('order_by=last_value_update&order_type=desc')
  end

  it 'edit metric description' do
    name = @driver.find_element(:css, 'table > tbody > tr:nth-child(1) > td:nth-child(1)').text
    @driver.find_element(:css, 'table > tbody > tr:nth-child(1)').find_element(:class, 'edit-metric-button').click
    expect(@driver.find_element(:id, 'edit_metric_dialog').displayed?).to be_truthy
    expect(@driver.find_element(:id, 'metric_name').attribute('readonly')).to eql('true')
    @driver.find_element(:id, 'metric_description').clear
    @driver.find_element(:id, 'metric_description').send_key('test')
    @driver.find_element(:name, 'commit').click; sleep 5
    element = @driver.find_elements(:css, 'tbody > tr').select { |x| x.find_element(:css, 'td:nth-child(1)').text == name }
    expect(element.first.find_element(:css, 'td:nth-child(3)').text).to eql('test')
  end

  it 'edit metric watcher -percentage' do
    name = @driver.find_element(:css, 'table > tbody > tr:nth-child(1) > td:nth-child(1)').text
    # pick metric
    @driver.find_element(:css, 'table > tbody > tr:nth-child(1)').find_element(:class, 'edit-metric-button').click; sleep 5
    # editing metric
    @driver.find_element(:name, 'metric[metric_watcher_attributes][watcher_type]').find_elements(tag_name: 'option').find do |option|
      option.click if option.attribute('value') == 'percentage_change_metrics_last_period'
    end; sleep 3
    expect(@driver.find_element(:id, 'metric_metric_watcher_attributes_lower_threshold').displayed?).to be_truthy
    expect(@driver.find_element(:id, 'metric_metric_watcher_attributes_upper_threshold').displayed?).to be_truthy
    expect(@driver.find_element(:id, 'metric_metric_watcher_attributes_period').displayed?).to be_truthy
    @driver.find_element(:name, 'metric[metric_watcher_attributes][lower_threshold]').send_key('10')
    @driver.find_element(:name, 'metric[metric_watcher_attributes][upper_threshold]').send_key('10')
    @driver.find_element(:name, 'metric[metric_watcher_attributes][period]').send_key('10')
    @driver.find_element(:name, 'commit').click; sleep 5
    # check new params
    @driver.find_elements(:css, 'tbody > tr').select do |x|
      x.find_element(:class, 'edit-metric-button').click if x.find_element(:css, 'td:nth-child(1)').text == name
    end; sleep 5
    expect(@driver.find_element(:name, 'metric[metric_watcher_attributes][period]').attribute('value')).to eql('10')
    expect(@driver.find_element(:name, 'metric[metric_watcher_attributes][upper_threshold]').attribute('value')).to eql('10')
    expect(@driver.find_element(:name, 'metric[metric_watcher_attributes][lower_threshold]').attribute('value')).to eql('10')
    @driver.find_element(:id, 'edit_metric_dialog').find_element(:class, 'close').click
  end

  it 'edit metric watcher -sudden_dip' do
    name = @driver.find_element(:css, 'tbody > tr:nth-child(2) > td:nth-child(1)').text
    # pick metric
    @driver.find_element(:css, 'table > tbody > tr:nth-child(2)').find_element(:class, 'edit-metric-button').click; sleep 5
    # editing metric
    @driver.find_element(:name, 'metric[metric_watcher_attributes][watcher_type]').find_elements(tag_name: 'option').find do |option|
      option.click if option.attribute('value') == 'sudden_dip'
    end; sleep 3
    expect(@driver.find_element(:id, 'metric_metric_watcher_attributes_lower_threshold').displayed?).to be_truthy
    expect(@driver.find_element(:id, 'metric_metric_watcher_attributes_upper_threshold').displayed?).to be_truthy
    expect(@driver.find_element(:id, 'metric_metric_watcher_attributes_period').displayed?).to be_truthy
    @driver.find_element(:name, 'metric[metric_watcher_attributes][lower_threshold]').send_key('10')
    @driver.find_element(:name, 'metric[metric_watcher_attributes][upper_threshold]').send_key('10')
    @driver.find_element(:name, 'metric[metric_watcher_attributes][period]').send_key('10')
    @driver.find_element(:name, 'commit').click; sleep 5
    # check new params
    @driver.find_elements(:css, 'tbody > tr').select do |x|
      x.find_element(:class, 'edit-metric-button').click if x.find_element(:css, 'td:nth-child(1)').text == name
    end; sleep 5
    expect(@driver.find_element(:name, 'metric[metric_watcher_attributes][period]').attribute('value')).to eql('10')
    expect(@driver.find_element(:name, 'metric[metric_watcher_attributes][upper_threshold]').attribute('value')).to eql('10')
    expect(@driver.find_element(:name, 'metric[metric_watcher_attributes][lower_threshold]').attribute('value')).to eql('10')
    @driver.find_element(:id, 'edit_metric_dialog').find_element(:class, 'close').click
  end

  it 'edit metric watcher -metric limits' do
    name = @driver.find_element(:css, 'tbody > tr:nth-child(3) > td:nth-child(1)').text
    # pick metric
    @driver.find_elements(:css, 'tbody > tr').select do |x|
      x.find_element(:class, 'edit-metric-button').click if x.find_element(:css, 'td:nth-child(1)').text == name
    end; sleep 5
    # editing metric
    @driver.find_element(:name, 'metric[metric_watcher_attributes][watcher_type]').find_elements(tag_name: 'option').find do |option|
      option.click if option.attribute('value') == 'metric_limits'
    end; sleep 5
    expect(@driver.find_element(:id, 'metric_metric_watcher_attributes_lower_threshold').displayed?).to be_truthy
    expect(@driver.find_element(:id, 'metric_metric_watcher_attributes_upper_threshold').displayed?).to be_truthy
    @driver.find_element(:name, 'metric[metric_watcher_attributes][lower_threshold]').send_key('10')
    @driver.find_element(:name, 'metric[metric_watcher_attributes][upper_threshold]').send_key('10')
    @driver.find_element(:name, 'commit').click; sleep 5
    # check new params
    @driver.find_elements(:css, 'tbody > tr').select do |x|
      x.find_element(:class, 'edit-metric-button').click if x.find_element(:css, 'td:nth-child(1)').text == name
    end; sleep 5
    expect(@driver.find_element(:name, 'metric[metric_watcher_attributes][upper_threshold]').attribute('value')).to eql('10')
    expect(@driver.find_element(:name, 'metric[metric_watcher_attributes][lower_threshold]').attribute('value')).to eql('10')
    @driver.find_element(:id, 'edit_metric_dialog').find_element(:class, 'close').click
  end

  it 'switch off choosen metric watcher' do
    name = @driver.find_element(:css, 'table > tbody > tr:nth-child(1) > td:nth-child(1)').text
    @driver.find_element(:css, 'table > tbody > tr:nth-child(1)').find_element(:class, 'edit-metric-button').click; sleep 5
    @driver.find_element(:name, 'metric[metric_watcher_attributes][watcher_type]').find_elements(tag_name: 'option').find do |option|
      option.click if option.attribute('value') == ''
    end
    @driver.find_element(:name, 'commit').click; sleep 5
    @driver.find_elements(:css, 'tbody > tr').select do |x|
      x.find_element(:class, 'edit-metric-button').click if x.find_element(:css, 'td:nth-child(1)').text == name
    end; sleep 5
    # chech editing
    expect(@driver.find_element(:id, 'metric_metric_watcher_attributes_lower_threshold').displayed?).to be_falsey
    expect(@driver.find_element(:id, 'metric_metric_watcher_attributes_upper_threshold').displayed?).to be_falsey
    expect(@driver.find_element(:id, 'metric_metric_watcher_attributes_period').displayed?).to be_falsey
    # check params were reseted
    @driver.find_element(:name, 'metric[metric_watcher_attributes][watcher_type]').find_elements(tag_name: 'option').find do |option|
      option.click if option.attribute('value') == 'sudden_dip'
    end; sleep 5
    expect(@driver.find_element(:name, 'metric[metric_watcher_attributes][period]').attribute('value')).to eql('')
    expect(@driver.find_element(:name, 'metric[metric_watcher_attributes][upper_threshold]').attribute('value')).to eql('')
    expect(@driver.find_element(:name, 'metric[metric_watcher_attributes][lower_threshold]').attribute('value')).to eql('')
  end
end
