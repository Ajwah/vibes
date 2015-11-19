class BackgroundUrlManager
  @queue = :url_converter

  def self.expand_url(tiny_url)
    %x( curl -s -o /dev/null --head -w "%{url_effective}\n" -L "#{tiny_url}" ).sub("\n",'')
  end

  def self.process_response(tweet, res)
      if res && res['status'] == "OK"
        tweet.update(:sentiment => res['docSentiment']['type'])
        return true
      else
        return false
      end
  end

  def self.perform
    alchemy = AlchemyAPI.new
    Tweet.all.each do |tweet|
      tweet.text
           .split(/\s+/)
           .find_all { |u| u =~ /^https?:/ }
           .each do |tiny_url|
              actual_url = expand_url(tiny_url)
              term = URI.decode(tweet.url.split(' posted:')[0]).strip
              res = alchemy.sentiment_targeted('url', actual_url, term)
              unless process_response(tweet, res)
                if tweet["statusInfo"] == "cannot-locate-keyphrase"
                  res = alchemy.sentiment('url', actual_url)
                  res = process_response(tweet, res)
                end
              end
              DebugHelper.output_data("#{tweet.text}\n-----------#{term}   |
                \nConverted: #{tiny_url}    ==>   #{actual_url}
                \nChanged: #{tweet.old_sentiment}  ==> #{tweet.sentiment}
              ")
            end
    end
  end

end