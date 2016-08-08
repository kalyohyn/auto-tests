#
# After test delete all created alarms at staging api console:
#    Alarm.where("name LIKE 'kalyoh_test%'").destroy_all
#

require 'spec_helper'

describe 'Upload alarms' do

  before(:all) do
    @upload_dir = File.join(Dir.pwd, 'spec/gui_tests/Uploads')
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
    @driver.navigate.to('https://intel-staging.xcal.tv/alarm_uploads')
  end

  it 'view upload alarms' do
    # check notification window open/close
    expect(@driver.current_url).to include('/alarm_uploads')
    @driver.find_element(:class, 'icon-question-sign').click
    expect( @driver.find_element(:class, 'alarms-upload-hint').displayed?).to be_truthy
    @driver.find_element(:class, 'icon-question-sign').click
    expect( @driver.find_element(:class, 'alarms-upload-hint').displayed?).to be_truthy
  end

  it 'upload alarm' do
    filename = 'alarm.csv'
    file = File.join(@upload_dir, filename)
    @driver.find_element(:class, 'controls').find_element(:name, 'files[]').send_key(file)
    @driver.find_element(:name, 'commit').click; sleep 5
    expect(@driver.find_element(:class, 'alert-notice').displayed?).to be_truthy
    expect(@driver.find_element(:class, 'alert-notice').text).to include('Successfully uploaded!')
    @driver.find_element(:class, 'alert-notice').find_element(:class, 'close').click; sleep 5
    begin
      @driver.find_element(:class, 'alert-notice')
      raise e
    rescue Selenium::WebDriver::Error::NoSuchElementError
      expect(true).to be_truthy
    end
    # check new alarm
    @driver.navigate.to('https://intel-staging.xcal.tv/alarms/alarm_management'); sleep 5
    @driver.find_element(:id, 'alarm_management').find_element(:css, 'thead > tr > td:nth-child(1) > input').send_key('kalyoh_test'); sleep 3
    expect(@driver.find_element(:id, 'alarm_management').find_element(:css, 'tbody > tr:nth-child(1) > td:nth-child(1)').text).to eql('kalyoh_test')
  end

  it 'upload alarms' do
    filename = 'alarms.csv'
    file = File.join(@upload_dir, filename)
    @driver.find_element(:class, 'controls').find_element(:name, 'files[]').send_key(file)
    @driver.find_element(:name, 'commit').click; sleep 5
    expect(@driver.find_element(:class, 'alert-notice').displayed?).to be_truthy
    expect(@driver.find_element(:class, 'alert-notice').text).to include('Successfully uploaded!')
    @driver.find_element(:class, 'alert-notice').find_element(:class, 'close').click; sleep 5
    begin
      @driver.find_element(:class, 'alert-notice')
      raise e
    rescue Selenium::WebDriver::Error::NoSuchElementError
      expect(true).to be_truthy
    end
    # check new alarms
    @driver.navigate.to('https://intel-staging.xcal.tv/alarms/alarm_management'); sleep 5
    @driver.find_element(:id, 'alarm_management').find_element(:css, 'thead > tr > td:nth-child(1) > input').send_key('kalyoh_test'); sleep 3
    expect(@driver.find_element(:id, 'alarm_management').find_elements(:css, 'table > tbody > tr').size).to eql(4)
  end

  it 'upload invalid file' do
    filename = 'error import.yml'
    file = File.join(@upload_dir, filename)
    @driver.find_element(:class, 'controls').find_element(:name, 'files[]').send_key(file)
    @driver.find_element(:name, 'commit').click; sleep 5
    expect(@driver.find_element(:class, 'alert-error').displayed?).to be_truthy
    expect(@driver.find_element(:class, 'alert-error').text).to eql("x\nIncorrect data in csv row [\"---\"]")
    @driver.find_element(:class, 'alert-error').find_element(:class, 'close').click; sleep 5
    begin
      @driver.find_element(:class, 'alert-error')
      raise e
    rescue Selenium::WebDriver::Error::NoSuchElementError
      expect(true).to be_truthy
    end
  end

  it 'upload txt file with invalid content' do
    filename = 'wrong.txt'
    file = File.join(@upload_dir, filename)
    @driver.find_element(:class, 'controls').find_element(:name, 'files[]').send_key(file)
    @driver.find_element(:name, 'commit').click; sleep 5
    expect(@driver.find_element(:class, 'alert-error').displayed?).to be_truthy
    expect(@driver.find_element(:class, 'alert-error').text).to eql("x\nIncorrect data in csv row [\"wrong text\"]")
  end

  it 'upload csv file with invalid content' do
    filename = 'wrong_alarm.csv'
    file = File.join(@upload_dir, filename)
    @driver.find_element(:class, 'controls').find_element(:name, 'files[]').send_key(file)
    @driver.find_element(:name, 'commit').click; sleep 5
    expect(@driver.find_element(:class, 'alert-error').displayed?).to be_truthy
    expect(@driver.find_element(:class, 'alert-error').text).to eql("x\nIncorrect data in csv row [\"name \"]")
  end
end