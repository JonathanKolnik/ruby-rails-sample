class FogStorageHandler
  def initialize(bucket_name)
    @bucket_name = bucket_name
  end

  def put(local_path, key)
    File.open(local_path) do |file|
      bucket.files.create(
        key: key,
        body: file,
        multipart_chunk_size: 5242880,
        public: true
      )
    end
  end

  def get(key, &block)
    bucket.files.get(key, &block)
  end

  def bucket
    @bucket ||= connection.directories.get(@bucket_name)
  end
end
