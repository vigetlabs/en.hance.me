class Source < ActiveRecord::Base
  attr_accessor :url

  mount_uploader :image, SourceImageUploader

  has_many :montages

  def url=(url)
    self.source = open(url) if url.present?
  end
end
