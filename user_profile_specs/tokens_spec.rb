require 'spec_helper'

describe 'Tokens' do

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

  it 'view access tokens' do
    @driver.find_element(:id, 'profile_dropdown').click
    @driver.find_element(:link_text, 'Tokens').click; sleep 5
    expect(@driver.current_url).to include('access_tokens')
    expect(@driver.page_source).to include('Create Token', 'Access Tokens')
  end

  it 'create access token with empty required fields' do
    @driver.find_elements(:name, 'commit').select {|x| x if x.attribute('value') == 'Create' }.first.click; sleep 5
    expect(@driver.find_element(:class, 'create_access_token').find_elements(:class, 'error').size).to eql(2)
  end

  it 'create access token with empty required field "Expires After"' do
    @driver.find_element(:id, 'generate_access_token_hash').click
    @driver.find_elements(:name, 'commit').select {|x| x if x.attribute('value') == 'Create' }.first.click; sleep 5
    expect(@driver.find_element(:class, 'create_access_token').find_elements(:class, 'error').size).to eql(1)
  end

  it 'create access token with empty required field "Access Token Hash"' do
    @driver.navigate.refresh
    @driver.find_element(:class, 'create_access_token').find_element(:name, 'token[expiration_date_time[time[hours]]]').send_key(1)
    @driver.find_element(:class, 'create_access_token').find_element(:name, 'token[expiration_date_time[time[days]]]').send_key(1)
    @driver.find_element(:class, 'create_access_token').find_element(:name, 'token[expiration_date_time[time[months]]]').send_key(1)
    @driver.find_elements(:name, 'commit').select {|x| x if x.attribute('value') == 'Create' }.first.click; sleep 5
    expect(@driver.find_element(:class, 'create_access_token').find_elements(:class, 'error').size).to eql(1)
  end

  it 'create access token with min required params' do
    time = (Time.now + 1.months + 1.days).strftime('%m/%d/%Y')
    @driver.find_element(:id, 'generate_access_token_hash').click
    my_hash = @driver.find_element(:id, 'access_token_access_token_hash').attribute('value')
    @driver.find_elements(:name, 'commit').select {|x| x if x.attribute('value') == 'Create' }.first.click; sleep 5
    # check created token
    expect(@driver.find_element(:class, 'alert-success').displayed?).to be_truthy
    expect(@driver.find_element(:class, 'alert-success').text).to eql("x\nAccess Token Created!")
    expect(@driver.find_element(:class, 'table-hover').find_element(:css, 'tr:nth-child(1) > td:nth-child(1)').text).to eql(my_hash)
    expect(@driver.find_element(:class, 'table-hover').find_element(:css, 'tr:nth-child(1) > td:nth-child(5)').text).to include("#{time}")
  end

  it 'update access token with all params' do
    time = (Time.now + 1.months + 1.days).strftime('%m/%d/%Y')
    my_hash = @driver.find_element(:class, 'table-hover').find_element(:css, 'tr:nth-child(1) > td:nth-child(1)').text
    @driver.find_element(:class, 'table-hover').find_element(:css, 'tr:nth-child(1) > td.span2 > a.btn.access_token_update_button').click if
        my_hash != '[FILTERED]'; sleep 5
    # updating access token
    @driver.find_element(:class, 'edit_access_token').find_element(:id, 'token_internal').click
    @driver.find_element(:class, 'edit_access_token').find_element(:id, 'token_other_read').click
    @driver.find_element(:class, 'edit_access_token').find_element(:id, 'token_metric_read').click
    @driver.find_element(:class, 'edit_access_token').find_element(:id, 'token_event_read').click
    @driver.find_element(:class, 'edit_access_token').find_element(:id, 'token_other_write').click
    @driver.find_element(:class, 'edit_access_token').find_element(:id, 'token_metric_write').click
    @driver.find_element(:class, 'edit_access_token').find_element(:id, 'token_event_write').click
    @driver.find_element(:class, 'edit_access_token').find_element(:id, 'token_description').clear
    @driver.find_element(:class, 'edit_access_token').find_element(:id, 'token_description').send_key('test')
    @driver.find_element(:class, 'edit_access_token').find_element(:id, 'token_email').clear
    @driver.find_element(:class, 'edit_access_token').find_element(:id, 'token_email').send_key 'changeme@change.me'
    @driver.find_element(:class, 'edit_access_token').find_element(:name, 'token[expiration_date_time[time[hours]]]').clear
    @driver.find_element(:class, 'edit_access_token').find_element(:name, 'token[expiration_date_time[time[hours]]]').send_key(1)
    @driver.find_element(:class, 'edit_access_token').find_element(:name, 'token[expiration_date_time[time[days]]]').clear
    @driver.find_element(:class, 'edit_access_token').find_element(:name, 'token[expiration_date_time[time[days]]]').send_key(1)
    @driver.find_element(:class, 'edit_access_token').find_element(:name, 'token[expiration_date_time[time[months]]]').clear
    @driver.find_element(:class, 'edit_access_token').find_element(:name, 'token[expiration_date_time[time[months]]]').send_key(1)
    @driver.find_element(:class, 'edit_access_token').find_element(:name, 'commit').click; sleep 5
    # check new params
    expect(@driver.find_element(:css, 'table > tbody > tr:nth-child(1) > td:nth-child(1)').text).to eql(my_hash)
    expect(@driver.find_element(:css, 'table > tbody > tr:nth-child(1) > td:nth-child(2)').text).to eql('test')
    expect(@driver.find_element(:css, 'table > tbody > tr:nth-child(1) > td:nth-child(5)').text).to include("#{time}")
    expect(@driver.find_element(:css, 'table > tbody > tr:nth-child(1) > td:nth-child(7)').text).to eql('false')
    expect(@driver.find_element(:css, 'table > tbody > tr:nth-child(1) > td:nth-child(9)').text).to eql('true')
    expect(@driver.find_element(:css, 'table > tbody > tr:nth-child(1) > td:nth-child(10)').text).to eql('true')
    expect(@driver.find_element(:css, 'table > tbody > tr:nth-child(1) > td:nth-child(11)').text).to eql('true')
    expect(@driver.find_element(:css, 'table > tbody > tr:nth-child(1) > td:nth-child(12)').text).to eql('true')
    expect(@driver.find_element(:css, 'table > tbody > tr:nth-child(1) > td:nth-child(13)').text).to eql('true')
    expect(@driver.find_element(:css, 'table > tbody > tr:nth-child(1) > td:nth-child(14)').text).to eql('true')
  end

  it 'delete access token' do
    # deletion access token
    my_hash = @driver.find_element(:css, 'table > tbody > tr:nth-child(1) > td:nth-child(1)').text
    @driver.execute_script('window.confirm = function() {return true}')
    @driver.find_element(:class, 'table-hover').find_element(:css, 'tr:nth-child(1) > td.span2 > a:nth-child(2)').click if
        my_hash != '[FILTERED]'; sleep 5
    expect(@driver.find_element(:css, 'table > tbody > tr:nth-child(1) > td:nth-child(1)') == my_hash).to be_falsey
  end
end