module MontageImage
  class Generator
    require 'fileutils'

    DEFAULT_STEP_COUNT = 3

    def initialize(image, crop = {})
      @image = image
      @crop = crop
    end

    def generate(options = {})
      step_count = options.fetch(:steps, DEFAULT_STEP_COUNT)
      components = [image.path]

      steps_for_step_count(step_count).each_with_index do |step, index|
        components << new_sub_image(step, index)
      end

      components << output_file_path

      if create_montage(components)
        yield output_file_path
      else
        yield false
      end

      cleanup
    end

    private

    attr_reader :crop, :image

    def create_montage(components)
      montage_args = (['-tile 1x', '-geometry +0+0'] + components).join(' ')
      `montage #{montage_args}`
      $?.success?
    end

    def new_sub_image(step, index)
      File.join(working_directory, "#{index}#{image_extension}").tap do |path|
        Rails.logger.warn(step)

        working_image = magick_image

        working_image.combine_options do |c|
          c.crop step.to_s
          c.resize "#{source_width}x"
        end

        working_image.write path
      end
    end

    def cleanup
      FileUtils.rm_r working_directory
    end

    def output_file_path
      File.join(working_directory, "output#{image_extension}")
    end

    def working_directory
      @working_directory ||= Dir.mktmpdir
    end

    def steps_for_step_count(step_count)
      [].tap do |sizes|
        # Add intermediary steps
        (1..(step_count - 1)).each do |current_step_number|
          sizes << Step.new_from_crop(
            crop:         crop,
            current_step: current_step_number,
            total_steps:  step_count,
            image_width:  source_width,
            image_height: source_height,
          )
        end

        # Add the final step
        sizes << Step.new(x:      crop[:x],
                          y:      crop[:y],
                          width:  crop[:width],
                          height: crop[:height])
      end
    end

    def image_extension
      @iamge_extension ||= File.extname(image.path)
    end

    def source_height
      magick_image[:height]
    end

    def source_width
      magick_image[:width]
    end

    def magick_image
      MiniMagick::Image.open(image.path)
    end

    def apply_watermark_to(file)
      Watermarker.new(file).apply_watermark
    end
  end
end
