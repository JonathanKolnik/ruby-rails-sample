desc "Syncs from gmail"

task :pull_from_gmail => :environment do
  s3 = S3Handler.new("bubhack")
  name_start = 'entry'
  name_end = '.gif'
  options = { encoding: Encoding::UTF_8 }

  gmail = Gmail.connect(ENV['GMAIL_EMAIL'], ENV['GMAIL_PASSWORD'])
  images = {}
  gmail.inbox.emails(:to => "coolcats@bookbub.com").reverse.map do |email|
    attachment = email.message.attachments.first
    if attachment && /\.gif/ =~ attachment.filename
      unless images[attachment.filename]
        images[attachment.filename] = attachment
        from = email.from.first.name
        next if s3.get(path(from, attachment))
        upload = s3.bucket.files.create(
          key: path(from, attachment) ,
          body: attachment.body.to_s.force_encoding("UTF-8").encode("UTF-8"),
          multipart_chunk_size: 5242880,
          public: true
        )
        Entry.create(name: from, image_url: upload.public_url)
      end
    end
    email.archive!
  end

  unless Time.current.wday == 5
    SlackNotifier.prepare
  end
end

def path(from, attachment)
  [attachment.filename, from].join('-')
end
