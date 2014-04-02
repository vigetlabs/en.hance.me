class Montage < ActiveRecord::Base

  belongs_to :source

  mount_uploader :image, ImageUploader

  scope :latest, -> { order(:created_at => :desc) }

  after_create :generate_image

  private

  def generate_image
    images = [uploaded_image_path]

    Dir.mktmpdir do |dir|
      sizes.each_with_index do |group, index|
        path = File.join(dir, "#{index}.jpg")

        image = uploaded_image

        x, y, w, h = group
        Rails.logger.warn("#{w}x#{h}+#{x}+#{y}")
        image.combine_options do |c|
          c.crop "#{w}x#{h}+#{x}+#{y}"
          c.resize "#{source_width}x"
        end
        path = File.join(dir, "#{index}.jpg")

        image.write path
        images << path
      end

      output_file = File.join(dir, 'output.jpg')
      images << output_file

      args = ['-tile 1x', '-geometry +0+0'] + images

      `montage #{args.join(' ')}`

      apply_watermark_to(output_file)
      update_attributes!(:image => File.open(output_file))
    end
  end

  def source_width
    uploaded_image[:width]
  end

  def source_height
    uploaded_image[:height]
  end

  def uploaded_image_path
    source.image.path
  end

  def uploaded_image
    MiniMagick::Image.open(uploaded_image_path)
  end

  def sizes
    target_bottom_right_x = crop_x + crop_width
    target_bottom_right_y = crop_y + crop_height

    # get first box
    first_x = crop_x / 3
    first_y = crop_y / 3

    first_bottom_x = source_width - ((source_width - target_bottom_right_x) / 3)
    first_bottom_y = source_height - ((source_height - target_bottom_right_y) / 3)

    first_width  = first_bottom_x - first_x
    first_height = first_bottom_y - first_y

    first = [first_x, first_y, first_width, first_height]

    # get second box
    second_x = 2 * crop_x / 3
    second_y = 2 * crop_y / 3

    second_bottom_x = source_width - (2 * (source_width - target_bottom_right_x) / 3)
    second_bottom_y = source_height - (2 * (source_height - target_bottom_right_y) / 3)

    second_width  = second_bottom_x - second_x
    second_height = second_bottom_y - second_y

    second = [second_x, second_y, second_width, second_height]

    # third (final) box is given
    third = [crop_x, crop_y, crop_width, crop_height]

    [first, second, third]
  end

  def apply_watermark_to(file)
    Watermarker.new(file).apply_watermark
  end
end
