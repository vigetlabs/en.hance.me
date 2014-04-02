module Jobs
  class ImageGeneration
    @queue = :image_generation

    def self.perform(resource_id, resource_class)
      new(resource_id, resource_class).generate_image
    end

    def initialize(resource_id, resource_class)
      @resource_id = resource_id
      @resource_class = resource_class.constantize
    end

    def generate_image
      resource.generate_image
    end

    private

    attr_reader :resource_class, :resource_id

    def resource
      @resource ||= resource_class.find(resource_id)
    end
  end
end
