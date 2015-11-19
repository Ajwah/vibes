class AddOldSentimentColumn < ActiveRecord::Migration
  def change
    add_column :tweets, :old_sentiment, :string
    Tweet.update_all("old_sentiment=sentiment")
  end
end
