require 'fog_storage_handler'
class S3Handler < FogStorageHandler
  def connection
    @connection ||= Fog::Storage.new(
      provider: 'AWS',
      :aws_access_key_id => ENV['ACCESS_KEY_ID'],
      :aws_secret_access_key => ENV['SECRET_ACCESS_KEY']
    )
  end
end

