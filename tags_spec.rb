require 'spec_helper'

describe 'Tags tab' do

  before(:all) do
    @tag = 'test'
    @driver = Selenium::WebDriver.for :firefox
    @driver.navigate.to 'https://intel-staging.xcal.tv'
    @driver.find_element(:name => 'login').send_key('[FILTERED]')
    @driver.find_element(:name => 'password').send_key('[FILTERED]')
    @driver.find_element(:name => 'commit').submit
  end

  before(:each) do
    @driver.find_element(:link_text, 'Tags').click; sleep 5
  end

  after(:all) do
    @driver.quit
  end

  it 'tags list' do
    expect(@driver.current_url).to eql('https://intel-staging.xcal.tv/tags')
    expect(@driver.find_element(:id, 'alphabetical_tags_list').displayed?).to be_truthy
    expect(@driver.find_element(:id, 'tags_list').displayed?).to be_truthy
  end

  it 'tag view' do
    element = @driver.find_element(:id, 'tags_list').find_elements(:class, 'tagmanagerTag').select { |x| x if x.text == 'test' }
    element.first.click; sleep 5
    expect(@driver.current_url).to include("tags/#{@tag}")
    expect(@driver.page_source).to include("#{@tag} Tag")
  end

  it 'jump to tag' do
    letter = 'Y'
    @driver.find_element(:link_text, "#{letter}").click
    expect(@driver.current_url).to include("/tags/letter/#{letter}")
    @driver.find_element(:link_text, 'All').click
    expect(@driver.current_url).to eql('https://intel-staging.xcal.tv/tags')
  end

  it 'search tag name' do
    @driver.find_element(:id, 'search_tag_input').send_key("#{@tag}"); sleep 5
    @driver.find_element(:class, 'search').find_element(:class, 'active').click
    expect(@driver.current_url).to include("/tags/#{@tag}")
    expect(@driver.page_source).to include("#{@tag} Tag")
    expect(@driver.page_source).to include('Alarms fired in the last 48 hours', 'Events fired in the last 48 hours')
  end
end
