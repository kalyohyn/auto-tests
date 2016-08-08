require 'spec_helper'

describe 'My Profile' do

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

  before(:each) do
    @driver.find_element(:id, 'profile_dropdown').click
    @driver.find_element(:link_text, 'My Profile').click; sleep 5
  end

  it 'time zone' do
    # set another time zone
    @driver.find_element(:id, 'user_profile_time_zone').send_key('Central Time')
    @driver.find_element(:name, 'commit').click; sleep 5
    # check new time zone
    expect(@driver.find_element(:class, 'alert-success').text).to eql ("x\nProfile Updated!")
    expect(@driver.find_element(:class, 'selected').find_element(:id, 'clock_cst').displayed?).to be_truthy
    # check alert notification
    @driver.find_element(:class, 'alert-success').find_element(:class, 'close').click; sleep 5
    begin
      @driver.find_element(:class, 'alert-success')
      raise e
    rescue Selenium::WebDriver::Error::NoSuchElementError
      expect(true).to be_truthy
    end
    # restore time zone to default
    @driver.find_element(:id, 'user_profile_time_zone').send_key('UTC')
    @driver.find_element(:name, 'commit').click
  end

  it 'email' do
    @driver.find_element(:id, 'user_profile_email').clear
    @driver.find_element(:id, 'user_profile_email').send_key('changeme@change.me')
    @driver.find_element(:name, 'commit').click; sleep 5
    expect(@driver.find_element(:class, 'alert-success').text).to eql ("x\nProfile Updated!")
    expect(@driver.find_element(:id, 'user_profile_email').attribute('value')).to eql ('changeme@change.me')
  end

  it 'links in a new tabs' do
    @driver.find_element(:id, 'user_profile_open_links_in_new_tab').click
    @driver.find_element(:name, 'commit').click; sleep 5
    expect(@driver.find_element(:class, 'alert-success').text).to eql ("x\nProfile Updated!")
  end

  it 'disabled notification' do
    @driver.find_element(:class, 'disabled_notifications').send_key('Global')
    @driver.find_element(:name, 'commit').click; sleep 5
    expect(@driver.find_element(:class, 'alert-success').text).to eql ("x\nProfile Updated!")
  end
end