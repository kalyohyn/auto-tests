#
# After testing - destroy created test Role 'KALYOHYN_TEST' at UI staging console
#       Role.where(name: 'KALYOHYN_TEST').first.destroy
#

require 'spec_helper'

describe 'User Rights' do

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

  before(:each) do
    @driver.navigate.to('https://intel-staging.xcal.tv/rights')
  end

  it 'view rights' do
    expect(@driver.page_source).to include('Add new right for specific user role', 'Create new role', 'Assigned rights')
    # check notification - open/close
    @driver.find_element(:class, 'icon-question-sign').click
    expect(@driver.find_element(:class, 'rights-doc-hint').displayed?).to be_truthy
    @driver.find_element(:class, 'icon-question-sign').click; sleep 5
    expect(@driver.find_element(:class, 'rights-doc-hint').displayed?).to be_falsey
    # check right details - open/close
    element = @driver.find_element(:id, 'rights_accordion').find_elements(:css, 'div.accordion-heading > a')
    element.each { |x| x.click if x.text == 'NON_OIV_GROUP'}; sleep 5
    expect(@driver.find_element(:class, 'accordion-inner').displayed?).to be_truthy

    element = @driver.find_element(:id, 'rights_accordion').find_elements(:css, 'div.accordion-heading > a')
    element.each { |x| x.click if x.text == 'NON_OIV_GROUP'}; sleep 5
    expect(@driver.find_element(:id, 'rights_accordion').find_element(:class, 'accordion-inner').displayed?).to be_falsey
  end

  # bug here - 500 error
  xit 'create new role without name' do
    @driver.find_elements(:name, 'commit').find { |x| x.click if x.attribute('value') == 'Create' }; sleep 5
    expect(@driver.current_url).to include('rights')
  end

  it 'create new role' do
    @driver.find_element(:id, 'new_role').send_key('kalyohyn_test')
    @driver.find_elements(:name, 'commit').find { |x| x.click if x.attribute('value') == 'Create' }; sleep 5
    # check alert notification
    expect(@driver.find_element(:class, 'alert-notice').text).to eql ("x\nRole kalyohyn_test successfully created")
    @driver.find_element(:class, 'alert-notice').find_element(:class, 'close').click; sleep 5
    begin
      @driver.find_element(:class, 'alert-notice')
      raise e
    rescue Selenium::WebDriver::Error::NoSuchElementError
      expect(true).to be_truthy
    end
    # check new role
    expect(@driver.find_element(:id, 'rights_accordion').find_elements(:css, 'div.accordion-heading > a').collect { |x| x.text }).to include('KALYOHYN_TEST')
  end

  # bug here - 500 error
  xit 'create role with existed name' do
    @driver.find_element(:id, 'new_role').send_key('kalyohyn_test')
    @driver.find_elements(:name, 'commit').find { |x| x.click if x.attribute('value') == 'Create' }; sleep 5
    expect(@driver.current_url).to include('rights')
  end

  it 'assign rights to role' do
    # pick number of the rights and choose new role
    @driver.find_element(:id, 'rights_accordion').find_elements(:css, 'div.accordion-heading > a').each { |x| x.click if x.text == 'TEST' }
    count = @driver.find_element(:id, 'TEST').find_elements(:css, 'table > tbody > tr').size
    @driver.find_element(:id, 'role').find_elements(tag_name: 'option').find { |x| x.text == 'KALYOHYN_TEST' }.click
    @driver.find_element(:id, 'source_role').find_elements(tag_name: 'option').find { |x| x.text == 'TEST' }.click
    @driver.find_element(:class, 'form-horizontal').find_element(:name, 'commit').click; sleep 5
    # check that rights were added
    expect(@driver.find_element(:class, 'alert-notice').displayed?).to be_truthy
    expect(@driver.find_element(:class, 'alert-notice').text).to include('Rights for KALYOHYN_TEST successfully cloned from the role TEST')
    @driver.find_element(:id, 'rights_accordion').find_elements(:css, 'div.accordion-heading > a').each { |x| x.click if x.text == 'KALYOHYN_TEST' }; sleep 5
    expect(@driver.find_element(:id, 'KALYOHYN_TEST').find_elements(:css, 'table > tbody > tr').size).to be == count
  end

  it 'assign new right to the role' do
    # pick right
    count = @driver.find_element(:id, 'KALYOHYN_TEST').find_elements(:css, 'table > tbody > tr').size
    # add new right to tre role
    @driver.find_element(:id, 'right').send_key('alarm_view')
    @driver.find_element(:class, 'form-horizontal').find_element(:name, 'commit').click; sleep 5
    # check that role was not added
    expect(@driver.find_element(:class, 'alert-notice').displayed?).to be_truthy
    expect(@driver.find_element(:class, 'alert-notice').text).to include("Access to alarm_view for User Role: KALYOHYN_TEST successfully created")
    # @driver.find_element(:id, 'rights_accordion').find_elements(:css, 'div.accordion-heading > a').each { |x| x.click if x.text == 'KALYOHYN_TEST' }
    expect(@driver.find_element(:id, 'KALYOHYN_TEST').find_elements(:css, 'table > tbody > tr').size).to be == count + 1
  end

  it 'assign existed right to the role' do
    # pick right
    count = @driver.find_element(:id, 'KALYOHYN_TEST').find_elements(:css, 'table > tbody > tr').size
    # add new right to tre role
    @driver.find_element(:id, 'right').send_key('alarm_view')
    @driver.find_element(:class, 'form-horizontal').find_element(:name, 'commit').click; sleep 5
    # check that role was not added
    expect(@driver.find_element(:class, 'alert-notice').displayed?).to be_truthy
    expect(@driver.find_element(:class, 'alert-notice').text).to include("Can't add 'alarm_view' right because it already present in 'KALYOHYN_TEST'")
    expect(@driver.find_element(:id, 'KALYOHYN_TEST').find_elements(:css, 'table > tbody > tr').size).to be == count
  end

  it 'remove role' do
    @driver.navigate.refresh
    # pick right and role what will be deleted
    @driver.find_element(:id, 'rights_accordion').find_elements(:css, 'div.accordion-heading > a').each { |x| x.click if x.text == 'KALYOHYN_TEST'}; sleep 5
    count = @driver.find_element(:id, 'KALYOHYN_TEST').find_elements(:css, 'table > tbody > tr').size
    number = rand(1..count)
    access =  @driver.find_element(:css, "table > tbody > tr:nth-child(#{number}) > td:nth-child(2)").text.downcase!
    # delete role
    @driver.find_element(:css, "table > tbody > tr:nth-child(#{number})").find_element(:name, 'commit').click
    # check that role was deleted
    expect(@driver.find_element(:class, 'alert-notice').displayed?).to be_truthy
    @driver.find_element(:id, 'rights_accordion').find_elements(:css, 'div.accordion-heading > a').each { |x| x.click if x.text == 'KALYOHYN_TEST'}; sleep 5
    expect((@driver.find_elements(:css, 'table > tbody > tr').collect { |x| x.find_element(:css, 'td:nth-child(2)').text }).include?(access)).to be_falsey
  end
end