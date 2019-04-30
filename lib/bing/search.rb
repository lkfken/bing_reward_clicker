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
      URI(Search::URI + '/news' + "?q=" + ::URI.escape(topic) + '&qft=interval%3d"8"')
    end

  end
end