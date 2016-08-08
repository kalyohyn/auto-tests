require 'spec_helper'

describe 'Manage Landing Page' do

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

  it 'view manage landing page' do
    @driver.find_element(:id, 'profile_dropdown').click
    @driver.find_element(:link_text, 'Manage Landing Pages').click; sleep 5
    expect(@driver.current_url).to include('manage_landing_pages')
    expect(@driver.page_source).to include('Manage Landing Pages')
    # check tenant list
    @driver.find_element(:css, 'table > tbody > tr > td:nth-child(1) > a').click; sleep 5
    expect(@driver.current_url).to include('tenants')
    @driver.find_element(:link_text, 'Back').click; sleep 5
    # check dashboard
    @driver.find_element(:css, 'table > tbody > tr > td:nth-child(2) > a').click; sleep 5
    expect(@driver.find_element(:class, 'center').text).to eql('X1 Tune')
  end

  it 'create new associate' do
    @driver.navigate.to('https://intel-staging.xcal.tv/manage_landing_pages'); sleep 5
    @driver.find_element(:id, 'home_page_dashboard_tenant_tenant_id').send_key('Cox-dev')
    @driver.find_element(:id, 'home_page_dashboard_tenant_dashboard_id').send_key('kalyohyn dash')
    @driver.find_element(:name, 'commit').click; sleep 5
    tenant = @driver.find_elements(:css, 'table > tbody > tr').find do |x|
      x if x.find_element(:css, 'td:nth-child(1)').text == 'Cox-dev'
    end
    expect(tenant.find_element(:css, 'td:nth-child(2)').text).to eql('kalyohyn dash')
  end

  it 'associate existed tenant' do
    @driver.find_element(:id, 'home_page_dashboard_tenant_tenant_id').send_key('Cox-dev')
    @driver.find_element(:id, 'home_page_dashboard_tenant_dashboard_id').send_key('X1 Tune')
    @driver.find_element(:name, 'commit').click; sleep 5
    tenant = @driver.find_elements(:css, 'table > tbody > tr').find do |x|
      x if x.find_element(:css, 'td:nth-child(1)').text == 'Cox-dev'
    end
    # check that another dash associated with this tenant
    expect(tenant.find_element(:css, 'td:nth-child(2)').text).to eql('X1 Tune')
  end

  it 'disassociate' do
    count = @driver.find_elements(:css, 'table > tbody > tr').size
    @driver.execute_script('window.confirm = function() {return true}')
    @driver.find_elements(:css, 'table > tbody > tr').find do |x|
      x.find_element(:class, 'btn-danger').click if x.find_element(:css, 'td:nth-child(1)').text == 'Cox-dev'
    end
    expect(@driver.find_elements(:css, 'table > tbody > tr').size).to be < count
  end
end
