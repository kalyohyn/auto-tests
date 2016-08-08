require 'spec_helper'

describe 'reports' do

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

  context 'filter alarms' do

    before(:each) do
      @driver.navigate.to('https://intel-staging.xcal.tv/reports/alarms')
    end

    it 'filter alarms with valid dates' do
      start_date = (Time.now - 1.days).strftime('%Y-%m-%d')
      end_date = Time.now.strftime('%Y-%m-%d')

      @driver.find_element(:name, 'start_date').clear
      @driver.find_element(:name, 'start_date').send_key("#{start_date}")
      @driver.find_element(:name, 'end_date').clear
      @driver.find_element(:name, 'end_date').send_key("#{end_date}")
      @driver.find_element(:id, 'submit_button').click
      expect(@driver.current_url).to eql ("https://intel-staging.xcal.tv/reports/alarms/#{start_date}/#{end_date}")
    end

    it 'invalid end-time' do
      start_date = (Time.now - 1.days).strftime('%Y-%m-%d')
      end_date = (Time.now + 7.days).strftime('%Y-%m-%d')

      @driver.find_element(:name, 'end_date').clear
      @driver.find_element(:name, 'end_date').send_key("#{end_date}")
      @driver.find_element(:id, 'submit_button').click
      expect(@driver.current_url).to eql ("https://intel-staging.xcal.tv/reports/alarms/#{start_date}/#{end_date}")
    end

    it 'invalid start-time' do
      start_date =  @driver.find_element(:id, 'start_date')
      start_date.send_key('')
      @driver.find_element(:xpath, '/html/body/div[5]/div[1]/table/tbody/tr[1]/td[2]').click
      st = start_date.attribute('value')
      end_date = @driver.find_element(:id, 'end_date')
      end_date.send_key("")
      @driver.find_element(:xpath, '/html/body/div[6]/div[1]/table/tbody/tr[1]/td[1]').click
      et = end_date.attribute('value')
      expect(@driver.find_element(:id, 'alert').displayed?).to be_truthy

      @driver.find_element(:id, 'submit_button').click
      expect(@driver.current_url).to include ("/alarms/#{st}/#{et}")
    end

    it 'clear end-time field' do
      start_date = (Time.now - 1.days).strftime('%Y-%m-%d')
      end_date = Time.now.strftime('%Y-%m-%d')
      @driver.find_element(:name, 'end_date').clear
      @driver.find_element(:id, 'submit_button').click
      expect(@driver.current_url).to include("reports/alarms/#{start_date}")
      expect(@driver.find_element(:id, 'end_date').attribute('value')).to eql("#{end_date}")
    end

    it 'clear start-time field' do
      end_date = Time.now.strftime('%Y-%m-%d')
      @driver.find_element(:name, 'start_date').clear
      @driver.find_element(:id, 'submit_button').click
      expect(@driver.current_url).to include("reports/alarms//#{end_date}")
      expect(@driver.find_element(:id, 'start_date').attribute('value')).to eql("#{end_date}")
      expect(@driver.find_element(:id, 'end_date').attribute('value')).to eql("#{end_date}")
    end
  end

  context 'reports pages' do

    before(:all) do
      @start_date = (Time.now - 1.days).strftime('%Y-%m-%d')
      @end_date = Time.now.strftime('%Y-%m-%d')
    end

    it 'alarm history' do
      @driver.find_element(:link_text, 'Reports').click
      @driver.find_element(:link_text, 'Alarm History').click; sleep 5
      expect(@driver.current_url).to include("reports/alarms/#{@start_date}/#{@end_date}")
      expect(@driver.page_source).to include ('All alarms in a given time domain')
    end

    it 'top alarms' do
      @driver.find_element(:link_text, 'Reports').click
      @driver.find_element(:link_text, 'Top Alarms').click; sleep 5
      expect(@driver.current_url).to include("top_alarms/#{@start_date}/#{@end_date}")
      expect(@driver.page_source).to include('TOP Alarms in a given time domain')
    end

    it 'currently snoozed events' do
      @driver.find_element(:link_text, 'Reports').click
      @driver.find_element(:link_text, 'Currently Snoozed Events').click; sleep 5
      expect(@driver.current_url).to include('reports/snoozed_events')
      expect(@driver.page_source).to include('Events currently snoozed')
    end

    it 'collected CHANGE tickets' do
      @driver.find_element(:link_text, 'Reports').click
      @driver.find_element(:link_text, 'Collected CHANGE tickets').click; cleep 5
      expect(@driver.current_url).to include("reports/change_tickets/#{@start_date}/#{@end_date}")
      expect(@driver.page_source).to include('Collected CHANGE tickets in a given time domain')
    end

    it 'collected INCIDENT tickets' do
      @driver.find_element(:link_text, 'Reports').click
      @driver.find_element(:link_text, 'Collected INCIDENT tickets').click
      expect(@driver.current_url).to include("reports/incident_tickets/#{@start_date}/#{@end_date}")
      expect(@driver.page_source).to include('Collected INCIDENT tickets in a given time domain')
    end

    it 'Mean Time to Acknowledge (MTTA)' do
      @driver.find_element(:link_text, 'Reports').click
      @driver.find_element(:link_text, 'Mean Time to Acknowledge (MTTA)').click
      expect(@driver.current_url).to include("reports/acknowledgments/#{@start_date}/#{@end_date}")
      expect(@driver.page_source).to include('Acknowledgments in a given time domain')
    end

    it 'Mean Time to Ticket (MTTT)' do
      @driver.find_element(:link_text, 'Reports').click
      @driver.find_element(:link_text, 'Mean Time to Ticket (MTTT)').click
      expect(@driver.current_url).to include("reports/ticketing/#{@start_date}/#{@end_date}")
      expect(@driver.page_source).to include('Ticketing in a given time domain')
    end

    it 'user timestamps' do
      @driver.find_element(:link_text, 'Reports').click
      @driver.find_element(:link_text, 'User Timestamps').click
      expect(@driver.current_url).to include('reports/user_timestamps')
      expect(@driver.page_source).to include('User login / logout timestamps')
    end

    it 'Acknowledged By Me (MTTA)' do
      @driver.find_element(:link_text, 'Reports').click
      @driver.find_element(:link_text, 'Acknowledged By Me (MTTA)').click
      expect(@driver.current_url).to include("reports/my_acknowledgments/#{@start_date}/#{@end_date}")
      expect(@driver.page_source).to include('Acknowledgments in a given time domain')
    end

    it 'Ticketed By Me (MTTT)' do
      @driver.find_element(:link_text, 'Reports').click
      @driver.find_element(:link_text, 'Ticketed By Me (MTTT)').click
      expect(@driver.current_url).to include("reports/my_ticketing/#{@start_date}/#{@end_date}")
      expect(@driver.page_source).to include('Ticketing in a given time domain')
    end
  end
end

