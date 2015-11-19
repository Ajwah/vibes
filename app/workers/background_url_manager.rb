class BackgroundUrlManager
  @queue = :url_converter
  def self.expand_url(tiny_url)
    %x( curl -s -o /dev/null --head -w "%{url_effective}\n" -L "#{tiny_url}" )
  end

  def self.perform
    Tweetfirst(30).each do |tweet|
      tweet.text
           .split(/\s+/)
           .find_all { |u| u =~ /^https?:/ }
           .each do |tiny_url|
              actual_url = expand_url(tiny_url)
              DebugHelper.output_data("-----------#{tweet.text}   |\nConverted: #{tiny_url}    ==>   #{actual_url}")

            end
    end
  end

end