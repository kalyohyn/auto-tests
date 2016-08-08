require 'spec_helper'

describe 'Manage Alarm Dashboards' do

  before(:all) do
    @name = 'alyohyn'
    @driver = Selenium::WebDriver.for :firefox
    @driver.navigate.to('https://intel-staging.xcal.tv')
    @driver.find_element(:name => 'login').send_key('[FILTERED]')
    @driver.find_element(:name => 'password').send_key('[FILTERED]')
    @driver.find_element(:name => 'commit').submit
  end

  after(:all) do
    @driver.quit
  end

  it 'view alarm dashboards' do
    @driver.find_element(:id, 'profile_dropdown').click; sleep 3
    @driver.find_element(:link_text, 'Manage Alarm Dashboards').click; sleep 5
    expect(@driver.current_url).to include('alarm_dashboards')
    expect(@driver.find_element(:link_text, 'Create alarm dashboard').displayed?).to be_truthy
  end

  it 'pagination' do
    # go to page number 2
    @driver.find_element(:css, '.pagination > ul:nth-child(1) > li:nth-child(3) > a').click; sleep 5
    expect(@driver.current_url).to include('page=2')
    # go to next page
    @driver.find_element(:css, '.pagination > ul:nth-child(1) > li:nth-child(5) > a').click; sleep 5
    expect(@driver.current_url).to include('page=3')
    # go to previous page
    @driver.find_element(:css, '.pagination > ul:nth-child(1) > li:nth-child(1) > a').click; sleep 5
    expect(@driver.current_url).to include('page=2')
  end

  it 'create alarm dashboard' do
    # create alarm dash
    @driver.find_element(:link_text, 'Create alarm dashboard').click; sleep 5
    expect(@driver.find_element(:id, 'edit_alarm_dashboard_dialog_').displayed?).to be_truthy
    @driver.find_element(:id, 'new_alarm_dashboard').find_element(:name, 'alarm_dashboard[name]').send_key(@name)
    @driver.find_element(:id, 'new_alarm_dashboard').find_element(:name, 'commit').click; sleep 5
    # check that new dash appears in dashboads list
    element = @driver.find_elements(:css, 'table > tbody > tr > td:nth-child(1)').collect { |x| x.text }
    expect(element.include?(@name)).to be_truthy
    @driver.find_element(:id, 'alarms_dropdown').click
    expect(@driver.find_element(:link_text, @name).displayed?).to be_truthy
  end

  it 'create alarm dashboard with empty required fields' do
    @driver.navigate.refresh
    # create new dash
    @driver.find_element(:link_text, 'Create alarm dashboard').click; sleep 5
    @driver.find_element(:id, 'new_alarm_dashboard').find_element(:name, 'alarm_dashboard[name]').clear
    @driver.find_element(:id, 'new_alarm_dashboard').find_element(:name, 'commit').click; sleep 5
    # check thar error occurs
    expect(@driver.find_element(:id, 'new_alarm_dashboard').find_element(:class, 'error').displayed?).to be_truthy
    @driver.find_element(:id, 'edit_alarm_dashboard_dialog_').find_element(:class, 'close').click
  end

  it 'create alarm dashboard with existed name' do
    @driver.navigate.refresh
    # create new dash with existed name
    @driver.find_element(:link_text, 'Create alarm dashboard').click; sleep 5
    @driver.find_element(:id, 'new_alarm_dashboard').find_element(:name, 'alarm_dashboard[name]').send_key(@name)
    @driver.find_element(:id, 'new_alarm_dashboard').find_element(:name, 'commit').click; sleep 5
    # check that error occurs
    expect(@driver.find_element(:id, 'new_alarm_dashboard').find_element(:class, 'error').displayed?).to be_truthy
    @driver.find_element(:id, 'edit_alarm_dashboard_dialog_').find_element(:class, 'close').click; sleep 5
    expect(@driver.find_element(:id, 'edit_alarm_dashboard_dialog_').displayed?).to be_falsey
  end

  it 'edit alarm dashboard with clear filters' do
    @driver.find_element(:id, 'profile_dropdown').click
    @driver.find_element(:link_text, 'Manage Alarm Dashboards').click; sleep 5
    # pick and editing dash
    @driver.find_elements(:css, 'table > tbody > tr').find do |x|
      x.find_elements(:class, 'btn').find { |z| z.click if z.text == 'Edit' } if x.find_element(:css, 'td:nth-child(1)').text == @name
    end; sleep 5
    expect(@driver.current_url).to include('edit')
    expect(@driver.page_source).to include("Manage #{@name}")
    # check pop-up notification - open/close
    @driver.find_element(:class, 'edit-alarm-dashboard').find_element(:class, 'icon-question-sign').click; sleep 5
    expect(@driver.find_element(:class, 'alarm-dashboard-hint').displayed?).to be_truthy
    @driver.find_element(:class, 'edit-alarm-dashboard').find_element(:class, 'icon-question-sign').click; sleep 5
    expect(@driver.find_element(:class, 'alarm-dashboard-hint').displayed?).to be_falsey
    @driver.find_element(:name, 'commit').click; sleep 5
    expect(@driver.current_url).to include(@name)
    # check alert pop-up - appears/close
    expect(@driver.find_element(:class, 'alert-notice').displayed?).to be_truthy
    expect(@driver.find_element(:class, 'alert-notice').text).to eql("x\nAlarm Dashboard #{@name} was successfully updated")
    @driver.find_element(:class, 'alert-notice').find_element(:class, 'close').click; sleep 5
    begin
      @driver.find_element(:class, 'alert-notice')
      raise e
    rescue Selenium::WebDriver::Error::NoSuchElementError
      expect(true).to be_truthy
    end
    expect(@driver.find_element(:class, 'alert-error').displayed?).to be_truthy
    expect(@driver.find_element(:class, 'alert-error').text).to eql("x\nFilters have not yet been specified")
  end

  it 'edit alarm dashboard with specify filters' do
    @driver.find_element(:id, 'profile_dropdown').click
    @driver.find_element(:link_text, 'Manage Alarm Dashboards').click; sleep 5
    # pick dash and editing params
    @driver.find_elements(:css, 'table > tbody > tr').find do |x|
      x.find_elements(:class, 'btn').find { |z| z.click if z.text == 'Edit' } if x.find_element(:css, 'td:nth-child(1)').text == @name
    end; sleep 5
    @driver.find_element(:name, 'alarm_dashboard[name]').send_key(" test")
    @driver.find_element(:name, 'alarm_dashboard[alarm_query]').send_key('1=1')
    @driver.find_element(:name, 'alarm_dashboard[event_query]').send_key('1=1')
    @driver.find_element(:name, 'alarm_dashboard[tag_query]').send_key('test tag')
    @driver.find_element(:name, 'alarm_dashboard[sort_by]').send_key('name')
    @driver.find_element(:id, 'alarm_dashboard_role_ids').find_elements(:tag_name => 'option').find do |option|
      option.text == 'OIV_USER'
    end.click
    @driver.find_element(:id, 'alarm_dashboard_display_brouha_incidents').click
    @driver.find_element(:id, 'alarm_dashboard_display_events_impact_level').click
    @driver.find_element(:id, 'alarm_dashboard_sort_events_by_severity').click
    @driver.find_element(:id, 'alarm_dashboard_sort_by_unticketed_events').click
    @driver.find_element(:id, 'alarm_dashboard_group_and_view_by_host').click
    @driver.find_element(:name, 'commit').click; sleep 10
    # check dash was edited
    expect(@driver.current_url).to include("#{@name}-test")
    expect(@driver.find_element(:class, 'alert-notice').displayed?).to be_truthy
    @driver.find_element(:id, 'alarms_dropdown').click
    expect(@driver.find_element(:link_text, "#{@name} test").displayed?).to be_truthy
  end

  context 'check dashboard filters' do

    before(:all) do
      @driver.navigate.to('https://intel-staging.xcal.tv/'); sleep 5
      @driver.find_element(:id, 'alarms_dropdown').click; sleep 3
      @driver.find_element(:link_text, 'alyohyn test').click
      @url = @driver.current_url
    end

    it 'DC filter' do
      @driver.find_element(:css, 'ul.nav-pills:nth-child(4) > li:nth-child(1) > a:nth-child(1)').click; sleep 3
      @driver.find_element(:class, 'open').find_elements(:class, 'data_center').find { |x| x.click if x.text == 'DC Westchester' }; sleep 5
      expect(@driver.find_element(:class, 'alarm_dashboard_data').find_elements(:css, 'tbody > tr').size).to eql(0)
      expect(@driver.find_element(:css, 'ul.nav-pills:nth-child(4) > li:nth-child(1) > a:nth-child(1)').text).to eql('DC: DC')
      @driver.find_element(:css, 'ul.nav-pills:nth-child(4) > li:nth-child(1) > a:nth-child(1)').click
      @driver.find_element(:class, 'open').find_elements(:class, 'data_center').find { |x| x.click if x.text == 'All' }
    end

    it 'impact level' do
      @driver.find_element(:css, 'ul.nav-pills:nth-child(5) > li:nth-child(1) > a:nth-child(1)').click; sleep 3
      @driver.find_element(:class, 'open').find_elements(:class, 'impact_level').find { |x| x.click if x.text == 'High' }; sleep 5
      expect(@driver.find_element(:css, 'ul.nav-pills:nth-child(5) > li:nth-child(1) > a:nth-child(1)').text).to eql('Impact: High')
      @driver.find_element(:css, 'ul.nav-pills:nth-child(5) > li:nth-child(1) > a:nth-child(1)').click
      @driver.find_element(:class, 'open').find_elements(:class, 'impact_level').find { |x| x.click if x.text == 'All' }
    end

    it 'priority' do
      @driver.find_element(:css, 'ul.nav-pills:nth-child(6) > li:nth-child(1) > a:nth-child(1)').click; sleep 3
      @driver.find_element(:class, 'open').find_elements(:class, 'component-alarm-priority').find { |x| x.click if x.text == '3' }; sleep 5
      expect(@driver.find_element(:class, 'alarm_dashboard_data').find_elements(:css, 'tbody > tr').size).to eql(0)
      expect(@driver.find_element(:css, 'ul.nav-pills:nth-child(6) > li:nth-child(1) > a:nth-child(1)').text).to eql('Priority: 3')
      @driver.find_element(:css, 'ul.nav-pills:nth-child(6) > li:nth-child(1) > a:nth-child(1)').click
      @driver.find_element(:class, 'open').find_elements(:class, 'component-alarm-priority').find { |x| x.click if x.text == 'All' }
    end

    it 'per page' do
      @driver.find_element(:css, 'ul.nav-pills:nth-child(7) > li:nth-child(1) > a:nth-child(1)').click; sleep 3
      @driver.find_element(:class, 'open').find_elements(:class, 'per_page_for_alarms').find { |x| x.click if x.text == '20 items' }; sleep 5
      expect(@driver.find_element(:css, 'ul.nav-pills:nth-child(7) > li:nth-child(1) > a:nth-child(1)').text).to eql('Per page: 20')
    end

    it 'time range' do
      @driver.find_element(:css, 'ul.nav-pills:nth-child(8) > li:nth-child(1) > a:nth-child(1)').click; sleep 3
      @driver.find_element(:class, 'open').find_elements(:class, 'time_range_for_alarms').find { |x| x.click if x.text == '60 hours' }; sleep 5
      expect(@driver.find_element(:css, 'ul.nav-pills:nth-child(8) > li:nth-child(1) > a:nth-child(1)').text).to eql('Time range: 60')
    end

    it 'simple filter' do
      # switch to Un-Acknowledged Negative
      @driver.find_element(:css, 'div.buttons:nth-child(3) > div:nth-child(1) > a:nth-child(1)').click
      @driver.find_elements(:class, 'events-general-filter').find { |x| x.click if x.text == 'Un-Acknowledged Negative' }; sleep 5
      expect(@driver.find_element(:link_text, 'Un-Acknowledged Negative').displayed?).to be_truthy
      # switch to All Ticketed
      @driver.find_element(:css, 'div.buttons:nth-child(3) > div:nth-child(1) > a:nth-child(1)').click
      @driver.find_elements(:class, 'events-general-filter').find { |x| x.click if x.text == 'All Ticketed' }; sleep 5
      expect(@driver.find_element(:link_text, 'All Ticketed').displayed?).to be_truthy
      # switch to All Acknowledged
      @driver.find_element(:css, 'div.buttons:nth-child(3) > div:nth-child(1) > a:nth-child(1)').click
      @driver.find_elements(:class, 'events-general-filter').find { |x| x.click if x.text == 'All Acknowledged' }; sleep 5
      expect(@driver.find_element(:link_text, 'All Acknowledged').displayed?).to be_truthy
      # switch to All Positive States
      @driver.find_element(:css, 'div.buttons:nth-child(3) > div:nth-child(1) > a:nth-child(1)').click
      @driver.find_elements(:class, 'events-general-filter').find { |x| x.click if x.text == 'All Positive States' }; sleep 5
      expect(@driver.find_element(:link_text, 'All Positive States').displayed?).to be_truthy
      # switch to advanced option
      @driver.find_elements(:class, 'btn-primary').find { |x| x.click if x.text == 'All Positive States' }
      @driver.find_elements(:class, 'events-general-filter').find { |x| x.click if x.text == 'Switch to advanced options' }; sleep 5
      expect(@driver.find_element(:link_text, 'Switch to Simple filters').displayed?).to be_truthy
      @driver.find_element(:css, 'button.multiselect').click
      @driver.find_element(:class, 'multiselect-container').find_elements(:tag_name, 'input').collect do |x|
        x.click if x.attribute('value') == "multiselect-all"
      end
      expect(@driver.find_element(:css, 'button.multiselect').text).to eql('Auto aged and 21 more')
      @driver.find_element(:class, 'filter_by_me').click; sleep 5
      expect(@driver.find_element(:class, 'filter_by_me').text).to eql('Filter All')
      @driver.find_element(:class, 'icon-refresh').click; sleep 5
      expect(@driver.find_element(:class, 'filter_by_me').text).to eql('Filter All')
      # switch to simple filter
      @driver.find_element(:class, 'events-general-filter').click; sleep 5
      expect(@driver.find_element(:link_text, 'Everything').displayed?).to be_truthy
    end

    it 'search "any"' do
      @driver.find_element(:class, 'first-letter').click
      @driver.find_element(:id, 'search_query').send_key('test'); sleep 3
      @driver.find_element(:id, 'submit_button').click; sleep 5
      expect(@driver.current_url).to include('search_query=test')
      expect(@driver.find_element(:class, 'white-space-pre-wrap').text).to eql("Search results for criteria: 'test'")
    end

    it 'search "subject"' do
      @driver.navigate.to(@url)
      @driver.find_element(:class, 'first-letter').click
      @driver.find_element(:class, 'event-search').find_elements(:class, 'menu-item').find do |x|
        x.click if x.text == 'subject'
      end; sleep 5
      @driver.find_element(:id, 'search_query').send_key('test')
      @driver.find_element(:id, 'submit_button').click; sleep 5
      expect(@driver.current_url).to include('search_query=subject%3Dtest')
      expect(@driver.find_element(:class, 'white-space-pre-wrap').text).to eql("Search results for criteria: 'subject=test'")
    end

    it 'search "incident_id"' do
      @driver.navigate.to(@url)
      @driver.find_element(:class, 'first-letter').click
      @driver.find_element(:class, 'event-search').find_elements(:class, 'menu-item').find do |x|
        x.click if x.text == 'incident_id'
      end; sleep 3
      @driver.find_element(:id, 'search_query').send_key('test')
      @driver.find_element(:id, 'submit_button').click; sleep 5
      expect(@driver.current_url).to include('search_query=incident_id%3Dtest')
      expect(@driver.find_element(:class, 'white-space-pre-wrap').text).to eql("Search results for criteria: 'incident_id=test'")
    end

    it 'search "host"' do
      @driver.navigate.to(@url)
      @driver.find_element(:class, 'first-letter').click
      @driver.find_element(:class, 'event-search').find_elements(:class, 'menu-item').find do |x|
        x.click if x.text == 'host'
      end; sleep 3
      @driver.find_element(:id, 'search_query').send_key('test')
      @driver.find_element(:id, 'submit_button').click; sleep 5
      expect(@driver.current_url).to include('search_query=host%3Dtest')
      expect(@driver.find_element(:class, 'white-space-pre-wrap').text).to eql("Search results for criteria: 'host=test'")
    end

    it 'search "application"' do
      @driver.navigate.to(@url)
      @driver.find_element(:class, 'first-letter').click
      @driver.find_element(:class, 'event-search').find_elements(:class, 'menu-item').find do |x|
        x.click if x.text == 'application'
      end; sleep 3
      @driver.find_element(:id, 'search_query').send_key('test')
      @driver.find_element(:id, 'submit_button').click; sleep 5
      expect(@driver.current_url).to include('search_query=application%3Dtest')
      expect(@driver.find_element(:class, 'white-space-pre-wrap').text).to eql("Search results for criteria: 'application=test'")
    end

    it 'switch to events view' do
      @driver.navigate.to(@url)
      @driver.find_element(:link_text, 'Switch to events view').click; sleep 5
      expect(@driver.current_url).to include('test-test/events_view')
      @driver.find_element(:link_text, 'Switch to alarms view').click; sleep 5
      expect(@driver.current_url).to eql(@url)
    end

    it 'delete alarm dashboard' do
      @driver.find_element(:id, 'profile_dropdown').click
      @driver.find_element(:link_text, 'Manage Alarm Dashboards').click; sleep 5
      # delete dash
      @driver.execute_script('window.confirm = function() {return true}')
      @driver.find_elements(:css, 'table > tbody > tr').find do |x|
        x.find_element(:class, 'btn-danger').click if x.find_element(:css, 'td:nth-child(1)').text == ('alyohyn test')
      end; sleep 5
      # check that dash was deleted
      @driver.find_element(:id, 'alarms_dropdown').click
      begin
        @driver.find_element(:link_text, 'alyohyn test')
        raise e
      rescue Selenium::WebDriver::Error::NoSuchElementError
        expect(true).to be_truthy
      end
    end
  end
end