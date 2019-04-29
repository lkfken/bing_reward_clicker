module Bing
  class Login
    include Bing
    URL = 'https://login.live.com/'

    def initialize(browser:, username:, password:, logger: Logger.new($stdout))
      @browser = browser
      @username = username
      @password = password
      @logger = logger
    end

    def run
      @browser.navigate.to URL
      wait_for(10) {@browser.find_element(:name => 'loginfmt')}
      @browser.find_element(:name => 'loginfmt').send_key(@username)
      @browser.find_element(:name => 'loginfmt').send_key(Selenium::WebDriver::Keys[:return])

      wait_for(10) {@browser.find_element(:name => 'passwd')}
      @browser.find_element(:name => 'passwd').send_key(Selenium::WebDriver::Keys[:return])
      @browser.find_element(:name => 'passwd').clear
      @browser.find_element(:name => 'passwd').send_key(@password)
      @browser.find_element(:name => 'passwd').send_key(Selenium::WebDriver::Keys[:return])

      wait_for(10) {@browser.find_element(:id => 'uhfLogo')}
    end
  end
end