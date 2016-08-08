require 'spec_helper'

describe 'Manage Users ' do

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

  it 'view users' do
    @driver.find_element(:id, 'profile_dropdown').click
    @driver.find_element(:link_text, 'Manage Users').click; sleep 5
    expect(@driver.current_url).to include('/users')
    expect(@driver.find_element(:css, 'table').displayed?).to be_truthy
  end

  it 'search existed user with part name' do
    @driver.find_element(:id, 'login').send_key('dev')
    @driver.find_element(:class, 'form-search').find_element(:class, 'btn').click; sleep 5
    @driver.find_element(:id, 'login').clear
    expect(@driver.current_url).to include('users?login=dev')
    expect(@driver.find_elements(:css, 'table > tbody > tr').size).to eql(1)
  end

  it 'search existed user with full name' do
    @driver.find_element(:id, 'login').send_key('dev user')
    @driver.find_element(:class, 'form-search').find_element(:class, 'btn').click; sleep 5
    @driver.find_element(:id, 'login').clear
    expect(@driver.current_url).to include('users?login=dev+user')
    expect(@driver.find_elements(:css, 'table > tbody > tr').size).to eql(1)
  end

  it 'search non existed user' do
    @driver.find_element(:id, 'login').send_key('blabla')
    @driver.find_element(:class, 'form-search').find_element(:class, 'btn').click; sleep 5
    @driver.find_element(:id, 'login').clear
    expect(@driver.current_url).to include('users?login=blabla')
    expect(@driver.find_elements(:css, 'table > tbody > tr').size).to eql(0)
  end

  it 'sort users by bootstrap login' do
    @driver.navigate.to('localhost:3001/users')
    @driver.find_elements(:css, 'table > thead > tr > th').find do |x|
      x.click if x.find_element(:class, 'tablesorter-header-inner').text == 'Login'
    end; sleep 5
    expect(@driver.current_url).to include('users/profile-desc')
    el = @driver.find_element(:class, 'table-hover').find_elements(:css, 'thead > tr > th')
    expect(el.find { |x| x.find_element(:class, 'icon-chevron-up') }.displayed?).to be_truthy

    @driver.find_elements(:css, 'table > thead > tr > th').find do |x|
      x.click if x.find_element(:class, 'tablesorter-header-inner').text == 'Login'
    end; sleep 5
    element = @driver.find_element(:class, 'table-hover').find_elements(:css, 'thead > tr > th')
    expect(element.find { |x| x.find_element(:class, 'icon-chevron-down') }.displayed?).to be_truthy
  end

  it 'sort users by bootstrap last login' do
    @driver.navigate.to('localhost:3001/users')
    @driver.find_element(:class, 'table-hover').find_elements(:css, 'thead > tr').find do |x|
      x.find_element(:css, 'th:nth-child(5)').click
    end; sleep 5
    expect(@driver.current_url).to include('users/last-login-asc')
  end

  it 'sort users by bootstrap last signed out' do
    @driver.navigate.to('localhost:3001/users')
    @driver.find_element(:class, 'table-hover').find_elements(:css, 'thead > tr').find do |x|
      x.find_element(:css, 'th:nth-child(6)').click
    end; sleep 5
    expect(@driver.current_url).to include('users/signed-out-at-asc')
  end

  it 'assign roles for the user' do
    @driver.find_elements(:css, 'table > tbody > tr').find { |x| x.find_element(:class, 'user_roles_button').click }; sleep 5
    expect(@driver.find_element(:id, 'roles_list_dialog').displayed?).to be_truthy
    @driver.find_element(:id, 'roles_list_dialog').find_element(:class, 'close').click; sleep 5
    expect(@driver.find_element(:id, 'roles_list_dialog').displayed?).to be_falsey
    @driver.find_elements(:css, 'table > tbody > tr').find { |x| x.find_element(:class, 'user_roles_button').click }
    @driver.find_element(:id, 'roles').send_key('OIV_USER')
    @driver.find_element(:name, 'commit').click; sleep 5
    expect(@driver.find_element(:css, 'table > tbody > tr > td:nth-child(7)').text).to include('OIV_USER')
    # restore original role
    @driver.find_elements(:css, 'table > tbody > tr').find { |x| x.find_element(:class, 'user_roles_button').click }
    @driver.find_element(:id, 'roles').send_key('OIV_ADMIN')
    @driver.find_element(:name, 'commit').click
  end
end