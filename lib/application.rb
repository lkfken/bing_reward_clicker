require 'logger'

class Application
  def self.logger
      log_dev = is_production? ? (LOGGER_DIR + 'run.log') : (LOGGER_DIR + "#{stage.to_s}.log")
      lgr = Logger.new(log_dev) #Selenium::WebDriver.logger
      lgr.level = is_production? ? :info : :debug
      lgr
  end

  def self.is_production?
    stage == :production
  end

  def self.stage
    ENV['stage'].downcase.to_sym
  end

  def self.user
    name = ENV['bing_username']
    raise "please config your .env file" if name == '<username>'
    name
  end

  def self.password
    ENV['bing_password']
  end

  def self.mobile_total
    str = ENV['mobile_total']
    raise "please config your .env file" if str.nil?
    str.to_i
  end

  def self.pc_total
    str = ENV['pc_total'].to_i
    raise "please config your .env file" if str.nil?
    str.to_i
  end

  def self.browser(screen_capture_dir:, mode:, logger:)
    Browser.new(screen_capture_dir: screen_capture_dir, mode: mode, logger: logger)
  end

  def self.show_points(browser:, logger: Logger.new($stdout))
    if !browser.login?
      login = Bing::Login.new(browser: browser, username: Application.user, password: Application.password)
      login.run
    end
    points = Bing::Points.new(browser: browser)
    logger.info "Available: #{points.available_points}"
    logger.info points.points_detail.inspect
  end

  def self.bing_search(browser:, logger:, keywords: [])
    total = browser.pc_mode? ? pc_total : mobile_total

    if Application.is_production? && !browser.login?
      login = Bing::Login.new(browser: browser, username: Application.user, password: Application.password)
      login.run
    end

    topics = Bing::Topics.new(total: total, keywords: keywords)
    logger.debug "total topics: #{topics.size}"

    search = Bing::Search.new
    topics.each do |topic|
      search.topic = topic
      browser.jump_to search.url, pause: 0
      sleep(rand(1..5)) if Application.is_production?
    end
  end
end