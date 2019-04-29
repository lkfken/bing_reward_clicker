module Bing
  class Points
    include Bing
    POINTS_DETAIL_URL = 'https://account.microsoft.com/rewards/pointsbreakdown'
    REWARD_URL = 'https://account.microsoft.com/rewards'

    def initialize(browser:)
      @browser = browser
    end

    def available_points
      begin
        @browser.navigate.to REWARD_URL
      rescue Selenium::WebDriver::Error::UnexpectedAlertOpenError => ex
      end
      sleep(5) # wait for animation to end
      element = wait_for(10) {@browser.find_element(:class => 'title-detail')}
      Integer(element.text.split("\n")[0].delete(','))
    end

    def points_detail
      @browser.navigate.to POINTS_DETAIL_URL
      buckets = wait_for(10) {@browser.find_elements(:xpath => "//p[contains(@class, 'pointsDetail c-subheading-3 ng-binding')]")}
      edge_bonus, pc_search, mobile_search = buckets.map(&:text)
      {edge_bonus: edge_bonus, pc_search: pc_search, mobile_search: mobile_search}
    end
  end
end