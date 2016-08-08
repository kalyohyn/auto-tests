#
# After testing - destroy all created notification by UI-staging console:
#           Notification.where("title LIKE 'alyohyn test%'").destroy_all
#

require 'spec_helper'

describe 'Manage Notifications' do

  before(:all) do
    @date = (Time.now + 1.days).strftime('%Y-%m-%d %H-%M-%S')
    @driver = Selenium::WebDriver.for :firefox
    @driver.navigate.to('https://intel-staging.xcal.tv')
    @driver.find_element(:name => 'login').send_key('[FILTERED]')
    @driver.find_element(:name => 'password').send_key('[FILTERED]')
    @driver.find_element(:name => 'commit').submit
  end

  after(:all) do
    @driver.quit
  end

  context 'notification functionality' do

    before(:all) do
      @driver.navigate.to('https://intel-staging.xcal.tv/notifications'); sleep 5
    end

    it 'create notification with invalid params' do
      @driver.find_element(:class, 'notification_button').click; sleep 5
      expect(@driver.find_element(:id, 'notification_dialog').displayed?).to be_truthy
      @driver.find_element(:id, 'notification_dialog').find_element(:name, 'commit').click; sleep 5
      expect(@driver.find_elements(:class, 'error').size).to eql(2)
      # check title field
      @driver.find_element(:id, 'notification_title').send_key('012345678')
      @driver.find_element(:id, 'notification_dialog').find_element(:name, 'commit').click
      expect(@driver.find_elements(:class, 'error').size).to eql(2)
      @driver.find_element(:id, 'notification_dialog').find_element(:class, 'close').click
      expect(@driver.find_element(:id, 'notification_dialog').displayed?).to be_falsey
    end

    it 'create new notification' do
      @driver.find_element(:class, 'notification_button').click; sleep 5
      @driver.find_element(:id, 'notification_title').send_key('alyohyn test')
      @driver.find_element(:id, 'notification_body').send_key('My test notification')
      @driver.find_element(:id, 'notification_type').send_key('Landing')
      @driver.find_element(:id, 'notification_expire_at').send_key(@date)
      @driver.find_element(:id, 'notification_dialog').find_element(:name, 'commit').click; sleep 5
      element = @driver.find_elements(:css, 'table > tbody > tr').collect { |x| x.find_element(:css, 'td:nth-child(1)').text }
      expect(element).to include('alyohyn test')
      expect(@driver.find_element(:class, 'notification-indicator').attribute('title')).to eql('You have unread notifications')
    end

    it 'view notification' do
      @driver.find_element(:id, 'profile_dropdown').click
      @driver.find_element(:link_text, 'Manage Notifications').click; sleep 5
      @driver.find_elements(:css, 'table > tbody > tr').find do |x|
        x.find_element(:css, 'td:nth-child(1) > a').click if x.find_element(:css, 'td:nth-child(1)').text == 'alyohyn test'
      end; sleep 5
      expect(@driver.current_url).to include('notifications')
      expect(@driver.find_element(:class, 'notification_header').text).to eql('alyohyn test')
      expect(@driver.find_element(:class, 'well').text).to eql('My test notification')
      expect(@driver.find_element(:class, 'notification-indicator').find_element(:class, 'unread').displayed?).to be_truthy
    end

    it 'edit notification' do
      # open edit window
      @driver.find_element(:class, 'notification_button').click
      expect(@driver.find_element(:id, 'notification_dialog').displayed?).to be_truthy
      # change params
      @driver.find_element(:id, 'notification_title').send_key(' test')
      @driver.find_element(:id, 'notification_body').clear
      @driver.find_element(:id, 'notification_body').send_key('My edited notification')
      @driver.find_element(:id, 'notification_type').send_key('Global')
      @driver.find_element(:id, 'notification_dialog').find_element(:name, 'commit').click; sleep 5
      # check edited notification
      element = @driver.find_elements(:css, 'table > tbody > tr').collect { |x| x.find_element(:css, 'td:nth-child(1)').text }
      expect(element).to include('alyohyn test test')
      el = @driver.find_elements(:css, 'table > tbody > tr').find do |x|
        x.find_element(:css, 'td:nth-child(1)').text == 'alyohyn test test'
      end
      expect(el.find_element(:css, 'td:nth-child(2)').text).to eql('Global')
      expect(@driver.find_element(:class, 'notification-indicator').find_element(:class, 'unread').displayed?).to be_truthy
    end

    it 'read notification' do
      # pick and read notification
      @driver.find_element(:class, 'notification-indicator').click; sleep 5
      expect(@driver.find_element(:id, 'unread-notifications').find_elements(:class, 'unread').size).to be >= 1
      @driver.find_elements(:css, 'table > tbody > tr').find do |x|
        x.find_element(:css, 'td:nth-child(1) > a').click if x.find_element(:css, 'td:nth-child(1)').text == 'alyohyn test test'
      end; sleep 5
      @driver.find_element(:link_text, 'Back').click; sleep 5
      # check that notification was read
      element = @driver.find_element(:id, 'unread-notifications').find_elements(:css, 'table > tbody > tr').collect do |x|
        x.find_element(:css, 'td:nth-child(1)').text
      end
      expect(element.include?('alyohyn test test')).to be_falsey
      begin
        @driver.find_element(:class, 'notification-indicator').find_element(:class, 'unread')
        raise e
      rescue Selenium::WebDriver::Error::NoSuchElementError
        expect(true).to be_truthy
      end
      # check that notification appears ass 'all notifications'
      @driver.find_element(:css, '.nav-tabs > li:nth-child(3) > a:nth-child(1)').click
      el = @driver.find_element(:id, 'all-notifications').find_elements(:css, 'table > tbody > tr').collect do |x|
        x.find_element(:css, 'td:nth-child(1)').text
      end
      expect(el).to include('alyohyn test test')
    end

    it 'delete notification' do
      @driver.navigate.to('https://intel-staging.xcal.tv/notifications'); sleep 5
      @driver.execute_script('window.confirm = function() {return true}')
      @driver.find_elements(:css, 'table > tbody > tr').find do |x|
        x.find_element(:class, 'btn-danger').click if x.find_element(:css, 'td:nth-child(1)').text == 'alyohyn test test'
      end
      # check that notification was deleted
      element = @driver.find_elements(:css, 'table > tbody > tr').collect { |x| x.find_element(:css, 'td:nth-child(1)').text }
      expect(element.include?('alyohyn test test')).to be_falsey
    end
  end

  context 'landing page notification' do
    it 'create landing page notification' do
      @driver.navigate.to('https://intel-staging.xcal.tv/notifications'); sleep 5
      # create new notification
      @driver.find_element(:class, 'notification_button').click; sleep 5
      @driver.find_element(:id, 'notification_title').send_key('alyohyn test landing')
      @driver.find_element(:id, 'notification_body').send_key('My test notification')
      @driver.find_element(:id, 'notification_type').send_key('Landing')
      @driver.find_element(:id, 'notification_expire_at').send_key(@date)
      @driver.find_element(:id, 'notification_dialog').find_element(:name, 'commit').click; sleep 5
      # check created notification
      el = @driver.find_elements(:css, 'table > tbody > tr').find do |x|
        x.find_element(:css, 'td:nth-child(1)').text == 'alyohyn test landing'
      end
      expect(el.find_element(:css, 'td:nth-child(2)').text).to eql('Landing page only')
    end

    it 'disabled landing page notification' do
      # select disabled param
      @driver.find_element(:id, 'profile_dropdown').click
      @driver.find_element(:link_text, 'My Profile').click; sleep 5
      @driver.find_element(:class, 'disabled_notifications').send_key('Landing page only')
      @driver.find_element(:name, 'commit').click; sleep 5
      # check landing page
      @driver.navigate.to('https://intel-staging.xcal.tv'); sleep 5
      begin
        @driver.find_element(:class, 'notification')
        raise e
      rescue Selenium::WebDriver::Error::NoSuchElementError
        expect(true).to be_truthy
      end
      @driver.find_element(:id, 'profile_dropdown').click
      @driver.find_element(:link_text, 'My Profile').click; sleep 5
      @driver.find_element(:class, 'disabled_notifications').send_key('Dashboard')
      @driver.find_element(:name, 'commit').click; sleep 5
    end

    it 'check landing page notification' do
      @driver.navigate.to('https://intel-staging.xcal.tv'); sleep 5
      expect(@driver.find_element(:class, 'notification').displayed?).to be_truthy
      expect(@driver.find_element(:class, 'notification').text).to include('alyohyn test landing')
      @driver.find_element(:class, 'notification-read-more').click; sleep 5
      expect(@driver.current_url).to include('notifications')
      expect(@driver.find_element(:class, 'notification_header').text).to eql('alyohyn test landing')
      expect(@driver.find_element(:class, 'well').text).to eql('My test notification')
      expect(@driver.find_element(:class, 'notification-indicator').attribute('title')).to eql('You have no unread notifications')
    end
  end

  context 'global notification' do
    it 'create global notification' do
      @driver.navigate.to('https://intel-staging.xcal.tv/notifications'); sleep 5
      # create new notification
      @driver.find_element(:class, 'notification_button').click; sleep 5
      @driver.find_element(:id, 'notification_title').send_key('alyohyn test global')
      @driver.find_element(:id, 'notification_body').send_key('My test notification')
      @driver.find_element(:id, 'notification_type').send_key('Global')
      @driver.find_element(:id, 'notification_expire_at').send_key(@date)
      @driver.find_element(:id, 'notification_dialog').find_element(:name, 'commit').click; sleep 5
      # check created notification
      el = @driver.find_elements(:css, 'table > tbody > tr').find do |x|
        x.find_element(:css, 'td:nth-child(1)').text == 'alyohyn test global'
      end
      expect(el.find_element(:css, 'td:nth-child(2)').text).to eql('Global')
      # check notification appears
      expect(@driver.find_element(:class, 'notification').displayed?).to be_truthy
      expect(@driver.find_element(:class, 'notification').text).to include('alyohyn test global')
      @driver.navigate.to('https://intel-staging.xcal.tv/logs'); sleep 5
      expect(@driver.find_element(:class, 'notification').displayed?).to be_truthy
    end

    it 'disabled global notification' do
      # select disabled param
      @driver.find_element(:id, 'profile_dropdown').click
      @driver.find_element(:link_text, 'My Profile').click; sleep 5
      @driver.find_element(:class, 'disabled_notifications').send_key('Global')
      @driver.find_element(:name, 'commit').click; sleep 5
      # check landing page
      @driver.navigate.to('https://intel-staging.xcal.tv'); sleep 5
      begin
        @driver.find_element(:class, 'notification')
        raise e
      rescue Selenium::WebDriver::Error::NoSuchElementError
        expect(true).to be_truthy
      end
      @driver.find_element(:id, 'profile_dropdown').click
      @driver.find_element(:link_text, 'My Profile').click; sleep 5
      @driver.find_element(:class, 'disabled_notifications').send_key('Landing page only')
      @driver.find_element(:name, 'commit').click; sleep 5
      expect(@driver.find_element(:class, 'notification').displayed?).to be_truthy
    end

    it 'close notification alert' do
      @driver.find_element(:class, 'notification').find_element(:class, 'close').click; sleep 5
      expect(@driver.find_element(:class, 'notification-indicator').attribute('title')).to eql('You have no unread notifications')
      @driver.find_element(:class, 'notification-indicator').click; sleep 5
      el = @driver.find_element(:id, 'unread-notifications').find_elements(:css, 'table > tbody > tr').collect do |x|
        x.find_element(:css, 'td:nth-child(1)').text
      end
      expect(el.include?('alyohyn test global')).to be_falsey
    end
  end

  context 'dashboard notification' do
    it 'create dashboard notification' do
      @driver.navigate.to('https://intel-staging.xcal.tv/notifications'); sleep 5
      # create new notification
      @driver.find_element(:class, 'notification_button').click; sleep 5
      @driver.find_element(:id, 'notification_title').send_key('alyohyn test dashboard')
      @driver.find_element(:id, 'notification_body').send_key('My test notification')
      @driver.find_element(:id, 'notification_expire_at').send_key(@date)
      @driver.find_element(:id, 'notification_type').find_elements(:tag_name, 'option').find { |x| x.click if x.text == 'Dashboard' }; sleep 5
      @driver.find_element(:id, 'notification_dashboards').send_key('kalyohyn dash')
      @driver.find_element(:id, 'notification_dialog').find_element(:name, 'commit').click; sleep 5
      # check created notification
      el = @driver.find_elements(:css, 'table > tbody > tr').find do |x|
        x.find_element(:css, 'td:nth-child(1)').text == 'alyohyn test dashboard'
      end
      expect(el.find_element(:css, 'td:nth-child(2)').text).to eql('Dashboard')
    end

    it 'check notification appears' do
      expect(@driver.find_element(:class, 'notification-indicator').attribute('title')).to eql('You have no unread notifications')
      # check notification on unselected dash
      @driver.find_element(:id, 'dashboards_dropdown_full').click
      @driver.find_element(:link_text, 'XB3 Devices').click; sleep 5
      expect(@driver.find_element(:class, 'notification-indicator').attribute('title')).to eql('You have no unread notifications')
      # check notification on valid dash
      @driver.find_element(:id, 'dashboards_dropdown_full').click
      @driver.find_element(:link_text, 'kalyohyn dash').click; sleep 5
      expect(@driver.find_element(:class, 'notification').displayed?).to be_truthy
      expect(@driver.find_element(:class, 'notification').text).to include('alyohyn test dashboard')
    end

    it 'disabled dashboard notification' do
      # select disabled param
      @driver.find_element(:id, 'profile_dropdown').click
      @driver.find_element(:link_text, 'My Profile').click; sleep 5
      @driver.find_element(:class, 'disabled_notifications').send_key('Dasboard')
      @driver.find_element(:name, 'commit').click; sleep 5
      # check dashboard
      @driver.find_element(:id, 'dashboards_dropdown_full').click
      @driver.find_element(:link_text, 'kalyohyn dash').click; sleep 5
      begin
        @driver.find_element(:class, 'notification')
        raise e
      rescue Selenium::WebDriver::Error::NoSuchElementError
        expect(true).to be_truthy
      end
    end
  end
end