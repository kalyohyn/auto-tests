require 'spec_helper'

describe 'dashboards' do

  before(:all) do
    @driver = Selenium::WebDriver.for :firefox
    @driver.navigate.to 'https://intel-staging.xcal.tv'
    @driver.find_element(:name => 'login').send_key('[FILTERED]')
    @driver.find_element(:name => 'password').send_key('[FILTERED]')
    @driver.find_element(:name => 'commit').submit
  end

  after(:all) do
    @driver.quit
  end

  it 'Multi-tenant by default' do
    expect(@driver.current_url).to eql('https://intel-staging.xcal.tv/')
    expect(@driver.find_element(:class, 'tenant-name').text).to eql('Multi-tenant')
  end

  it 'Cox-tenant' do
    @driver.find_element(:class, 'tenant-name').click
    @driver.find_element(:link_text, 'cox').click
    expect(@driver.find_element(:class, 'tenant-name').text).to eql('cox')
    expect(@driver.find_element(:class, 'cox-partner').displayed?).to be_truthy
  end

  it 'Shaw-tenant' do
    @driver.find_element(:class, 'tenant-name').click
    @driver.find_element(:link_text, 'shaw').click
    expect(@driver.find_element(:class, 'tenant-name').text).to eql('shaw')
    expect(@driver.find_element(:class, 'shaw-partner').displayed?).to be_truthy
  end

  it 'Multi-tenant' do
    @driver.find_element(:class, 'tenant-name').click
    @driver.find_element(:link_text, 'Multi-tenant').click
    expect(@driver.find_element(:class, 'tenant-name').text).to eql('Multi-tenant')
    expect(@driver.find_element(:class, 'general-partner').displayed?).to be_truthy
  end
end

