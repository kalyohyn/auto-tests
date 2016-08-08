require 'spec_helper'

describe 'User login/logout' do

  before(:all) do
    @driver = Selenium::WebDriver.for :firefox #:chrome
    @driver.navigate.to 'https://intel-staging.xcal.tv'
  end

  after(:all) do
    @driver.quit
  end

  it 'invalid user' do
    @driver.find_element(:name, 'login').send_key('test')
    @driver.find_element(:name, 'password').send_key('test')
    @driver.find_element(:name, 'commit').submit
    expect(@driver.page_source).to include('The credentials you entered are wrong. Please, verify and re-submit the form below.')
  end

  it 'enter only login' do
    @driver.navigate.refresh
    @driver.find_element(:name, 'login').send_key('test')
    @driver.find_element(:name, 'commit').submit
    expect(@driver.page_source).to include('The credentials you entered are wrong. Please, verify and re-submit the form below.')
  end

  it 'enter only password' do
    @driver.navigate.refresh
    @driver.find_element(:name, 'password').send_key('test')
    @driver.find_element(:name, 'commit').submit
    expect(@driver.page_source).to include('The credentials you entered are wrong. Please, verify and re-submit the form below.')
  end

  it 'valid user' do
    @driver.navigate.refresh
    @driver.find_element(:name, 'login').send_key('[FILTERED]')
    @driver.find_element(:name, 'password').send_key('[FILTERED]')
    @driver.find_element(:name, 'commit').submit; sleep 5
    expect(@driver.current_url).to eql('https://intel-staging.xcal.tv/')

    expect(@driver.find_element(:class, 'center').text).to eql ('Open High Severity Incidents')
    expect(@driver.find_element(:class, 'release-footer').displayed?).to be_truthy
    expect(@driver.find_element(:class, 'selected').find_element(:id, 'clock_utc').displayed?).to be_truthy
  end

  it 'logout' do
    @driver.find_element(:id, 'profile_dropdown').click
    @driver.find_element(:link_text, 'Sign out').click
    expect(@driver.current_url).to include('users/sign_in')
    expect(@driver.page_source).to include('Session expired')
  end

  it 'third-party_provider' do
    element = @driver.find_element(:name, 'identity_provider')
    element.find_elements(:tag_name, 'option').find do |option|
      option.text == 'cox'
    end.click
    @driver.find_element(:name, 'button').click
    expect(@driver.current_url).to include('sso.dev.cox.com/')

    @driver.find_element(:id, 'ContentPlaceHolder1_UsernameTextBox').send_key('[FILTERED]')
    @driver.find_element(:id, 'ContentPlaceHolder1_PasswordTextBox').send_key('[FILTERED]')
    @driver.find_element(:id, 'ContentPlaceHolder1_SubmitButton').click; sleep 5
    expect(@driver.current_url).to eql('https://96.119.145.125/')
    expect(@driver.find_element(:link_text, 'a1ssotest@CORP.COX.com'))
  end
end
