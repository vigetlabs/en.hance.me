class Image < ActiveRecord::Base
  mount_uploader :source, SourceImageUploader
  mount_uploader :montage, ImageUploader
end
