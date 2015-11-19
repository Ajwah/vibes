class BackgroundUrlManager
  JOBCOMPLETEDFILE = 'completed_alchemy_jobs.log'

  @queue = :url_converter_alchemy_analysis

  def self.expand_url(tiny_url)
    %x( curl -s -o /dev/null --head -w "%{url_effective}\n" -L "#{tiny_url}" ).sub("\n",'')
  end

  def self.process_response(tweet, res)
      if res && res['status'] == "OK" && tweet.sentiment != res['docSentiment']['type']
        tweet.update(:sentiment => res['docSentiment']['type'])
        tweet.save
        binding.pry
        return true
      else
        return false
      end
  end

  def self.perform
    alchemy = AlchemyAPI.new
    lines = IO.readlines(JOBCOMPLETEDFILE) rescue nil
    from = lines && lines.last.to_i || 0
    Tweet.first(5000).each do |tweet|
      tweet.text
           .split(/\s+/)
           .find_all { |u| u =~ /^https?:/ }
           .each do |tiny_url|
              actual_url = expand_url(tiny_url)
              term = URI.decode(tweet.url.split(' posted:')[0]).strip
              res = alchemy.sentiment_targeted('url', actual_url, term) rescue nil
              unless process_response(tweet, res)
                if tweet["statusInfo"] == "cannot-locate-keyphrase"
                  res = alchemy.sentiment('url', actual_url)
                  res = process_response(tweet, res) rescue nil
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
                else
                  DebugHelper.output_data("#{tweet.text}\n-----------#{term}   |
                    \nConverted: #{tiny_url}    ==>   #{actual_url}
                    \nChanged: #{tweet.old_sentiment}  ==> #{tweet.sentiment}
                  ")
                end
              end
            end
    end
    File.open(JOBCOMPLETEDFILE, 'a') do |file|
      file.puts "#{Tweet.count}"
    end
  end

end