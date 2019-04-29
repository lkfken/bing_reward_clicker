require 'uri'
module Bing
  class Search
    attr_accessor :topic
    URI = 'https://www.bing.com'

    def initialize(topic: nil)
      @topic = topic
    end

    def url
      raise(MissingTermError, 'no term defined!') unless topic
      URI(Search::URI + '/search' + "?q=" + ::URI.escape(topic))
    end

  end
end