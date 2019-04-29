require 'delegate'

class Browser < DelegateClass(Selenium::WebDriver::Firefox::Driver)
  class InvalidModeError < StandardError;
  end

  MOBILE_AGENT = 'Mozilla/5.0 (Windows Phone 10.0; Android 6.0.0; WebView/3.0) ' + 'AppleWebKit/537.36 (KHTML, like Gecko) coc_coc_browser/64.118.222 ' + 'Chrome/52.0.2743.116 Mobile Safari/537.36 Edge/15.15063'
  PC_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ' + 'AppleWebKit/537.36 (KHTML, like Gecko) ' + 'Chrome/64.0.3282.140 Safari/537.36 Edge/17.17134'
  VALID_MODES = [:pc, :mobile]

  attr_reader :mode, :logger

  def initialize(mode: :pc, logger: Logger.new($stdout))
    raise(InvalidModeError, "#{mode} is not a valid mode") unless VALID_MODES.include?(mode)
    @mode = mode
    @logger = logger

    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['general.useragent.override'] = user_agent
    options = Selenium::WebDriver::Firefox::Options.new
    options.profile = profile
    options.headless! if defined? Headless

    @driver = Selenium::WebDriver::Firefox::Driver.new(:marionette => true, :options => options)
    super(@driver)
  end

  def jump_to(url)
    navigate.to url
    logger.debug "navigate to #{url}"
  end

  def self.for(*args)
    self.new(*args)
  end

  def wait_for(seconds)
    Selenium::WebDriver::Wait.new(timeout: seconds).until {yield}
  end

  def start_headless
    @headless = Headless.new
    @headless.start
    logger.debug 'Start headless'
    @headless
  end

  def quit
    quit_headless
    super
  end

  def quit_headless
    if @headless
      @headless.destroy
      logger.debug 'Destroy headless'
    end
  end

  def pc_mode?
    mode == :pc
  end

  def mobile_mode?
    mode == :mobile
  end

  private

  def current_agent
    @driver.execute_script("return navigator.userAgent")
  end

  def user_agent
    case
    when pc_mode?
      logger.debug "user-agent is set to PC"
      PC_AGENT
    when mobile_mode?
      logger.debug "user-agent is set to MOBILE"
      MOBILE_AGENT
    end
  end


end