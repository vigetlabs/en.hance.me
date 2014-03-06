class Image < ActiveRecord::Base
  attr_accessor :url

  mount_uploader :source, SourceImageUploader
  mount_uploader :montage, ImageUploader

  def url=(url)
    self.source = open(url) if url.present?
  end
end
