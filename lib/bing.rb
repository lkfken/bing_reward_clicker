require_relative 'bing/errors'
require_relative 'bing/login'
require_relative 'bing/points'
require_relative 'bing/search'
require_relative 'bing/topics'

module Bing
  def wait_for(seconds)
    Selenium::WebDriver::Wait.new(timeout: seconds).until {yield}
  end
end