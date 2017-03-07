require 's3_handler'
class WelcomeController < ApplicationController
  def index
    s3 = S3Handler.new("bubhack")
    name_start = 'entry'
    name_end = '.gif'
    options = { encoding: Encoding::UTF_8 }

    gmail = Gmail.connect('jonathan@bookbub.com', ENV['GMAIL_PASSWORD'])
    images = gmail.inbox.emails(:to => "coolcats@bookbub.com").map do |email|
      attachment = email.message.attachments.first
      from = email.from.first.name
      if attachment && /\.gif/ =~ attachment.filename
        file = Tempfile.new([name_start, name_end], '/tmp', options)
        file.write(attachment.body.to_s.force_encoding("UTF-8").encode("UTF-8"))
        file.close
        key = file.path.split('/').third
        upload = s3.put file, key
      end
    end
  end

end

