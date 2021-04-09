defmodule Jaang.Amazon.S3 do
  alias ExAws.S3

  def create_presigned_url(http_method, file_name, folder_name) do
    config = ExAws.Config.new(:s3)
    bucket = System.fetch_env!("AWS_BUCKET_NAME")
    object_key = folder_name <> "/" <> file_name
    S3.presigned_url(config, http_method, bucket, object_key)
  end
end
