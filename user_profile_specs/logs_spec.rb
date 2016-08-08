require 'spec_helper'

describe 'logs' do

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
    @driver.find_element(:link_text, 'Logs').click; sleep 5
  end

  it 'view logs' do
    @driver.find_element(:id, 'profile_dropdown').click
    @driver.find_element(:link_text, 'Logs').click; sleep 5
    expect(@driver.current_url).to include('logs')
    expect(@driver.page_source).to include('Logged user actions')
  end

  it 'search' do
    @driver.find_element(:class, 'form-search').find_element(:name, 'query').send_key('blabla')
    @driver.find_element(:class, 'form-search').find_element(:name, 'commit').click; sleep 5
    # check query
    expect(@driver.current_url).to include('query=blabla&commit=Search')
    expect(@driver.find_element(:class, 'form-search').find_element(:name, 'query').attribute('value')).to eql('blabla')
    # switch log type
    @driver.find_element(:link_text, 'Switch to Security Audit Logs').click; sleep 5
    expect(@driver.find_element(:class, 'form-search').find_element(:name, 'query').attribute('value')).to eql('')
    @driver.find_element(:class, 'form-search').find_element(:name, 'query').send_key('blabla')
    @driver.find_element(:class, 'form-search').find_element(:name, 'commit').click; sleep 5
    expect(@driver.current_url).to include('query=blabla&commit=Search')
  end

  it 'security audit/ordinal logs' do
    @driver.find_element(:link_text, 'Switch to Security Audit Logs').click; sleep 5
    expect(@driver.current_url).to include('/logs?security_audit=')
    expect(@driver.page_source).to include('Security audit')
    expect(@driver.find_element(:link_text, 'Switch to ordinal Logs').displayed?).to be_truthy
    @driver.find_element(:link_text, 'Switch to ordinal Logs').click; sleep 5
    expect(@driver.current_url).to include('logs')
  end
end