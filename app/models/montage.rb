class Montage < ActiveRecord::Base
  include ProcessingStatus

  belongs_to :source

  mount_uploader :image, ImageUploader

  scope :latest, -> { order(:created_at => :desc) }

  after_create :enqueue_image_generation

  def generate_image
    process do
      image_generator.generate do |file|
        update_attributes(:image => File.open(file))
      end
    end
  end

  private

  def crop_specs
    {
      :x      => crop_x,
      :y      => crop_y,
      :width  => crop_width,
      :height => crop_height
    }
  end

  def image_generator
    @image_generator ||= MontageImage::Generator.new(source.image, crop_specs)
  end

  def enqueue_image_generation
    Resque.enqueue(Jobs::ImageGeneration, id, self.class.to_s)
  end
end
