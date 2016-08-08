require 'spec_helper'

describe 'Support' do

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

  it 'view support' do
    @driver.find_element(:id, 'profile_dropdown').click
    @driver.find_element(:link_text, 'Support').click; sleep 5
    expect(@driver.current_url).to include('/access_requests')
    expect(@driver.page_source).to include('Application Support', 'Application Access', 'API Access')
    expect(@driver.find_element(:link_text, 'T&P_Production_Support@cable.comcast.com').attribute('href')).to eql('mailto:T%26P_Production_Support@cable.comcast.com')
    expect(@driver.find_element(:link_text, 'XIDM').attribute('href')).to eql('https://xidm.ccp.xcal.tv/xidmoivauto')
    expect(@driver.find_element(:link_text, 'T&P_OPSENIntake@cable.comcast.com').attribute('href')).to eql('mailto:T%26P_OPSENIntake@cable.comcast.com')
    @driver.find_element(:link_text, 'Documentation on the API').click; sleep 5
    expect(@driver.current_url).to include('www.teamccp.com/confluence')
    @driver.navigate.back
  end

end