require 'spec_helper'

describe 'Tags tab' do

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
  context 'service_desks_dashboards' do

    before(:all) do
      @name = 'Test Desk 1'
    end

    it 'view service desks dashboards' do
      @driver.navigate.refresh
      expect(@driver.current_url).to include('manage_service_desks')
      expect(@driver.page_source).to include('Service Desks Dashboards')
      expect(@driver.find_element(:link_text, 'Fetch from Brouha').displayed?).to be_truthy
    end

    it 'pagination' do
      # go to page number 2
      @driver.find_element(:class, 'pagination').find_element(:link_text, '2').click; sleep 5
      expect(@driver.current_url).to include('page=2')
      # go to next page
      @driver.find_element(:class, 'pagination').find_element(:css, '.next > a:nth-child(1)').click; sleep 5
      expect(@driver.current_url).to include('page=3')
      # go to previous page
      @driver.find_element(:class, 'pagination').find_element(:css, '.prev > a:nth-child(1)').click; sleep 5
      expect(@driver.current_url).to include('page=2')
    end

    it 'edit service desk' do
      @driver.navigate.refresh
      # pick service desk
      @driver.find_elements(:css, 'table > tbody > tr').find do |x|
        x.find_element(:css, 'td:nth-child(2)').find_element(:class, 'btn-info').click if x.find_element(:css, 'td:nth-child(1)').text == @name
      end; sleep 5
      expect(@driver.current_url).to include('test-desk-1/edit')
      expect(@driver.page_source).to include("Manage #{@name}")
      # edit service desk
      @driver.find_element(:id, 'alarm_dashboard_display_events_impact_level').click
      @driver.find_element(:id, 'alarm_dashboard_sort_events_by_severity').click
      @driver.find_element(:id, 'alarm_dashboard_sort_by_unticketed_events').click
      @driver.find_element(:id, 'alarm_dashboard_group_and_view_by_host').click
      @driver.find_element(:id, 'alarm_dashboard_show_in_service_desk').click
      @driver.find_element(:id, 'alarm_dashboard_show_on_create_ticket').click
      @driver.find_element(:name, 'commit').click; sleep 5
      # check alert pop-up - appears/close
      expect(@driver.find_element(:class, 'alert-notice').displayed?).to be_truthy
      expect(@driver.find_element(:class, 'alert-notice').text).to include("x\nAlarm Dashboard #{@name} was successfully updated")
      @driver.find_element(:class, 'alert-notice').find_element(:class, 'close').click; sleep 5
      begin
        @driver.find_element(:class, 'alert-notice')
        raise e
      rescue Selenium::WebDriver::Error::NoSuchElementError
        expect(true).to be_truthy
      end
      @driver.find_element(:id, 'alarms_dropdown').click
      expect(@driver.find_element(:link_text, 'Test Desk 1').displayed?).to be_truthy

      it 'show in service_desk' do
        @driver.find_element(:id, 'profile_dropdown').click
        @driver.find_element(:link_text, 'Service Desks Dashboards').click; sleep 5
        @driver.find_element(:class, 'pagination').find_element(:link_text, '2').click; sleep 5
        @driver.find_elements(:css, 'table > tbody > tr').find do |x|
          x.find_element(:css, 'td:nth-child(2)').find_element(:class, 'btn-info').click if x.find_element(:css, 'td:nth-child(1)').text == @name
        end; sleep 5
        @driver.find_element(:id, 'alarm_dashboard_show_in_service_desk').click
        @driver.find_element(:name, 'commit').click
        @driver.find_element(:id, 'alarms_dropdown').click
        begin
          @driver.find_element(:link_text, 'Test Desk 1')
          raise e
        rescue Selenium::WebDriver::Error::NoSuchElementError
          expect(true).to be_truthy
        end
      end
    end

    it 'delete service desk' do
      @driver.find_element(:id, 'profile_dropdown').click
      @driver.find_element(:link_text, 'Service Desks Dashboards').click; sleep 5
      @driver.find_element(:class, 'pagination').find_element(:link_text, '2').click; sleep 5
      @driver.execute_script('window.confirm = function() {return true}')
      @driver.find_elements(:css, 'table > tbody > tr').find do |x|
        x.find_element(:css, 'td:nth-child(2)').find_element(:class, 'btn-danger').click if x.find_element(:css, 'td:nth-child(1)').text == @name
      end; sleep 5
      #check that SD was removed
      @driver.find_element(:class, 'pagination').find_element(:link_text, '2').click; sleep 5
      el = @driver.find_elements(:css, 'table > tbody > tr').collect { |x| x.find_element(:css, 'td:nth-child(1)').text }
      expect(el.include? @name).to be_falsey
    end

    it 'fetch from brouha' do
      # synchronize with brouha
      @driver.find_element(:link_text, 'Fetch from Brouha').click; sleep 5
      # check alert pop-up - appears/close
      expect(@driver.find_element(:class, 'alert-notice').displayed?).to be_truthy
      expect(@driver.find_element(:class, 'alert-notice').text).to include("x\nService Desk Dashboards were successfully synchronized")
      @driver.find_element(:class, 'alert-notice').find_element(:class, 'close').click; sleep 5
      begin
        @driver.find_element(:class, 'alert-notice')
        raise e
      rescue Selenium::WebDriver::Error::NoSuchElementError
        expect(true).to be_truthy
      end
      # check that deleted service desk was restored
      @driver.find_element(:class, 'pagination').find_element(:link_text, '2').click; sleep 5
      el = @driver.find_elements(:css, 'table > tbody > tr').collect { |x| x.find_element(:css, 'td:nth-child(1)').text }
      expect(el.include? 'Test Desk 1').to be_truthy
    end
  end
end
