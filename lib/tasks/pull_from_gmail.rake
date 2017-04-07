desc "Syncs from gmail"

task :pull_and_sync => :environment do
  read_from_gmail

  unless Time.current.wday == 5
    SlackNotifier.prepare
  end
end

task :pull_from_gmail => :environment do
  read_from_gmail
end

task :clear_votes => :environment do
  Vote.destroy_all
end

task :clear_entries => :environment do
  Vote.destroy_all
  Entry.destroy_all
end

def read_from_gmail
  s3 = S3Handler.new("bubhack")
  name_start = 'entry'
  name_end = '.gif'
  options = { encoding: Encoding::UTF_8 }

  gmail = Gmail.connect(ENV['GMAIL_EMAIL'], ENV['GMAIL_PASSWORD'])
  images = {}
  gmail.inbox.emails(:to => "coolcats@bookbub.com").reverse.map do |email|
    if body = email.parts.first.parts.second
      body = body.body.decoded
    else
      body = email.parts.second.body.decoded
    end
    html_regex = /src=\"(.*?)\".*/
    src = html_regex.match(body).try(:captures).try(:first)
    from = email.from.first.name
    date = email.date
    if src
      if !src.include?('.gif')
        content_id = src.split(':').second
        attachment = email.attachments.find{|a| a.content_id == "<#{content_id}>"}

        if attachment && /\.gif/ =~ attachment.filename
          unless images[attachment.filename]
            images[attachment.filename] = attachment
            next if s3.get(path(from, attachment))
            upload = s3.bucket.files.create(
              key: path(from, attachment),
              body: attachment.body.to_s.force_encoding("UTF-8").encode("UTF-8"),
              multipart_chunk_size: 5242880,
              public: true
            )
            Entry.create(name: from, image_url: upload.public_url, created_at: date)
          end
        end
      else
        unless Entry.find_by(name: from, image_url: src).present?
          Entry.create(name: from, image_url: src, created_at: date)
        end
      end
    end
  end
end

def path(from, attachment)
  [attachment.filename, from].join('-')
end
