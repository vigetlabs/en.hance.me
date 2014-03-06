class Montage

  attr_reader :target_x, :target_y, :target_width, :target_height

  def initialize(image, target_x, target_y, target_width, target_height)
    @image         = image
    @target_x      = target_x.to_i
    @target_y      = target_y.to_i
    @target_width  = target_width.to_i
    @target_height = target_height.to_i
  end

  def create
    images = [uploaded_image_path]

    Dir.mktmpdir do |dir|
      sizes.each_with_index do |group, index|
        path = File.join(dir, "#{index}.jpg")

        image = uploaded_image

        x, y, w, h = group
        Rails.logger.warn("#{w}x#{h}+#{x}+#{y}")
        image.combine_options do |c|
          c.crop "#{w}x#{h}+#{x}+#{y}"
          c.resize "#{width}x"
        end
        path = File.join(dir, "#{index}.jpg")

        image.write path
        images << path
      end

      output_file = File.join(dir, 'output.jpg')
      images << output_file

      args = ['-tile 1x', '-geometry +0+0'] + images

      `montage #{args.join(' ')}`

      @image.update_attributes!(:montage => File.open(output_file))
    end
  end

  def width
    uploaded_image[:width]
  end

  def height
    uploaded_image[:height]
  end

  def uploaded_image_path
    @image.source.path
  end

  def uploaded_image
    MiniMagick::Image.open(uploaded_image_path)
  end

  def sizes
    target_bottom_right_x = target_x + target_width
    target_bottom_right_y = target_y + target_height

    # get first box
    first_x = target_x / 3
    first_y = target_y / 3

    first_bottom_x = width - ((width - target_bottom_right_x) / 3)
    first_bottom_y = height - ((height - target_bottom_right_y) / 3)

    first_width  = first_bottom_x - first_x
    first_height = first_bottom_y - first_y

    first = [first_x, first_y, first_width, first_height]

    # get second box
    second_x = 2 * target_x / 3
    second_y = 2 * target_y / 3

    second_bottom_x = width - (2 * (width - target_bottom_right_x) / 3)
    second_bottom_y = height - (2 * (height - target_bottom_right_y) / 3)

    second_width  = second_bottom_x - second_x
    second_height = second_bottom_y - second_y

    second = [second_x, second_y, second_width, second_height]

    # third (final) box is given
    third = [target_x, target_y, target_width, target_height]

    [first, second, third]
  end

end
