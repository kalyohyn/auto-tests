require 'spec_helper'

describe 'dashboards' do

  before(:all) do
    @name = 'alyohyn test'
    @driver = Selenium::WebDriver.for :firefox
    @driver.navigate.to('https://intel-staging.xcal.tv')
    @driver.find_element(:name => 'login').send_key('[FILTERED]')
    @driver.find_element(:name => 'password').send_key('[FILTERED]')
    @driver.find_element(:name => 'commit').submit
  end

  after(:all) do
    @driver.quit
  end

  it 'search dashboard' do
    @driver.find_element(:id, 'dashboards_dropdown_full').click
    @driver.find_element(:class, 'dropdown-large-search-form').find_element(:id, 'dropdown-search-query').send_key('kalyohyn dash')
    @driver.find_element(:class, 'dropdown-large-search-form').find_element(:class, 'btn').click; sleep 5
    expect(@driver.current_url).to include("search_query=kalyohyn+dash")
    expect(@driver.find_element(:id, 'search_query').attribute('value')).to eql('kalyohyn dash')
    element = @driver.find_elements(:css, 'table > tbody > tr').collect { |x| x.find_element(:css, 'td:nth-child(1)').text }
    expect(element).to include('kalyohyn dash')
  end

  it 'search non-exist dashboard' do
    @driver.find_element(:id, 'dashboards_dropdown_full').click
    @driver.find_element(:class, 'dropdown-large-search-form').find_element(:id, 'dropdown-search-query').send_key('blablabla')
    @driver.find_element(:class, 'dropdown-large-search-form').find_element(:class, 'btn').click; sleep 5
    expect(@driver.current_url).to include("search_query=blablabla")
    expect(@driver.find_elements(:css, 'table > tbody > tr').size).to eql(0)
  end

  it 'search all dashboards' do
    @driver.find_element(:id, 'dashboards_dropdown_full').click
    @driver.find_element(:class, 'dropdown-large-search-form').find_element(:class, 'btn').click; sleep 5
    expect(@driver.current_url).to include("search_query=")
    expect(@driver.find_element(:id, 'search_query').attribute('value')).to eql('')
  end

  it 'view user_profile -> search dashboards' do
    @driver.find_element(:id, 'profile_dropdown').click
    @driver.find_element(:link_text, 'Search Dashboards').click; sleep 5
    expect(@driver.current_url).to include('search')
    expect(@driver.find_element(:class, 'dashboards-content').displayed?).to be_truthy
  end


  it 'create dashboard with empty required fields' do
    @driver.find_element(:id, 'dashboards_dropdown_full').click
    @driver.find_element(:link_text, 'Create Dashboard').click
    @driver.find_element(:id, 'edit_dashboard_dialog_').find_element(:name, 'commit').click; sleep 5
    expect(@driver.find_elements(:class, 'error').size).to eql (1)
    @driver.find_element(:id, 'edit_dashboard_dialog_').find_element(:class, 'close').click
  end

  it 'create dashboard' do
    @driver.find_element(:id, 'dashboards_dropdown_full').click
    @driver.find_element(:link_text, 'Create Dashboard').click
    @driver.find_element(:id, 'dashboard_role_ids').send_key('GROUP_ADMIN_DASHBOARD')
    @driver.find_element(:id, 'dashboard_name').send_key(@name)
    @driver.find_element(:id, 'edit_dashboard_dialog_').find_element(:name, 'commit').click; sleep 5
    expect(@driver.current_url).to include('alyohyn-test')
    expect(@driver.find_element(:class, 'center').text).to eql(@name)
    @driver.find_element(:id, 'dashboards_dropdown_full').click
    expect(@driver.find_element(:link_text, @name).displayed?).to be_truthy
  end

  it 'create dashboard with an existing name' do
    @driver.find_element(:link_text, 'Create Dashboard').click
    @driver.find_element(:id, 'dashboard_name').send_key(@name)
    @driver.find_element(:id, 'edit_dashboard_dialog_').find_element(:name, 'commit').click; sleep 5
    expect(@driver.find_elements(:class, 'error').size).to eql (1)
    @driver.find_element(:id, 'edit_dashboard_dialog_').find_element(:class, 'close').click
  end

  it 'star' do
    # open dashboard
    @driver.find_element(:id, 'dashboards_dropdown_full').click
    @driver.find_element(:link_text, @name).click; sleep 5
    # star
    @driver.find_element(:class, 'star-text').click; sleep 5
    expect(@driver.find_element(:class, 'star-text').text).to eql('Unstar')
    # check nav tab
    @driver.navigate.to('https://intel-staging.xcal.tv')
    @driver.find_element(:id, 'my_stars_dropdown').click
    expect(@driver.find_element(:link_text, @name).displayed?).to be_truthy
    @driver.find_element(:link_text, @name).click; sleep 5
    expect(@driver.current_url).to include('alyohyn-test')
  end

  it 'unstar' do
    @driver.find_element(:class, 'star-text').click; sleep 5
    expect(@driver.find_element(:class, 'star-text').text).to eql('Star')
    @driver.navigate.to('https://intel-staging.xcal.tv')
    begin
      @driver.find_element(:id, 'my_stars_dropdown')
      raise e
    rescue Selenium::WebDriver::Error::NoSuchElementError
      expect(true).to be_truthy
    end
  end

  it 'layout for 2 columns' do
    @driver.find_element(:id, 'dashboards_dropdown_full').click
    @driver.find_element(:link_text, @name).click; sleep 5
    @driver.find_element(:link_text, 'Layout').click
    expect(@driver.find_element(:class, 'layout-a-selected').displayed?).to be_truthy
    @driver.find_element(:class, 'layout-ab').click; sleep 5
    expect(@driver.find_elements(:class, 'column-for-draggable').size).to eql (2)
    @driver.find_element(:link_text, 'Layout').click
    expect(@driver.find_element(:class, 'layout-ab-selected').displayed?).to be_truthy
    @driver.find_element(:id, 'edit_layout_dialog').find_element(:class, 'close').click
  end

  it 'dashboard history' do
    expect(@driver.find_element(:class, 'dashboard-audit').text).to include('Last changed by [FILTERED]')
    @driver.find_element(:class, 'open_history_dialog').click; sleep 5
    expect(@driver.find_element(:id, 'open_history_dialog').displayed?).to be_truthy
    expect(@driver.find_element(:id, 'dashboard_history_content').displayed?).to be_truthy
    @driver.find_element(:class, 'modal-backdrop').click
    expect(@driver.find_element(:id, 'open_history_dialog').displayed?).to be_falsey
  end

  it 'my landing page' do
    @driver.navigate.refresh
    url = @driver.current_url
    expect(@driver.find_element(:class, 'custom-landing-page').text).to eql('Make this view my landing page')
    @driver.find_element(:class, 'custom-landing-page').click; sleep 5
    expect(@driver.current_url).to include('intel-staging.xcal.tv')
    @driver.navigate.to(url); sleep 5
    expect(@driver.find_element(:class, 'custom-landing-page').text).to eql('Restore to default landing page')
    @driver.find_element(:class, 'custom-landing-page').click; sleep 5
    expect(@driver.current_url).to include('intel-staging.xcal.tv')
    expect(@driver.find_element(:id, 'DVR_Success').displayed?).to be_truthy
  end

  it 'restore to default landing page from landing page' do
    @driver.find_element(:id, 'dashboards_dropdown_full').click
    @driver.find_element(:link_text, @name).click; sleep 5
    @driver.find_element(:class, 'custom-landing-page').click; sleep 5
    expect(@driver.current_url).to eql('https://intel-staging.xcal.tv/')
    expect(@driver.find_element(:class, 'custom-landing-page').displayed?).to be_truthy
    @driver.find_element(:class, 'custom-landing-page').click; sleep 5
    expect(@driver.current_url).to eql('https://intel-staging.xcal.tv/')
    expect(@driver.find_element(:id, 'DVR_Success').displayed?).to be_truthy
  end

  it 'manage dashboard' do
    @driver.find_element(:id, 'dashboards_dropdown_full').click
    @driver.find_element(:link_text, @name).click; sleep 5
    @driver.find_element(:link_text, 'Manage').click
    @driver.find_element(:name, 'dashboard[name]').clear
    @driver.find_element(:name, 'dashboard[name]').send_key "#{@name} test"
    @driver.find_element(:class, 'manage_dashboard_form').find_element(:name, 'commit').click; sleep 5
    expect(@driver.find_element(:class, 'center').text).to eql("#{@name} test")
  end

  it 'delete dashboard' do
    @driver.execute_script('window.confirm = function() {return true}')
    @driver.find_element(:link_text, 'Delete').click; sleep 5
    # check that dashboard was deleted
    expect(@driver.current_url).to include('intel-staging.xcal.tv')
    @driver.find_element(:id, 'dashboards_dropdown_full').click
    begin
      @driver.find_element(:link_text, "#{@name} test")
      raise e
    rescue Selenium::WebDriver::Error::NoSuchElementError
      expect(true).to be_truthy
    end
  end
end
