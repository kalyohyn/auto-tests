require 'spec_helper'

describe 'manage_alarms' do

  before(:all) do
    @driver = Selenium::WebDriver.for :firefox
    @driver.navigate.to('https://intel-staging.xcal.tv')
    @driver.find_element(:name => 'login').send_key('[FILTERED]')
    @driver.find_element(:name => 'password').send_key('[FILTERED]')
    @driver.find_element(:name => 'commit').submit
  end

  after(:all) do
    @driver.quit
  end

  it 'view alarms' do
    @driver.find_element(:id, 'profile_dropdown').click
    @driver.find_element(:link_text, 'Manage Alarms').click; sleep 5
    expect(@driver.current_url).to include('alarm_management')
    expect(@driver.find_element(:link_text, 'Create alarm').displayed?).to be_truthy
    expect(@driver.find_element(:id, 'alarm_management').find_elements(:css, 'tbody > tr').size).to eql(10)
  end

  it 'pagination' do
    expect(@driver.find_element(:class, 'pagedisplay').text).to include('1 to 10', 'page 1 of')
    # check per page
    @driver.find_element(:id, 'Per_page').find_elements(tag_name: 'option').find { |x| x.click if x.text == '25' }; sleep 5
    expect(@driver.find_element(:class, 'pagedisplay').text).to include('1 to 25')
    expect(@driver.find_element(:id, 'alarm_management').find_elements(:css, 'tbody > tr').size).to eql(25)
    # check next page
    @driver.find_element(:class, 'tablesorter-pager').find_element(:class, 'next').click; sleep 5
    expect(@driver.find_element(:class, 'pagedisplay').text).to include('page 2 of')
  end

  it 'add few columns' do
    @driver.navigate.refresh
    @driver.find_element(:class, 'btn-filter-menu').click
    el = @driver.find_element(:class, 'multiselect-container').find_elements(tag_name: 'li')
    el.find { |x| x.click if x.find_element(:class, 'checkbox').text == 'SOP' }
    el.find { |x| x.click if x.find_element(:class, 'checkbox').text == 'Added' }
    el.find { |x| x.click if x.find_element(:class, 'checkbox').text == 'SOP override' }
    @driver.find_element(:class, 'js-popover-tip-left').find_element(:class, 'icon-refresh').click; sleep 5
    element = @driver.find_element(:id, 'alarm_management').find_elements(:css, 'thead > tr > th').collect { |x| '+' if x.displayed? }
    expect(element.count('+')).to eql(8)
  end

  it 'remove few columns' do
    @driver.find_element(:class, 'btn-filter-menu').click
    el = @driver.find_element(:class, 'multiselect-container').find_elements(:class, 'active')
    el.find { |x| x.click if x.find_element(:class, 'checkbox').text == 'SOP' }
    el.find { |x| x.click if x.find_element(:class, 'checkbox').text == 'Added' }
    @driver.find_element(:class, 'js-popover-tip-left').find_element(:class, 'icon-refresh').click; sleep 5
    element = @driver.find_element(:id, 'alarm_management').find_elements(:css, 'thead > tr > th').collect { |x| '+' if x.displayed? }
    expect(element.count('+')).to eql(6)
  end

  it 'add all columns' do
    @driver.find_element(:class, 'btn-filter-menu').click
    @driver.find_element(:class, 'multiselect-all').click
    @driver.find_element(:class, 'icon-refresh').click; sleep 5
    element = @driver.find_element(:id, 'alarm_management').find_elements(:css, 'thead > tr > th').collect { |x| '+' if x.displayed? }
    expect(element.count('+')).to eql(18)
  end

  it 'create alarm with empty required fields' do
    @driver.find_element(:link_text, 'Create alarm').click; sleep 5
    expect(@driver.find_element(:id, 'create_alarm_dialog').displayed?).to be_truthy
    @driver.find_element(:id, 'create_alarm_dialog').find_element(:name, 'commit').click; sleep 5
    expect(@driver.find_element(:class, 'error').displayed?).to be_truthy
    @driver.find_element(:id, 'create_alarm_dialog').find_element(:class, 'close').click; sleep 5
    expect(@driver.find_element(:id, 'create_alarm_dialog').displayed?).to be_falsey
  end

  it 'create alarm' do
    # create new alarm
    @driver.find_element(:link_text, 'Create alarm').click; sleep 5
    @driver.find_element(:name, 'alarm[name]').send_key('alyohyn test')
    @driver.find_element(:name, 'alarm[originating_system]').send_key('Op5_nagios')
    @driver.find_element(:name, 'alarm[component]').send_key('test component')
    @driver.find_element(:name, 'alarm[primary_owner]').send_key('primary test')
    @driver.find_element(:name, 'alarm[secondary_owner]').send_key('secondary test')
    @driver.find_element(:name, 'alarm[impact_level]').send_key('low')
    @driver.find_element(:name, 'alarm[confidence_factor]').send_key('low')
    @driver.find_element(:name, 'alarm[impacted_business_process]').send_key('test')
    @driver.find_element(:name, 'alarm[service_desk]').send_key('test')
    @driver.find_element(:name, 'alarm[description]').send_key('test description')
    @driver.find_element(:name, 'alarm[ui_mapped_sop]').send_key('test sop')
    @driver.find_element(:name, 'alarm[sop]').send_key('http://blabla.bla')
    @driver.find_element(:name, 'alarm[sop_override]').send_key('test')
    @driver.find_element(:name, 'alarm[application_name]').send_key('test')
    @driver.find_element(:name, 'alarm[itrc_application_id]').send_key('test')
    @driver.find_element(:id, 'create_alarm_dialog').find_element(:name, 'commit').click; sleep 5
    # check alarm
    el = @driver.find_element(:id, 'alarm_management')
    el.find_element(:css, 'thead > tr > td:nth-child(1) > input').send_key('alyohyn test'); sleep 5
    expect(el.find_element(:css, 'tbody > tr:nth-child(1) > td:nth-child(1)').text).to eql('alyohyn test')
  end

  it 'edit alarm' do
    element = @driver.find_element(:id, 'alarm_management')
    element.find_element(:css, 'thead > tr > td:nth-child(1) > input').clear
    element.find_element(:css, 'thead > tr > td:nth-child(1) > input').send_key('alyohyn test'); sleep 3
    @driver.find_element(:css, 'tbody > tr:nth-child(1)').find_element(:class, 'edit_alarm_button').click; sleep 5
    # check some disabled fields
    begin
      @driver.find_element(:name, 'alarm[name]').send_key('')
      raise e
    rescue Selenium::WebDriver::Error::InvalidElementStateError
      expect(true).to be_truthy
    end
    begin
      @driver.find_element(:name, 'alarm[originating_system]').send_key('')
      raise e
    rescue Selenium::WebDriver::Error::InvalidElementStateError
      expect(true).to be_truthy
    end
    # change some fields
    @driver.find_element(:name, 'alarm[description]').clear
    @driver.find_element(:name, 'alarm[description]').send_key('new description')
    @driver.find_element(:name, 'alarm[application_name]').clear
    @driver.find_element(:name, 'alarm[application_name]').send_key('new application')
    @driver.find_element(:name, 'commit').click; sleep 5
    # check new fields values
    el = @driver.find_element(:id, 'alarm_management')
    el.find_element(:css, 'thead > tr > td:nth-child(1) > input').send_key('alyohyn test'); sleep 3
    expect(el.find_element(:css, 'tbody > tr:nth-child(1) > td:nth-child(9)').text).to eql('new description...')
    expect(el.find_element(:css, 'tbody > tr:nth-child(1) > td:nth-child(12)').text).to eql('new application')
  end

  it 'alarm actions page' do
    element = @driver.find_element(:id, 'alarm_management')
    element.find_element(:css, 'thead > tr > td:nth-child(1) > input').clear
    element.find_element(:css, 'thead > tr > td:nth-child(1) > input').send_key('alyohyn test'); sleep 3
    @driver.find_element(:css, 'tbody > tr:nth-child(1)').find_element(:class, 'manage_alarm_actions_button').click; sleep 5
    expect(@driver.current_url).to include('actions')
    expect(@driver.find_element(:link_text, 'Add action').displayed?).to be_truthy
  end

  it 'create action with empty required fields' do
    @driver.find_element(:link_text, 'Add action').click; sleep 5
    @driver.find_element(:id, 'update_alarm_action').click; sleep 5
    expect(@driver.find_elements(:class, 'error').size).to eql(4)
  end

  it 'create action' do
    @driver.find_element(:name, 'alarm_action[rule_attribute]').find_elements(:tag_name, 'option').find { |x| x.click if x.text == 'subject' }
    @driver.find_element(:name, 'alarm_action[rule_operator]').find_elements(:tag_name, 'option').find { |x| x.click if x.text == 'IN' }
    @driver.find_element(:name, 'alarm_action[rule_value]').send_key(1)
    @driver.find_element(:name, 'alarm_action[action_id]').find_elements(:tag_name, 'option').find { |x| x.click if x.text.include? 'jira' }; sleep 3
    # check errors appears with empty required fields
    @driver.find_element(:id, 'update_alarm_action').click; sleep 3
    expect(@driver.find_elements(:class, 'error').size).to eql(4)
    # switch action
    @driver.find_element(:name, 'alarm_action[action_id]').send_key('trigger pagerduty event'); sleep 3
    @driver.find_element(:name, 'alarm_action[action_id]').click; sleep 3
    @driver.find_element(:id, 'update_alarm_action').click; sleep 5
    # check new action
    expect(@driver.find_elements(:css, 'table > tbody > tr').size).to eql(1)
    expect(@driver.find_element(:css, 'table > tbody > tr > td:nth-child(1)').text).to eql('trigger pagerduty event')
    expect(@driver.find_element(:css, 'table > tbody > tr > td:nth-child(2)').text).to eql('if subject IN 1')
  end

  it 'create existed action' do
    @driver.find_element(:link_text, 'Add action').click; sleep 5
    @driver.find_element(:name, 'alarm_action[rule_attribute]').find_elements(:tag_name, 'option').find { |x| x.click if x.text == 'subject' }
    @driver.find_element(:name, 'alarm_action[rule_operator]').find_elements(:tag_name, 'option').find { |x| x.click if x.text == 'IN' }
    @driver.find_element(:name, 'alarm_action[rule_value]').send_key(1)
    @driver.find_element(:name, 'alarm_action[action_id]').send_key('trigger pagerduty event'); sleep 3
    @driver.find_element(:id, 'update_alarm_action').click; sleep 5
    expect(@driver.find_elements(:class, 'error').size).to eql(1)
    @driver.find_element(:link_text, 'Back').click
  end

  it 'edit alarm action' do
    @driver.find_element(:css, 'table > tbody > tr').find_element(:class, 'btn-info').click; sleep 5
    @driver.find_element(:name, 'alarm_action[rule_attribute]').send_key('host_groups')
    @driver.find_element(:name, 'alarm_action[rule_operator]').send_key('IS NOT')
    @driver.find_element(:name, 'alarm_action[rule_value]').send_key(1)
    @driver.find_element(:id, 'update_alarm_action').click; sleep 5
    # check action
    expect(@driver.find_element(:css, 'table > tbody > tr > td:nth-child(1)').text).to eql('trigger pagerduty event')
    expect(@driver.find_element(:css, 'table > tbody > tr > td:nth-child(2)').text).to eql('if host_groups IS NOT 11')
  end

  it 'delete alarm action' do
    # deletion action
    @driver.execute_script('window.confirm = function() {return true}')
    @driver.find_element(:css, 'table > tbody > tr').find_element(:class, 'btn-danger').click; sleep 5
    # check that action was deleted
    begin
      @driver.find_element(:css, 'table > tbody > tr > td:nth-child(1)')
      raise e
    rescue Selenium::WebDriver::Error::NoSuchElementError
      expect(true).to be_truthy
    end
  end

  it 'delete alarm' do
    @driver.navigate.to('https://intel-staging.xcal.tv/alarms/alarm_management'); sleep 5
    # find alarm
    element = @driver.find_element(:id, 'alarm_management')
    element.find_element(:css, 'thead > tr > td:nth-child(1) > input').clear
    element.find_element(:css, 'thead > tr > td:nth-child(1) > input').send_key('alyohyn test'); sleep 3
    # deletion alarm
    @driver.find_element(:css, 'tbody > tr:nth-child(1)').find_element(:class, 'edit_alarm_button').click; sleep 5
    @driver.execute_script('window.confirm = function() {return true}')
    @driver.find_element(:class, 'edit_alarm_dialog').find_element(:class, 'btn-danger').click; sleep 5
    expect(@driver.current_url).to include('alarm_management')
    # check alarm was deleted
    el = @driver.find_element(:id, 'alarm_management')
    el.find_element(:css, 'thead > tr > td:nth-child(1) > input').send_key('alyohyn test'); sleep 3
    expect(el.find_element(:css, 'tbody > tr:nth-child(1)').text).to eql('')
  end
end