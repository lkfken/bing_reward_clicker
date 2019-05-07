require 'forwardable'

class Browser
  extend Forwardable
  def_delegators :@driver, :navigate, :find_element, :find_elements
  class InvalidModeError < StandardError;
  end

  MOBILE_AGENT = 'Mozilla/5.0 (Windows Phone 10.0; Android 6.0.0; WebView/3.0) ' + 'AppleWebKit/537.36 (KHTML, like Gecko) coc_coc_browser/64.118.222 ' + 'Chrome/52.0.2743.116 Mobile Safari/537.36 Edge/15.15063'
  PC_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ' + 'AppleWebKit/537.36 (KHTML, like Gecko) ' + 'Chrome/64.0.3282.140 Safari/537.36 Edge/17.17134'
  VALID_MODES = [:pc, :mobile]

  attr_reader :mode, :logger, :headless_mode, :screen_capture_dir
  attr_accessor :logged_in

  def initialize(mode: :pc, logger: Logger.new($stdout), headless_mode: (defined?(Headless)), screen_capture_dir: './tmp')
    raise(InvalidModeError, "#{mode} is not a valid mode") unless VALID_MODES.include?(mode)

    @mode = mode
    @headless_mode = headless_mode
    @screen_capture_dir = screen_capture_dir
    @logger = logger
    @logged_in = false
    @driver = Selenium::WebDriver.for(:firefox, :desired_capabilities => capabilities, :options => options)
  end

  def jump_to(url, pause: 0)
    @driver.navigate.to url
    sleep(pause)
    logger.debug "navigate to #{url}"
  rescue Selenium::WebDriver::Error::UnexpectedAlertOpenError => ex
    logger.error ex.message
  end

  def wait_for(seconds)
    Selenium::WebDriver::Wait.new(timeout: seconds).until {yield}
  rescue Selenium::WebDriver::Error::TimeoutError => ex
    logger.error ex.message
    screen_print
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

  def login?
    logged_in
  end

  def screen_print(filename: "screen_print_#{Time.now.strftime('%Y%m%d%H%M%S')}.png")
    filename = File.join(screen_capture_dir, filename)
    @driver.save_screenshot(filename)
    logger.error "screen print saved to #{filename}"
    filename
  end

  private

  def profile
    @profile ||= begin
      _profile = Selenium::WebDriver::Firefox::Profile.new
      _profile['general.useragent.override'] = user_agent
      _profile
    end
  end

  def options
    @options ||= begin
      _options = Selenium::WebDriver::Firefox::Options.new
      _options.profile = profile
      if headless_mode
        _options.headless!
        start_headless
      end
      _options
    end
  end

  def capabilities
    @capabilities ||= begin
      _capabilities = Selenium::WebDriver::Remote::Capabilities.firefox(marionette: true)
      _capabilities['firefoxBinary'] = '/usr/bin/geckodriver'
      _capabilities['acceptInsecureCerts'] = true
      _capabilities
    end
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
      logger.info "user-agent is set to PC"
      PC_AGENT
    when mobile_mode?
      logger.info "user-agent is set to MOBILE"
      MOBILE_AGENT
    end
  end
end