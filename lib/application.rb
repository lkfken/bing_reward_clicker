class Application
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

  def self.run(mode: )
    browser = Browser.new(mode: mode, logger: logger)
    total = browser.pc_mode? ? 0 : 1

    browser.start_headless if defined? Headless

    if Application.is_production?
      login = Bing::Login.new(browser: browser, username: Application.user, password: Application.password, logger: logger)
      login.run
      points = Bing::Points.new(browser: browser)
      logger.info "Available: #{points.available_points}"
      logger.info points.points_detail.inspect
    end

    topics = Bing::Topics.new(total: total, keywords: YAML::load_file('./config/topics.yml'))
    search = Bing::Search.new
    topics.each do |topic|
      search.topic = topic
      browser.jump_to search.url
      sleep(rand(1..5)) if Application.is_production?
    end

    if login && points
      logger.info "Available: #{points.available_points}"
      logger.info points.points_detail.inspect
    end

    browser.quit
  end
end