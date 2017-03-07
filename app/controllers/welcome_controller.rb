require 's3_handler'
class WelcomeController < ApplicationController
  def index
    @entries = Entry.where('created_at > ?', Date.current - 7.days)
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
          # next if s3.get(path(from, attachment))
          # file = Tempfile.new([name_start, name_end], "#{Rails.root}/tmp", options)
          # file.write(attachment.body.to_s.force_encoding("UTF-8").encode("UTF-8"))
          # file.close
          upload = s3.bucket.files.create(
            key: path(from, attachment) ,
            body: attachment.body.to_s.force_encoding("UTF-8").encode("UTF-8"),
            multipart_chunk_size: 5242880,
            public: true
          )
          Entry.create(name: from, image_url: upload.public_url)
        end
      end
    end
  end
end

def path(from, attachment)
  [attachment.filename, from].join('-')
end
