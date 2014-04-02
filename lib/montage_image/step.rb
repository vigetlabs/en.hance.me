module MontageImage
  class Step
    def self.new_from_crop(params = {})
      crop         = params.fetch(:crop)
      total_steps  = params.fetch(:total_steps)
      current_step = params.fetch(:current_step)
      image_width  = params.fetch(:image_width)
      image_height = params.fetch(:image_height)

      target_bottom_right_x = crop.fetch(:x) + crop.fetch(:width)
      target_bottom_right_y = crop.fetch(:y) + crop.fetch(:height)

      x = current_step * crop.fetch(:x) / total_steps
      y = current_step * crop.fetch(:y) / total_steps

      bottom_x = image_width - (current_step * (image_width - target_bottom_right_x) / total_steps)
      bottom_y = image_height - (current_step * (image_height - target_bottom_right_y) / total_steps)

      width = bottom_x - x
      height = bottom_y - y

      new(x:      x,
          y:      y,
          width:  width,
          height: height)
    end

    def initialize(params = {})
      @params = params
    end

    def to_s
      "#{width}x#{height}+#{x}+#{y}"
    end

    private

    attr_reader :params

    [:width, :height, :x, :y].each do |param|
      define_method(param) do
        params.fetch(param)
      end
    end
  end
end
