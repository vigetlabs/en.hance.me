class Montage < ActiveRecord::Base

  belongs_to :source

  mount_uploader :image, ImageUploader

  scope :latest, -> { order(:created_at => :desc) }

  def generate_image
    image_generator.generate do |file|
      if file
        update_attributes!(:image => File.open(file))
      else
        # handle failure
      end
    end
  end

  private

  def crop_specs
    {
      x:      crop_x,
      y:      crop_y,
      width:  crop_width,
      height: crop_height
    }
  end

  def image_generator
    @image_generator ||= MontageImage::Generator.new(source.image, crop_specs)
  end
end
