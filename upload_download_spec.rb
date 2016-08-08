require 'spec_helper'

describe 'download file' do

  before(:all) do
    @wait = Selenium::WebDriver::Wait.new(:timeout => 10)
    @start_date = (Time.now - 1.days).strftime('%Y-%m-%d')
    @end_date = Time.now.strftime('%Y-%m-%d')
    @download_dir = File.join(Dir.pwd, 'spec/gui_tests/Downloads')
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['browser.download.folderList'] = 2
    profile['browser.download.dir'] = @download_dir
    profile['browser.helperApps.neverAsk.saveToDisk'] = 'application/octet-stream, text/csv, image/png, application/csv, application/yaml'
    profile['browser.helperApps.neverAsk.openFile'] = 'application/octet-stream, text/csv, image/png, application/csv, application/yaml'
    profile['browser.download.manager.showWhenStarting'] = false
    @driver = Selenium::WebDriver.for :firefox, :profile => profile
    @driver.navigate.to('https://intel-staging.xcal.tv')
    @driver.find_element(:name => 'login').send_key('[FILTERED]')
    @driver.find_element(:name => 'password').send_key('[FILTERED]')
    @driver.find_element(:name => 'commit').submit
  end

  after(:all) do
    @driver.quit
  end

  it 'download csv file from reports' do
    @driver.navigate.to('intel-staging.xcal.tv/reports/top_alarms'); sleep 5
    @driver.find_element(:link_text, 'Download CSV').click; sleep 5
    File.open("#{@download_dir}/#{@end_date}.csv")
    expect(File).to exist(@download_dir)
    File.delete("#{@download_dir}/#{@end_date}.csv")
  end

  it 'download csv file from users' do
    @driver.navigate.to('intel-staging.xcal.tv/users'); sleep 5
    @driver.find_element(:link_text, 'Download CSV').click; sleep 5
    File.open("#{@download_dir}/user_report.csv")
    expect(File).to exist(@download_dir)
    File.delete("#{@download_dir}/user_report.csv")
  end

  it 'download csv file from ChartWidget' do
    @driver.navigate.to('https://intel-staging.xcal.tv/'); sleep 5
    @driver.find_element(:css, '[id*=-dvr-success]').find_element(:class, 'highcharts-button').click; sleep 1
    @driver.find_element(:css, 'div.highcharts-contextmenu > div > div:nth-child(1)').click; sleep 5
    @wait.until { File.open("#{@download_dir}/DVR Success.csv") }
    expect(File).to exist(@download_dir)
    File.delete("#{@download_dir}/DVR Success.csv")
  end

  it 'download png file from ChartWidget' do
    @driver.navigate.to('https://intel-staging.xcal.tv/'); sleep 5
    @driver.find_element(:css, '[id*=-dvr-success]').find_element(:class, 'highcharts-button').click; sleep 1
    @driver.find_element(:css, 'div.highcharts-contextmenu > div > div:nth-child(2)').click; sleep 5
    @wait.until { File.open("#{@download_dir}/DVR Success.png") }
    expect(File).to exist(@download_dir)
    File.delete("#{@download_dir}/DVR Success.png")
  end

  it 'download csv file from Histogram for Alarming Events' do
    @driver.find_element(:id, 'profile_dropdown').click; sleep 3
    @driver.find_element(:link_text, 'Manage Alarms').click; sleep 5
    @driver.find_element(:id, 'alarm_management').find_element(:css, 'tbody > tr:nth-child(1) > td:nth-child(1) > a').click; sleep 5
    @driver.find_element(:class, 'histogram_container').find_element(:class, 'highcharts-button').click; sleep 1
    @driver.find_element(:css, 'div.highcharts-contextmenu > div > div:nth-child(1)').click; sleep 5
    @wait.until { File.open("#{@download_dir}/Histogram for Alarming Events.csv") }
    expect(File).to exist(@download_dir)
    File.delete("#{@download_dir}/Histogram for Alarming Events.csv")
  end

  it 'download png file from Histogram for Alarming Events' do
    @driver.find_element(:id, 'profile_dropdown').click; sleep 3
    @driver.find_element(:link_text, 'Manage Alarms').click; sleep 5
    @driver.find_element(:id, 'alarm_management').find_element(:css, 'tbody > tr:nth-child(1) > td:nth-child(1) > a').click; sleep 5
    @driver.find_element(:class, 'histogram_container').find_element(:class, 'highcharts-button').click; sleep 1
    @driver.find_element(:css, 'div.highcharts-contextmenu > div > div:nth-child(2)').click; sleep 5
    @wait.until { File.open("#{@download_dir}/Histogram for Alarming Events.png") }
    expect(File).to exist(@download_dir)
    File.delete("#{@download_dir}/Histogram for Alarming Events.png")
  end

  context 'export/import dashboard' do

    before(:all) do
      @upload_dir = File.join(Dir.pwd, 'spec/gui_tests/Uploads')
      @driver.find_element(:id, 'dashboards_dropdown_full').click
      @driver.find_element(:link_text, 'kalyohyn dash').click
    end

    it 'export' do
      @driver.find_element(:link_text, 'Export').click
      @driver.find_element(:id, 'select_all_export').click
      @driver.find_element(:class, 'form-export-widgets').find_element(:name, 'commit').click
      @wait.until { File.open("#{@download_dir}/kalyohyn dash.yml") }
      expect(File).to exist(@download_dir)
      File.delete("#{@download_dir}/kalyohyn dash.yml")
      @driver.find_element(:id, 'export_widgets_dialog').find_element(:class, 'close').click
    end

    it 'import yml file' do
      @driver.find_element(:link_text, 'Import').click
      expect(@driver.find_element(:id, 'import_widgets_dialog').displayed?).to be_truthy
      filename = 'import.yml'
      file = File.join(@upload_dir, filename)
      @driver.find_element(:id, 'yaml_config').send_key(file)
      expect(@driver.find_element(:id, 'yaml_config').attribute('value')).to eql('import.yml')
      @driver.find_element(:id, 'import_widgets_dialog').find_element(:name, 'commit').click; sleep 10
      # check new widget
      expect(@driver.find_element(:class, 'alert-notice').displayed?).to be_truthy
      expect(@driver.find_element(:class, 'alert-notice').text).to include('Import finished. Imported 1 widgets and 1 series.')
      expect(@driver.find_element(:css, '[id*=-test-import]').displayed?).to be_truthy
      # delete widget
      @driver.execute_script('window.confirm = function() {return true}')
      @driver.find_element(:css, '[id$=-test-import]').find_element(:link_text, 'Delete').click
    end

    it 'import yaml file' do
      @driver.find_element(:link_text, 'Import').click
      expect(@driver.find_element(:id, 'import_widgets_dialog').displayed?).to be_truthy
      filename = 'import.yaml'
      file = File.join(@upload_dir, filename)
      @driver.find_element(:id, 'yaml_config').send_key(file)
      expect(@driver.find_element(:id, 'yaml_config').attribute('value')).to eql('import.yaml')
      @driver.find_element(:id, 'import_widgets_dialog').find_element(:name, 'commit').click; sleep 10
      # check new widget
      expect(@driver.find_element(:css, '[id*=-test-import]').displayed?).to be_truthy
      expect(@driver.find_element(:class, 'alert-notice').displayed?).to be_truthy
      expect(@driver.find_element(:class, 'alert-notice').text).to include('Import finished. Imported 1 widgets and 1 series.')
      # delete widget
      @driver.execute_script('window.confirm = function() {return true}')
      @driver.find_element(:css, '[id$=-test-import]').find_element(:link_text, 'Delete').click
    end

    it 'import yml with errors file' do
      @driver.find_element(:link_text, 'Import').click
      expect(@driver.find_element(:id, 'import_widgets_dialog').displayed?).to be_truthy
      filename = 'error import.yml'
      file = File.join(@upload_dir, filename)
      @driver.find_element(:id, 'yaml_config').send_key(file)
      expect(@driver.find_element(:id, 'yaml_config').attribute('value')).to eql('error import.yml')
      @driver.find_element(:id, 'import_widgets_dialog').find_element(:name, 'commit').click; sleep 10
      expect(@driver.find_element(:class, 'alert-notice').displayed?).to be_truthy
      expect(@driver.find_element(:class, 'alert-notice').text).to include("Import finished. Imported 1 widgets and 0 series. Errors -> Series test-import: Database name can't be blank")
      # delete widget
      @driver.execute_script('window.confirm = function() {return true}')
      @driver.find_element(:css, '[id$=-test-import]').find_element(:link_text, 'Delete').click
    end

    it 'import txt file' do
      @driver.find_element(:link_text, 'Import').click
      expect(@driver.find_element(:id, 'import_widgets_dialog').displayed?).to be_truthy
      filename = 'wrong.txt'
      file = File.join(@upload_dir, filename)
      @driver.find_element(:id, 'yaml_config').send_key(file)
      expect(@driver.find_element(:id, 'yaml_config').attribute('value')).to eql('')

      @driver.find_element(:id, 'import_widgets_dialog').find_element(:name, 'commit').click
      @driver.find_element(:id, 'import_widgets_dialog').find_element(:class, 'close').click
    end
  end
end
