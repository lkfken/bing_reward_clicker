module Bing
  class Topics
    include Enumerable

    def initialize(total:, keywords:)
      @total = total
      @keywords = keywords.uniq
    end

    def sample
      @keywords.sample(@total)
    end

    def size
      sample.size
    end

    def each(*args, &block)
      sample.each do |keyword|
        block.call(keyword)
      end
    end
  end
end