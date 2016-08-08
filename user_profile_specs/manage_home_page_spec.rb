require 'spec_helper'

describe 'home_page' do

  before(:all) do
    @driver = Selenium::WebDriver.for :firefox
    @driver.navigate.to 'localhost:3001'

    element = @driver.find_element(:id, 'user_groups')
    element.find_elements(:tag_name => 'option').find do |option|
      option.text == 'OIV_ADMIN'
    end.click
    @driver.find_element(:class, 'form-horizontal').find_element(:name, 'commit').click
  end

  after(:all) do
    @driver.quit
  end

  it 'view current home page' do
    @driver.navigate.to('localhost:3001')
    sleep 5
    expect(@driver.find_element(:css, '[id*=-xre_concurrency_curve]').displayed?).to be_truthy
    expect(@driver.find_element(:css, '[id*=-platform_call_volume]').displayed?).to be_truthy
    @driver.find_element(:id, 'profile_dropdown').click
    @driver.find_element(:link_text, 'Manage Home Page').click; sleep 5
    expect(@driver.current_url).to include('home-page-dashboard')
    expect(@driver.find_element(:css, '[id*=-xre_concurrency_curve]').displayed?).to be_truthy
    expect(@driver.find_element(:css, '[id*=-platform_call_volume]').displayed?).to be_truthy
  end

  it 'edit home page' do
    # change some params on home page
    @driver.find_element(:css, '[id$=-xre_concurrency_curve]').find_element(:name, 'button').click
    @driver.find_element(:css, '[id$=-xre_concurrency_curve]').find_element(:class, 'open_edit_widget_dialog').click; sleep 5
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[name]').send_key ' test'
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'commit').click; sleep 5
    @driver.find_element(:css, '[id$=-platform_call_volume_summary]').find_element(:name, 'button').click
    @driver.find_element(:css, '[id$=-platform_call_volume_summary]').find_element(:class, 'open_edit_widget_dialog').click; sleep 5
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[name]').send_key ' test'
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'commit').click; sleep 5
    @driver.navigate.to('localhost:3001'); sleep 5
    expect(@driver.find_element(:css, '[id*=-xre_concurrency_curve-test]').displayed?).to be_truthy
    expect(@driver.find_element(:css, '[id*=-platform_call_volume_summary-test]').displayed?).to be_truthy

    # restore names
    @driver.find_element(:css, '[id$=-xre_concurrency_curve-test]').find_element(:name, 'button').click
    @driver.find_element(:css, '[id$=-xre_concurrency_curve-test]').find_element(:class, 'open_edit_widget_dialog').click; sleep 5
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[name]').clear
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[name]').send_key 'xre_concurrency_curve'
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'commit').click; sleep 5
    @driver.find_element(:css, '[id$=-platform_call_volume_summary-test]').find_element(:name, 'button').click
    @driver.find_element(:css, '[id$=-platform_call_volume_summary-test]').find_element(:class, 'open_edit_widget_dialog').click; sleep 5
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[name]').clear
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'chart_widget[name]').send_key 'platform_call_volume_summary'
    @driver.find_element(:id, 'edit_widget_dialog').find_element(:name, 'commit').click; sleep 5
  end

  it 'change home page' do
    # set another dash as Home Page
    @driver.find_element(:id, 'dashboards_dropdown_lite').click
    @driver.find_element(:link_text, 'X1 Errors Dashboard').click; sleep 5
    @driver.find_element(:class, 'custom-landing-page').click; sleep 5
    expect(@driver.find_element(:css, '[id*=-xre_guide_startup_errors]').displayed?).to be_truthy
    expect(@driver.find_element(:css, '[id*=-xre_parental_controls_errors]').displayed?).to be_truthy
    expect(@driver.find_element(:css, '[id*=-xre_tuning_errors]').displayed?).to be_truthy
    # check Manage Home Page new dash
    @driver.find_element(:id, 'profile_dropdown').click
    @driver.find_element(:link_text, 'Manage Home Page').click; sleep 5
    expect(@driver.find_element(:class, 'center').text).to eql('X1 Errors Dashboard')
    # restore landing page
    @driver.find_element(:class, 'custom-landing-page').click
  end
end