require 'spec_helper'

describe 'Manage Actions' do

  before(:all) do
    @driver = Selenium::WebDriver.for :firefox
    @driver.navigate.to('https://intel-staging.xcal.tv')
    @driver.find_element(:name => 'login').send_key('[FILTERED]')
    @driver.find_element(:name => 'password').send_key('[FILTERED]')
    @driver.find_element(:name => 'commit').submit
    # get existed action params
    @driver.navigate.to('https://intel-staging.xcal.tv/actions'); sleep 5
    @name = @driver.find_elements(:css, 'table > tbody > tr').first.find_element(:css, 'td:nth-child(1)').text
    @descr = @driver.find_elements(:css, 'table > tbody > tr').first.find_element(:css, 'td:nth-child(2)').text
    @action = @driver.find_elements(:css, 'table > tbody > tr').first.find_element(:css, 'td:nth-child(3)').text
  end

  after(:all) do
    # restore action
    @driver.navigate.to('https://intel-staging.xcal.tv/actions')
    @driver.find_element(:class, 'create_action_button').click; sleep 5
    @driver.find_element(:name, 'alarm_action[name]').send_key('trigger pagerduty event')
    @driver.find_element(:name, 'alarm_action[description]').send_key('Trigger Pagerduty Event')
    @driver.find_element(:name, 'alarm_action[action_method]').send_key('trigger_pagerduty_event')
    @driver.find_element(:name, 'commit').click
    @driver.quit
  end

  it 'view action' do
    # open action and check params
    @driver.find_elements(:css, 'table > tbody > tr').first.find_element(:css, 'td:nth-child(1) > a').click
    expect(@driver.find_element(:class, 'table-condensed').displayed?).to be_truthy
    expect(@driver.find_element(:css, 'tr:nth-child(1) > td').text).to eql(@name)
    expect(@driver.find_element(:css, 'tr:nth-child(2) > td').text).to eql(@descr)
    expect(@driver.find_element(:css, 'tr:nth-child(3) > td').text).to eql(@action)
  end

  it 'create new action with existed action_method' do
    @driver.navigate.to('https://intel-staging.xcal.tv/actions')
    # create action with this params
    @driver.find_element(:class, 'create_action_button').click; sleep 5
    @driver.find_element(:name, 'alarm_action[name]').clear
    @driver.find_element(:name, 'alarm_action[name]').send_key(@name)
    @driver.find_element(:name, 'alarm_action[action_method]').send_key(@action)
    @driver.find_element(:name, 'commit').click; sleep 5
    # check error occurs
    expect(@driver.find_elements(:class, 'error').size).to eql(2)
    @driver.find_element(:class, 'close').click
  end

  it 'create new action with empty required fields' do
    # create new action without params
    @driver.find_element(:class, 'create_action_button').click; sleep 5
    @driver.find_element(:name, 'commit').click; sleep 5
    @driver.find_element(:name, 'alarm_action[name]').clear
    # check error occurs
    expect(@driver.find_elements(:class, 'error').size).to eql(2)
    @driver.find_element(:class, 'close').click
  end

  it 'delete action from edit action mode' do
    # pick action and delete it
    element = @driver.find_elements(:css, 'table > tbody > tr')
    name = element.first.find_element(:css, 'td:nth-child(1)').text
    rows = @driver.find_element(:class, 'table-hover').find_elements(:css, 'tbody > tr').size
    element.first.find_elements(:class, 'btn').find { |x| x.click if x.text == 'Edit' }; sleep 5
    @driver.execute_script('window.confirm = function() {return true}')
    @driver.find_element(:class, 'btn-danger').click; sleep 5
    expect(@driver.find_elements(:css, 'table > tbody > tr').size).to be <= rows
    expect(@driver.find_elements(:css, 'tbody > tr').collect { |x| x.find_element(:css, 'td:nth-child(1)').text }.include?(name)).to be_falsey
  end

  it 'create new action' do
    # create new action
    rows = @driver.find_element(:class, 'table-hover').find_elements(:css, 'tbody > tr').size
    @driver.find_element(:class, 'create_action_button').click; sleep 5
    @driver.find_element(:name, 'alarm_action[name]').send_key(@name)
    @driver.find_element(:name, 'alarm_action[description]').send_key(@descr)
    @driver.find_element(:name, 'alarm_action[action_method]').send_key(@action)
    @driver.find_element(:name, 'commit').click; sleep 5
    # check that new action was created
    expect(@driver.find_elements(:css, 'table > tbody > tr').size).to be > rows
    expect(@driver.find_elements(:css, 'table > tbody > tr').collect { |x| x.find_element(:css, 'td:nth-child(1)').text }).to include(@name)
  end

  it 'edit action' do
    # pick action and editing it
    element = @driver.find_element(:class, 'table-hover').find_elements(:css, 'tbody > tr')
    element.first.find_elements(:class, 'btn').find { |x| x.click if x.text == 'Edit' }; sleep 5
    @driver.find_element(:name, 'alarm_action[name]').clear
    @driver.find_element(:name, 'alarm_action[name]').send_key('edit_action')
    @driver.find_element(:name, 'alarm_action[description]').clear
    @driver.find_element(:name, 'alarm_action[description]').send_key('Edit Action')
    @driver.find_element(:name, 'commit').click; sleep 5
    expect(@driver.find_elements(:css, 'tbody > tr').collect { |x| x.find_element(:css, 'td:nth-child(1)').text }).to include('edit_action')
    expect(@driver.find_elements(:css, 'tbody > tr').collect { |x| x.find_element(:css, 'td:nth-child(2)').text }).to include('Edit Action')
  end

  it 'check alarm#actions' do
    @driver.navigate.to('https://intel-staging.xcal.tv/alarms/alarm_management'); sleep 5
    @driver.find_element(:css, 'tbody > tr:nth-child(1)').find_element(:class, 'manage_alarm_actions_button').click; sleep 5
    @driver.find_element(:class, 'btn-primary').click; sleep 5
    element = @driver.find_element(:id, 'alarm_action_action_id').find_elements(:tag_name, 'option')
    expect( element.collect { |x| x.text }).to include('edit_action')
  end

  it 'delete action' do
    @driver.navigate.to('https://intel-staging.xcal.tv/actions'); sleep 5
    @driver.execute_script('window.confirm = function() {return true}')
    element = @driver.find_elements(:css, 'table > tbody > tr')
    rows = element.size
    element.find { |x| x.find_element(:class, 'btn-danger').click if x.find_element(:css, 'td:nth-child(1)').text == 'edit_action' }; sleep 5
    expect(@driver.find_elements(:css, 'table > tbody > tr').size).to be <= rows
    expect(@driver.find_elements(:css, 'tbody > tr').collect { |x| x.find_element(:css, 'td:nth-child(1)').text }.include?('edit_action')).to be_falsey
  end
end