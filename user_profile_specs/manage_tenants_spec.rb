require 'spec_helper'

describe 'Manage Tenants' do

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

  it 'view tenants' do
    @driver.find_element(:id, 'profile_dropdown').click
    @driver.find_element(:link_text, 'Manage Tenants').click; sleep 5
    expect(@driver.current_url).to include('tenants')
    expect(@driver.find_element(:link_text, 'Manage Home Page Associations').displayed?).to be_truthy
    # check Manage Home Page Associations btn
    @driver.find_element(:link_text, 'Manage Home Page Associations').click; sleep 5
    expect(@driver.current_url).to include('manage_landing_pages')
    @driver.find_element(:link_text, 'Back').click
  end

  it 'create tenant with empty required fields' do
    @driver.find_element(:link_text, 'Create Tenant').click; sleep 5
    @driver.find_element(:id, 'tenant_dialog').find_element(:name, 'commit').click; sleep 5
    expect(@driver.find_element(:id, 'tenant_dialog').find_elements(:class, 'error').size).to eql(1)
    @driver.find_element(:id, 'tenant_dialog').find_element(:class, 'close').click; sleep 5
    expect(@driver.find_element(:id, 'tenant_dialog').displayed?).to be_falsey
  end

  it 'create tenant' do
    @driver.find_element(:link_text, 'Create Tenant').click; sleep 5
    @driver.find_element(:name, 'tenant[name]').send_key('alyohyn test')
    @driver.find_element(:id, 'tenant_approved').click
    @driver.find_element(:id, 'tenant_dialog').find_element(:name, 'commit').click; sleep 5
    # check created tenant
    element = @driver.find_elements(:css, 'table > tbody > tr').collect do |x|
      x.find_element(:css, 'td:nth-child(1)').text
    end
    expect(element).to include('alyohyn test')
  end

  it 'create tenant with existed name' do
    @driver.find_element(:link_text, 'Create Tenant').click; sleep 5
    @driver.find_element(:name, 'tenant[name]').send_key('alyohyn test')
    @driver.find_element(:id, 'tenant_approved').click
    @driver.find_element(:id, 'tenant_dialog').find_element(:name, 'commit').click; sleep 5
    expect(@driver.find_element(:id, 'tenant_dialog').find_elements(:class, 'error').size).to eql(1)
    @driver.find_element(:id, 'tenant_dialog').find_element(:class, 'close').click
  end

  it 'edit tenant' do
    @driver.find_elements(:css, 'table > tbody > tr').find do |x|
      x.find_element(:link_text, 'Edit').click if x.find_element(:css, 'td:nth-child(1)').text == 'alyohyn test'
    end; sleep 5
    @driver.find_element(:name, 'tenant[name]').send_key(' test')
    @driver.find_element(:id, 'tenant_dialog').find_element(:name, 'commit').click; sleep 5
    # check edited tenant
    element = @driver.find_elements(:css, 'table > tbody > tr').collect do |x|
      x.find_element(:css, 'td:nth-child(1)').text
    end
    expect(element).to include('alyohyn test test')
  end

  it 'assign default roles' do
    @driver.find_elements(:css, 'table > tbody > tr').find do |x|
      x.find_element(:class, 'tenant_roles_button').click if x.find_element(:css, 'td:nth-child(1)').text == 'alyohyn test test'
    end; sleep 5
    expect(@driver.find_element(:id, 'roles_list_dialog').displayed?).to be_truthy
    @driver.find_element(:id, 'roles').send_key('OIV_ADMIN')
    @driver.find_element(:id, 'roles_list_dialog').find_element(:name, 'commit').click; sleep 5
    expect(@driver.find_element(:class, 'alert-notice').displayed?).to be_truthy
    element = @driver.find_elements(:css, 'table > tbody > tr').collect do |x|
      x.find_element(:css, 'td:nth-child(3)').text
    end
    expect(element).to include('OIV_ADMIN')
  end

  it 'delete tenant' do
    @driver.execute_script('window.confirm = function() {return true}')
    @driver.find_elements(:css, 'table > tbody > tr').find do |x|
      x.find_element(:class, 'btn-danger').click if x.find_element(:css, 'td:nth-child(1)').text == 'alyohyn test test'
    end; sleep 5
    # check, that tenant was deleted
    element = @driver.find_elements(:css, 'table > tbody > tr').collect do |x|
      x.find_element(:css, 'td:nth-child(1)').text
    end
    expect(element.include?('test_tenant test')).to be_falsey
  end
end