# This is to refine the sentiment analysis of Watson by following the URL
# provided in tweets and parsing them through alchemyapi.
class BackgroundUrlManager
  @queue = :url_converter_alchemy_analysis
  JOBCOMPLETEDFILE = 'completed_alchemy_jobs.log'


  def self.expand_url(tiny_url)
    %x( curl -s -o /dev/null --head -w "%{url_effective}\n" -L "#{tiny_url}" ).sub("\n",'')
  end

  def self.process_response(tweet, res)
      DebugHelper.output_data("#{res}")
      if res && res['status'] == "OK" && tweet.sentiment != res['docSentiment']['type']
        tweet.update(:sentiment => res['docSentiment']['type'])
        tweet.save
        return true
      else
        return false
      end
  end

  def self.perform
    alchemy = AlchemyAPI.new
    lines = IO.readlines(JOBCOMPLETEDFILE) rescue nil
    from = lines && lines.last.to_i || 0
    Tweet.find_each do |tweet|
      tweet.text
           .split(/\s+/)
           .find_all { |u| u =~ /^https?:/ }
           .each do |tiny_url|
              actual_url = expand_url(tiny_url)
              term = URI.decode(tweet.url.split(' posted:')[0].split('q=')[1]).strip
              res = alchemy.sentiment_targeted('url', actual_url, term) rescue nil
              DebugHelper.output_data("keyphrase #{term}")
              unless process_response(tweet, res)
                if tweet["statusInfo"] == "cannot-locate-keyphrase"
                  res = alchemy.sentiment('url', actual_url)
                  if res
                    DebugHelper.output_data("#{tweet.text}\n-----------#{term}   |
                      \nConverted: #{tiny_url}    ==>   #{actual_url}
                      \nChanged: #{tweet.old_sentiment}  ==> #{tweet.sentiment}
                    ")
                  else
                    DebugHelper.output_data("#{tweet.text}\n-----------#{term}   |
                      \nConverted: #{tiny_url}    ==>   #{actual_url}
                      \nNo change in url: ***** #{tweet.old_sentiment}  ==> #{tweet.sentiment}
                    ")
                  end
                end
              end
            end
    end
  end

end