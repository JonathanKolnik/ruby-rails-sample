require "byebug"

class SlackNotifier
  def self.announce(options, channel = "gif-of-the-week")
    notifier = Slack::Notifier.new(Rails.configuration.slack_url,
      channel: channel,
      username: "gifoftheweek")

    markup = {
      text: "It's time to vote for Gif of the Week. Voting closes at 3:45pm.",
      attachments: options,
    }
    notifier.post markup
  end

  def self.prepare
    gifs = Entry.where('created_at > ?', Date.current - 6.days)

    message = "It's time to vote for Gif of the Week. Voting closes at 3:45pm."

    if gifs.any?
      options = self.options_json(gifs)
      self.announce(options, "gif-of-the-week")
    end
  end

  def self.options_json(gifs)
    attachments = []
    gifs.each do |gif|
      attachments << {
        fallback: gif[:image_url],
        image_url: gif[:image_url],
        callback_id: gif[:id],
        color: "#3AA3E3",
        attachment_type: "default",
        actions: [
          {
            name: "gif #{gif[:image_url]}",
            text: "Vote",
            type: "button",
            value: "yes",
          }
        ]
      }
    end
    attachments
  end
end
