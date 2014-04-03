class Watermarker
  require 'fileutils'

  def initialize(file)
    @file = file
  end

  def apply_watermark
    `composite -gravity south #{watermark_file} #{file} #{file}`
  ensure
    cleanup
  end

  private

  attr_reader :file

  def watermark_scheme
    scheme = :dark

    magick_file.combine_options do |c|
      c.crop watermark_area_on_image
    end

    magick_file.write watermark_area_image

    `convert #{watermark_area_image} -resize 1x1 #{watermark_area_pixel_image}`
    `convert #{watermark_area_pixel_image} #{watermark_area_pixel_text}`

    pixel = File.read(watermark_area_pixel_text)

    rgb_matches = pixel.scan(/\(([\d]+),([\d]+),([\d]+)\)/m)

    if rgb_matches.any?
      rgb_values = rgb_matches.first
      rgb_total = rgb_values.map(&:to_i).inject(&:+)
      if rgb_total < (255*3/2)
        scheme = :light
      end
    end

    scheme
  end

  def watermark_file
    Rails.root.join('public', 'watermarks', "#{watermark_scheme}.png")
  end

  def working_directory
    @working_directory ||= Dir.mktmpdir
  end

  def cleanup
    FileUtils.rm_r working_directory
  end

  def watermark_height
    50
  end

  def watermark_width
    800
  end

  def watermark_area_on_image
    "#{watermark_width}x#{watermark_height}+0+#{magick_file[:height] - 50}"
  end

  def watermark_area_image
    File.join(working_directory, "watermark_area_image.jpg")
  end

  def watermark_area_pixel_image
    File.join(working_directory, "watermark_area_pixel_image.jpg")
  end

  def watermark_area_pixel_text
    File.join(working_directory, "watermark_area_pixel_text.txt")
  end

  def magick_file
    @magick_file ||= MiniMagick::Image.open(file)
  end
end
