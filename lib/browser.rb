require 'forwardable'

class Browser
  extend Forwardable
  def_delegators :@driver, :navigate, :find_element
  class InvalidModeError < StandardError;
  end

  MOBILE_AGENT = 'Mozilla/5.0 (Windows Phone 10.0; Android 6.0.0; WebView/3.0) ' + 'AppleWebKit/537.36 (KHTML, like Gecko) coc_coc_browser/64.118.222 ' + 'Chrome/52.0.2743.116 Mobile Safari/537.36 Edge/15.15063'
  PC_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ' + 'AppleWebKit/537.36 (KHTML, like Gecko) ' + 'Chrome/64.0.3282.140 Safari/537.36 Edge/17.17134'
  VALID_MODES = [:pc, :mobile]

  attr_reader :mode, :logger, :headless_mode, :screen_capture_dir

  def initialize(mode: :pc, logger: Logger.new($stdout), headless_mode: (defined?(Headless)), screen_capture_dir: './tmp')
    raise(InvalidModeError, "#{mode} is not a valid mode") unless VALID_MODES.include?(mode)
    @mode = mode
    @headless_mode = headless_mode
    @screen_capture_dir = screen_capture_dir
    logger.info "#{mode} mode"
    @logger = logger

    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['general.useragent.override'] = user_agent

    options = Selenium::WebDriver::Firefox::Options.new
    options.profile = profile

    if headless_mode
      options.headless!
      logger.info 'headless mode enabled'
      start_headless
    end

    capabilities = Selenium::WebDriver::Remote::Capabilities.firefox(marionette: true)
    capabilities['firefoxBinary'] = '/usr/bin/geckodriver'
    capabilities['acceptInsecureCerts'] = true

    @driver = Selenium::WebDriver.for(:firefox, :desired_capabilities => capabilities, :options => options)
  end

  def jump_to(url)
    @driver.navigate.to url
    logger.debug "navigate to #{url}"
  rescue Selenium::WebDriver::Error::UnexpectedAlertOpenError => ex
    logger.error ex.message
  end

  def wait_for(seconds)
    Selenium::WebDriver::Wait.new(timeout: seconds).until {yield}
  rescue Selenium::WebDriver::Error::TimeoutError => ex
    logger.error ex.message
    capture_error
    raise ex
  end

  def quit
    quit_headless if headless_mode
    @driver.quit
  rescue Selenium::WebDriver::Error::UnknownError => ex
    logger.error ex.message
  end

  def pc_mode?
    mode == :pc
  end

  def mobile_mode?
    mode == :mobile
  end

  private

  def capture_error
    filename = File.join(screen_capture_dir, "error_#{Time.now.strftime('%Y%m%d%H%M%S')}")
    @driver.screen_print(:png, filename: filename)
    logger.error "screen print saved to #{filename}"
    filename
  end
  def start_headless
    @headless = Headless.new
    @headless.start
    logger.debug 'Start headless'
    @headless
  end

  def quit_headless
      @headless.destroy
      logger.debug 'Destroy headless'
  end

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