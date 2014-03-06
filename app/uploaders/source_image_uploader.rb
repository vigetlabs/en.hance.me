# encoding: utf-8

class SourceImageUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  storage :file

  process :resize_to_fit => [800, 800]

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end


end
