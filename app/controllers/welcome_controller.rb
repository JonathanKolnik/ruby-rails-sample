require 's3_handler'
class WelcomeController < ApplicationController
  def index
    @entries = Entry.all
  end

  def pull_from_gmail
    s3 = S3Handler.new("bubhack")
    name_start = 'entry'
    name_end = '.gif'
    options = { encoding: Encoding::UTF_8 }

    gmail = Gmail.connect('jonathan@bookbub.com', ENV['GMAIL_PASSWORD'])
    images = {}
    gmail.inbox.emails(:to => "coolcats@bookbub.com").reverse.map do |email|
      attachment = email.message.attachments.first
      if attachment && /\.gif/ =~ attachment.filename
        unless images[attachment.filename]
          images[attachment.filename] = attachment
          from = email.from.first.name
          file = Tempfile.new([name_start, name_end], '/tmp', options)
          file.write(attachment.body.to_s.force_encoding("UTF-8").encode("UTF-8"))
          file.close
          key = file.path.split('/').third
          upload = s3.put file, key
          Entry.create(name: from, image_url: upload.public_url)
        end
      end
    end
  end
end

