require 'spec_helper'

describe 'widgets adding/functional' do

  before(:all) do
    @name = 'kalyohyn dash'
    @wait = Selenium::WebDriver::Wait.new(:timeout => 30)
    @driver = Selenium::WebDriver.for :firefox
    @driver.navigate.to('https://intel-staging.xcal.tv')
    @driver.find_element(:name => 'login').send_key('[FILTERED]')
    @driver.find_element(:name => 'password').send_key('[FILTERED]')
    @driver.find_element(:name => 'commit').submit
  end

  after(:all) do
    @driver.quit
  end

  context '-chart widget' do
    it 'add chart widget with empty required fields' do
      @driver.find_element(:id, 'dashboards_dropdown_full').click
      @driver.find_element(:link_text, @name).click
      @driver.find_element(:link_text, 'Add widget').click
      @driver.find_element(:id, 'add_widgets_dialog').find_element(:css, 'div.modal-body > div:nth-child(1) > a').click
      @driver.find_element(:id, 'create_chart_widget_dialog').find_element(:name, 'commit').click; sleep 5
      expect(@driver.find_element(:id, 'create_chart_widget_dialog').find_elements(:class, 'error').size).to eql (4)
      @driver.find_element(:id, 'create_chart_widget_dialog').find_element(:class, 'close').click
    end

    it 'add chart widget' do
      @driver.find_element(:link_text, 'Add widget').click
      @driver.find_element(:id, 'add_widgets_dialog').find_element(:css, 'div.modal-body > div:nth-child(1) > a').click
      @driver.find_element(:id, 'create_chart_widget_dialog').find_element(:name, 'chart_widget[name]').send_key('test chart widget')
      @driver.find_element(:id, 'create_chart_widget_dialog').find_element(:name, 'chart_widget[gap]').send_key('10')
      @driver.find_element(:id, 'create_chart_widget_dialog').find_element(:name, 'chart_widget[start_time]').send_key('1440')
      @driver.find_element(:id, 'create_chart_widget_dialog').find_element(:name, 'chart_widget[end_time]').send_key('0')
      @driver.find_element(:id, 'create_chart_widget_dialog').find_element(:name, 'commit').click; sleep 10
      expect(@wait.until {@driver.find_element(:id, 'test_chart_widget').displayed?}).to be_truthy
      expect(@driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:class, 'autoupdate').text).to eql ('10 minutes')
      expect(@driver.find_element(:id, 'test_chart_widget').find_element(:class, 'friendly-message').displayed?).to be_truthy
    end

    it 'add chart widget with existed name' do
      @driver.find_element(:link_text, 'Add widget').click
      @driver.find_element(:id, 'add_widgets_dialog').find_element(:css, 'div.modal-body > div:nth-child(1) > a').click
      @driver.find_element(:id, 'create_chart_widget_dialog').find_element(:name, 'chart_widget[name]').send_key('test chart widget')
      @driver.find_element(:id, 'create_chart_widget_dialog').find_element(:name, 'chart_widget[gap]').send_key('10')
      @driver.find_element(:id, 'create_chart_widget_dialog').find_element(:name, 'chart_widget[start_time]').send_key('1440')
      @driver.find_element(:id, 'create_chart_widget_dialog').find_element(:name, 'chart_widget[end_time]').send_key('0')
      @driver.find_element(:id, 'create_chart_widget_dialog').find_element(:name, 'commit').click; sleep 5
      expect(@driver.find_element(:id, 'create_chart_widget_dialog').find_elements(:class, 'error').size).to eql (1)
      @driver.find_element(:id, 'create_chart_widget_dialog').find_element(:class, 'close').click
    end

    it 'manage chart widget' do
      @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:name, 'button').click
      @driver.find_element(:css, '[id$=-test-chart-widget]').find_element(:class, 'open_edit_widget_dialog').click; sleep 5
      @wait.until { @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[name]') }.send_key(' test')
      @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[gap]').send_key('10')
      @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'commit').click; sleep 5
      expect(@driver.find_element(:css, '[id$=-test-chart-widget-test]').find_element(:class, 'autoupdate').text).to eql ('1010 minutes')
    end

    it 'chart widget time zone' do
      # check time zone link on widgets
      @driver.find_element(:css, '[id$=-test-chart-widget-test').find_elements(:class, 'btn-link').select do |x|
        x if x.text.include? 'Time Zone'
      end.first.click; sleep 5
      expect(@driver.current_url).to include('user_profiles')
      # change time in profile
      @driver.find_element(:id, 'user_profile_time_zone').send_key('New Delhi')
      @driver.find_element(:name, 'commit').click; sleep 5
      # check new time value
      @driver.find_element(:id, 'dashboards_dropdown_full').click
      @driver.find_element(:link_text, @name).click; sleep 5
      expect(@driver.find_element(:css, '[id$=-test-chart-widget-test]').find_element(:link_text, 'Time Zone: IST (+05:30)').displayed?).to be_truthy
    end

    it 'delete chart widget' do
      @driver.execute_script('window.confirm = function() {return true}')
      @driver.find_element(:css, '[id$=-test-chart-widget-test]').find_element(:link_text, 'Delete').click; sleep 5
      begin
        @driver.find_element(:id, 'test_chart_widget_test')
        raise e
      rescue Selenium::WebDriver::Error::NoSuchElementError
        expect(true).to be_truthy
      end
    end
  end

  context '-calendar widget' do
    it 'add calendar widget with empty required fields' do
      @driver.find_element(:link_text, 'Add widget').click
      @driver.find_element(:id, 'add_widgets_dialog').find_element(:css, 'div.modal-body > div:nth-child(2) > a').click
      @driver.find_element(:id, 'create_calendar_widget_dialog').find_element(:name, 'commit').click; sleep 5
      expect(@driver.find_element(:id, 'create_calendar_widget_dialog').find_elements(:class, 'error').size).to eql (1)
      @driver.find_element(:id, 'create_calendar_widget_dialog').find_element(:class, 'close').click
    end

    it 'add calendar widget' do
      @driver.find_element(:link_text, 'Add widget').click
      @driver.find_element(:id, 'add_widgets_dialog').find_element(:css, 'div.modal-body > div:nth-child(2) > a').click
      @driver.find_element(:id, 'create_calendar_widget_dialog').find_element(:name, 'calendar_widget[name]').send_key('test calendar widget')
      @driver.find_element(:id, 'create_calendar_widget_dialog').find_element(:name, 'commit').click; sleep 5
      expect(@driver.find_element(:id, 'test_calendar_widget').displayed?).to be_truthy
      expect(@driver.find_element(:id, 'test_calendar_widget').find_element(:class, 'friendly-message').displayed?).to be_truthy
    end

    it 'add chart widget with existed name' do
      @driver.find_element(:link_text, 'Add widget').click
      @driver.find_element(:id, 'add_widgets_dialog').find_element(:css, 'div.modal-body > div:nth-child(2) > a').click
      @driver.find_element(:id, 'create_calendar_widget_dialog').find_element(:name, 'calendar_widget[name]').send_key('test calendar widget')
      @driver.find_element(:id, 'create_calendar_widget_dialog').find_element(:name, 'commit').click; sleep 5
      @driver.find_element(:id, 'create_calendar_widget_dialog').find_element(:name, 'commit').click; sleep 5
      expect(@driver.find_element(:id, 'create_calendar_widget_dialog').find_elements(:class, 'error').size).to eql (1)
      @driver.find_element(:id, 'create_calendar_widget_dialog').find_element(:class, 'close').click
    end

    it 'manage calendar widget' do
      @driver.find_element(:css, '[id$=-test-calendar-widget]').find_element(:name, 'button').click
      @driver.find_element(:css, '[id$=-test-calendar-widget]').find_element(:class, 'open_edit_widget_dialog').click; sleep 5
      @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'calendar_widget[name]').send_key(' test')
      @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'commit').click; sleep 5
      expect(@driver.find_element(:id, 'test_calendar_widget_test').displayed?).to be_truthy
      expect(@driver.find_element(:id, 'test_calendar_widget_test').find_element(:class, 'friendly-message').displayed?).to be_truthy
    end

    it 'delete calendar widget' do
      @driver.navigate.refresh
      @driver.execute_script('window.confirm = function() {return true}')
      @driver.find_element(:css, '[id$=-test-calendar-widget-test]').find_element(:link_text, 'Delete').click; sleep 5
      begin
        @driver.find_element(:id, 'test_calendar_widget_test')
        raise e
      rescue Selenium::WebDriver::Error::NoSuchElementError
        expect(true).to be_truthy
      end
    end
  end

  context '-spacer widget' do
    it 'add spacer widget' do
      @driver.find_element(:link_text, 'Add widget').click
      @driver.find_element(:id, 'add_widgets_dialog').find_element(:css, 'div.modal-body > div:nth-child(3) > a').click; sleep 5
      @driver.find_element(:id, 'create_spacer_widget_dialog').find_element(:name, 'commit').click; sleep 5
      expect(@driver.find_element(:class, 'spacer_widget').displayed?).to be_truthy
      expect(@driver.find_element(:css, '[id^=spacer_widget_]').attribute('data-widget')).to include("\"height_type\":\"Chart Widget\"")
    end

    it 'manage spacer widget' do
      @driver.find_element(:css, '[id*=-spacer_widget_]').find_element(:class, 'btn-group').find_element(:name, 'button').click
      @driver.find_element(:css, '[id*=-spacer_widget_]').find_element(:class, 'open_edit_widget_dialog').click
      @wait.until {@driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'spacer_widget[height_type]') }.send_key('Counter Widget')
      @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'commit').click; sleep 5
      expect(@driver.find_element(:css, '[id^=spacer_widget_]').attribute('data-widget')).to include("\"height_type\":\"Counter Widget\"")
    end

    it 'delete spacer widget' do
      @driver.execute_script('window.confirm = function() {return true}')
      @driver.find_element(:css, '[id*=-spacer_widget_]').find_element(:link_text, 'Delete').click; sleep 5
      begin
        @driver.find_element(:class, 'spacer_widget')
        raise e
      rescue Selenium::WebDriver::Error::NoSuchElementError
        expect(true).to be_truthy
      end
    end
  end

  context '-label widget' do
    it 'add label widget' do
      @driver.find_element(:link_text, 'Add widget').click
      @driver.find_element(:id, 'add_widgets_dialog').find_element(:css, 'div.modal-body > div:nth-child(4) > a').click
      @driver.find_element(:id, 'create_label_widget_dialog').find_element(:name, 'label_widget[notes]').send_key('test label widget')
      @driver.find_element(:id, 'create_label_widget_dialog').find_element(:name, 'commit').click; sleep 5
      expect(@driver.find_element(:class, 'label_widget').displayed?).to be_truthy
      expect(@driver.find_element(:css, '[id*=-label_widget_]').find_element(:class, 'label-widget-notes').text).to eql('test label widget')
    end

    it 'manage label widget' do
      @driver.find_element(:css, '[id*=-label_widget_').find_element(:name, 'button').click
      @driver.find_element(:css, '[id*=-label_widget_').find_element(:class, 'open_edit_widget_dialog').click; sleep 5
      @wait.until { @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'label_widget[notes]') }.send_key(' test')
      @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'commit').click; sleep 5
      expect(@driver.find_element(:css, '[id*=-label_widget_]').find_element(:class, 'label-widget-notes').text).to eql('test label widget test')
    end

    it 'delete label widget' do
      @driver.execute_script('window.confirm = function() {return true}')
      @driver.find_element(:css, '[id*=-label_widget_]').find_element(:link_text, 'Delete').click; sleep 5
      begin
        @driver.find_element(:class, 'label_widget')
        raise e
      rescue Selenium::WebDriver::Error::NoSuchElementError
        expect(true).to be_truthy
      end
    end
  end

  context '-tabular widget' do
    it 'add tabular widget with empty required fields' do
      @driver.find_element(:link_text, 'Add widget').click
      @driver.find_element(:id, 'add_widgets_dialog').find_element(:css, 'div.modal-body > div:nth-child(5) > a').click
      @driver.find_element(:id, 'create_tabular_widget_dialog').find_element(:name, 'commit').click; sleep 5
      expect(@driver.find_element(:id, 'create_tabular_widget_dialog').find_elements(:class, 'error').size).to eql (4)
      @driver.find_element(:id, 'create_tabular_widget_dialog').find_element(:class, 'close').click
    end

    it 'add tabular widget' do
      @driver.find_element(:link_text, 'Add widget').click
      @driver.find_element(:id, 'add_widgets_dialog').find_element(:css, 'div.modal-body > div:nth-child(5) > a').click
      @driver.find_element(:id, 'create_tabular_widget_dialog').find_element(:name, 'tabular_widget[name]').send_key('test tabular widget')
      @driver.find_element(:id, 'create_tabular_widget_dialog').find_element(:name, 'tabular_widget[gap]').send_key('10')
      @driver.find_element(:id, 'create_tabular_widget_dialog').find_element(:name, 'tabular_widget[start_time]').send_key('1440')
      @driver.find_element(:id, 'create_tabular_widget_dialog').find_element(:name, 'tabular_widget[end_time]').send_key('0')
      @driver.find_element(:id, 'create_tabular_widget_dialog').find_element(:name, 'commit').click; sleep 5
      expect(@driver.find_element(:id, 'test_tabular_widget').displayed?).to be_truthy
      expect(@driver.find_element(:id, 'test_tabular_widget').find_element(:class, 'friendly-message').displayed?).to be_truthy
    end

    it 'add tabular widget with existed name' do
      @driver.find_element(:link_text, 'Add widget').click
      @driver.find_element(:id, 'add_widgets_dialog').find_element(:css, 'div.modal-body > div:nth-child(5) > a').click
      @driver.find_element(:id, 'create_tabular_widget_dialog').find_element(:name, 'tabular_widget[name]').send_key('test tabular widget')
      @driver.find_element(:id, 'create_tabular_widget_dialog').find_element(:name, 'tabular_widget[gap]').send_key('10')
      @driver.find_element(:id, 'create_tabular_widget_dialog').find_element(:name, 'tabular_widget[start_time]').send_key('1440')
      @driver.find_element(:id, 'create_tabular_widget_dialog').find_element(:name, 'tabular_widget[end_time]').send_key('0')
      @driver.find_element(:id, 'create_tabular_widget_dialog').find_element(:name, 'commit').click; sleep 5
      expect(@driver.find_element(:id, 'create_tabular_widget_dialog').find_elements(:class, 'error').size).to eql (1)
      @driver.find_element(:id, 'create_tabular_widget_dialog').find_element(:class, 'close').click
    end

    it 'manage tabular widget' do
      @driver.find_element(:css, '[id*=-test-tabular-widget').find_element(:name, 'button').click
      @driver.find_element(:css, '[id*=-test-tabular-widget').find_element(:class, 'open_edit_widget_dialog').click
      @wait.until { @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'tabular_widget[name]') }.send_key(' test')
      @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'tabular_widget[gap]').send_key('10')
      @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'tabular_widget[start_time]').send_key('0')
      @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'commit').click; sleep 5
      expect(@driver.find_element(:id, 'test_tabular_widget_test').displayed?).to be_truthy
      expect(@driver.find_element(:css, '[id$=-test-tabular-widget-test]').find_element(:class, 'autoupdate').text).to eql ('1010 minutes')
      expect(@driver.find_element(:id, 'test_tabular_widget_test').find_element(:class, 'friendly-message').displayed?).to be_truthy
    end

    it 'tabular widget time zone' do
      @driver.find_element(:css, '[id$=-test-tabular-widget-test]').find_elements(:class, 'btn-link').select do |x|
        x if x.text.include? 'Time Zone'
      end.first.click; sleep 5
      expect(@driver.current_url).to include ('user_profiles')
      @driver.find_element(:id, 'user_profile_time_zone').send_key('Pacific Time')
      @driver.find_element(:name, 'commit').click; sleep 5
      @driver.find_element(:id, 'dashboards_dropdown_full').click; sleep 5
      @driver.find_element(:link_text, @name).click
      expect(@driver.find_element(:css, '[id$=-test-tabular-widget-test]').find_element(:link_text, 'Time Zone: PDT (-07:00)').displayed?).to be_truthy
    end

    it 'delete tabular widget' do
      @driver.execute_script('window.confirm = function() {return true}')
      @driver.find_element(:css, '[id$=-test-tabular-widget-test]').find_element(:link_text, 'Delete').click; sleep 5
      begin
        @driver.find_element(:id, 'test_tabular_widget_test')
        raise e
      rescue Selenium::WebDriver::Error::NoSuchElementError
        expect(true).to be_truthy
      end
    end
  end

  context '-status widget' do
    it 'add status widget with empty required fields' do
      @driver.navigate.to('https://intel-staging.xcal.tv/dashboards/269-')

      @driver.find_element(:link_text, 'Add widget').click
      @driver.find_element(:id, 'add_widgets_dialog').find_element(:css, 'div.modal-body > div:nth-child(6) > a').click
      @driver.find_element(:id, 'create_status_widget_dialog').find_element(:name, 'commit').click; sleep 5
      expect(@driver.find_element(:id, 'create_status_widget_dialog').find_elements(:class, 'error').size).to eql (2)
      @driver.find_element(:id, 'create_status_widget_dialog').find_element(:class, 'close').click
    end

    it 'add status widget' do
      @driver.find_element(:link_text, 'Add widget').click
      @driver.find_element(:id, 'add_widgets_dialog').find_element(:css, 'div.modal-body > div:nth-child(6) > a').click; sleep 5
      @driver.find_element(:id, 'create_status_widget_dialog').find_element(:name, 'status_widget[name]').send_key('test status widget')
      @driver.find_element(:id, 'create_status_widget_dialog').find_element(:name, 'status_widget[gap]').send_key('10')
      @driver.find_element(:id, 'create_status_widget_dialog').find_element(:name, 'commit').click; sleep 5
      expect(@driver.find_element(:class, 'status-widget').find_element(:class, 'center').text).to eql('test status widget')
      expect(@driver.find_element(:class, 'status-widget').find_element(:class, 'autoupdate').text).to eql('10 minutes')
    end

    it 'manage status widget' do
      @driver.find_element(:class, 'status-widget').find_element(:name, 'button').click
      @driver.find_element(:class, 'status-widget').find_element(:class, 'open_edit_widget_dialog').click; sleep 5
      @wait.until { @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'status_widget[name]') }.send_key(' test')
      @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'status_widget[gap]').send_key('10')
      @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'commit').click; sleep 5
      expect(@driver.find_element(:class, 'status-widget').find_element(:class, 'center').text).to eql('test status widget test')
      expect(@driver.find_element(:class, 'status-widget').find_element(:class, 'autoupdate').text).to eql('1010 minutes')
    end

    it 'status widget time zone' do
      @driver.find_element(:class, 'status-widget').find_elements(:class, 'btn-link').select do |x|
        x if x.text.include? 'Time Zone'
      end.first.click; sleep 5
      expect(@driver.current_url).to include ('user_profiles')
      @driver.find_element(:id, 'user_profile_time_zone').send_key('UTC')
      @driver.find_element(:name, 'commit').click; sleep 5
      @driver.find_element(:id, 'dashboards_dropdown_full').click
      @driver.find_element(:link_text, @name).click; sleep 5
      expect(@driver.find_element(:class, 'status-widget').find_element(:link_text, 'Time Zone: UTC (+00:00)').displayed?).to be_truthy
    end

    it 'add second status widget' do
      @driver.find_element(:link_text, 'Add widget').click
      expect(@driver.find_element(:id, 'add_widgets_dialog').find_element(:css, 'div.modal-body > div:nth-child(6)').displayed?).to be_falsey
      @driver.find_element(:id, 'add_widgets_dialog').find_element(:class, 'close').click
    end

    it 'delete status widget' do
      @driver.execute_script('window.confirm = function() {return true}')
      @driver.find_element(:class, 'status-widget').find_element(:link_text, 'Delete').click; sleep 5
      begin
        @driver.find_element(:class, 'status-widget')
        raise e
      rescue Selenium::WebDriver::Error::NoSuchElementError
        expect(true).to be_truthy
      end
    end
  end
end
