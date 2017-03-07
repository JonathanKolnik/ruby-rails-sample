class FogStorageHandler
  def initialize(bucket_name)
    @bucket_name = bucket_name
  end

  def put(file, key)
    bucket.files.create(
      key: key,
      body: file,
      multipart_chunk_size: 5242880
    )
  end

  def get(key, &block)
    bucket.files.get(key, &block)
  end

  def bucket
    @bucket ||= connection.directories.get(@bucket_name)
  end
end
