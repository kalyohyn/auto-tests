require 'spec_helper'

describe 'Cleaners' do

  before(:all) do
    @driver = Selenium::WebDriver.for :firefox
    @driver.navigate.to 'localhost:3001'

    element = @driver.find_element(:id, 'user_groups')
    element.find_elements(:tag_name => 'option').find do |option|
      option.text == 'OIV_ADMIN'
    end.click
    @driver.find_element(:class, 'form-horizontal').find_element(:name, 'commit').click
  end

  after(:all) do
    @driver.quit
  end

  it 'view cleaners' do
    @driver.find_element(:id, 'profile_dropdown').click
    @driver.find_element(:link_text, 'Cleaners').click; sleep 5
    expect(@driver.current_url).to include('/cleaners')
    expect(@driver.page_source).to include('Api tasks', 'Collector task')
  end

  it 'collector tasks' do
    @driver.execute_script('window.confirm = function() {return true}')
    @driver.find_element(:css, 'div:nth-child(4) > form > div.pull-left > input').click; sleep 5
    expect(@driver.find_element(:class, 'alert-success').displayed?).to be_truthy
    expect(@driver.find_element(:class, 'alert-success').text).to eql("x\nCleaner has been scheduled!")
    @driver.find_element(:class, 'alert-success').find_element(:class, 'close').click; sleep 5
    begin
      @driver.find_element(:class, 'alert-success')
      raise e
    rescue Selenium::WebDriver::Error::NoSuchElementError
      expect(true).to be_truthy
    end
  end

  it 'api tasks' do
    @driver.find_element(:class, 'cleaner-tasks-multiselect').click
    @driver.execute_script('window.confirm = function() {return true}')
    @driver.find_element(:css, 'div:nth-child(3) > form > div.pull-left > input').click; sleep 5
    expect(@driver.find_element(:class, 'alert-success').displayed?).to be_truthy
  end

  it 'back button' do
    @driver.navigate.to('localhost:3001/metrics'); sleep 5
    @driver.find_element(:id, 'profile_dropdown').click
    @driver.find_element(:link_text, 'Cleaners').click; sleep 5
    expect(@driver.current_url).to include('cleaners')
    @driver.find_element(:link_text, 'Back').click; sleep 5
    expect(@driver.current_url).to include('metrics')
  end
end