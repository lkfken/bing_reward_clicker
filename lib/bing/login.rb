module Bing
  class Login
    URL = 'https://login.live.com/'

    def initialize(browser:, username:, password:)
      @browser = browser
      @username = username
      @password = password
      @logger = browser.logger
    end

    def run
      @browser.jump_to URL, pause: 3
      @browser.wait_for(10) {@browser.find_element(:name => 'loginfmt')}
      @browser.find_element(:name => 'loginfmt').send_key(@username)
      @browser.find_element(:name => 'loginfmt').send_key(Selenium::WebDriver::Keys[:return])

      @browser.wait_for(10) {@browser.find_element(:name => 'passwd')}
      @browser.find_element(:name => 'passwd').send_key(Selenium::WebDriver::Keys[:return])
      @browser.find_element(:name => 'passwd').clear
      sleep(3)
      @browser.find_element(:name => 'passwd').send_key(@password)
      @browser.find_element(:name => 'passwd').send_key(Selenium::WebDriver::Keys[:return])

      @browser.wait_for(10) {@browser.find_element(:id => 'uhfLogo')}
      @browser.logged_in = true
    end
  end
end