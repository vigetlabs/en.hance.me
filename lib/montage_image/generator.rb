module MontageImage
  class Generator
    require 'fileutils'

    DEFAULT_STEP_COUNT = 3

    class GenerationError < StandardError; end

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
        apply_watermark_to(output_file_path)
        create_gif_from_sub_images
        yield output_file_path, output_gif_file_path
      else
        raise GenerationError('Montage image generation failed.')
      end
    ensure
      cleanup
    end

    private

    attr_reader :crop, :image

    def create_montage(components)
      montage_args = (['-tile 1x', '-geometry +0+0'] + components).join(' ')
      `montage #{montage_args}`
      $?.success?
    end

    def create_gif_from_sub_images
      # copy original image
      FileUtils.cp(image.path, File.join(working_directory, "source0#{image_extension}"))
      # copy sub_images
      FileUtils.mv(File.join(working_directory, "0#{image_extension}"), File.join(working_directory, "source1#{image_extension}"))
      FileUtils.mv(File.join(working_directory, "1#{image_extension}"), File.join(working_directory, "source2#{image_extension}"))
      FileUtils.mv(File.join(working_directory, "2#{image_extension}"), File.join(working_directory, "source3#{image_extension}"))

      # first, the slow gif
      MiniMagick::Tool::Convert.new do |convert|
        convert << "-delay" << "100"
        convert << "-loop" << "0"
        convert << "#{File.join(working_directory, 'source*')}"
        convert << File.join(working_directory, "slow.gif")
      end

      # second, a faster gif with a sustain at the end
      MiniMagick::Tool::Convert.new do |convert|
        convert << "-delay" << "50"
        convert << "-loop" << "0"
        convert << "#{File.join(working_directory, 'source*')}"
        convert << "#{File.join(working_directory, "source3#{image_extension}")}"
        convert << "#{File.join(working_directory, "source3#{image_extension}")}"
        convert << "#{File.join(working_directory, "source3#{image_extension}")}"
        convert << "#{File.join(working_directory, "source3#{image_extension}")}"
        convert << File.join(working_directory, "fast.gif")
      end

      # third, combine the two
      MiniMagick::Tool::Convert.new do |convert|
        convert << File.join(working_directory, "slow.gif")
        convert << File.join(working_directory, "fast.gif")
        convert << File.join(working_directory, "result.gif")
      end
    end

    def output_gif_file_path
      File.join(working_directory, "result.gif")
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
