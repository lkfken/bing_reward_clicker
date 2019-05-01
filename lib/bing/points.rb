module Bing
  class Points
    POINTS_DETAIL_URL = 'https://account.microsoft.com/rewards/pointsbreakdown'
    REWARD_URL = 'https://account.microsoft.com/rewards'

    def initialize(browser:, logger: Logger.new($stdout))
      @browser = browser
      @logger = logger
    end

    def available_points
      begin
        @browser.jump_to REWARD_URL
      rescue Selenium::WebDriver::Error::UnexpectedAlertOpenError => ex
      end
      element = @browser.wait_for(10) {@browser.find_element(:class => 'title-detail')}
      sleep(5) # wait for animation to end
      Integer(element.text.split("\n")[0].delete(','))
    end

    def points_detail
      @browser.jump_to POINTS_DETAIL_URL, pause: 5
      panels = @browser.wait_for(10) {@browser.find_elements(:xpath => "//p[contains(@class, 'pointsDetail c-subheading-3 ng-binding')]")}
      @logger.debug "Score Panels on page: #{panels.size}"
      case panels.size
      when 4
        level_2, edge_bonus, pc_search, mobile_search = panels.map(&:text)
        {level_2: level_2, edge_bonus: edge_bonus, pc_search: pc_search, mobile_search: mobile_search}
      when 3
        edge_bonus, pc_search, mobile_search = panels.map(&:text)
        {edge_bonus: edge_bonus, pc_search: pc_search, mobile_search: mobile_search}
      end
    end
  end
end