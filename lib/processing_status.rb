module ProcessingStatus
  VALID_STATUSES = %w(queued processing success failed)

  def self.included(base)
    base.validates :status, inclusion: { in: VALID_STATUSES }
  end

  def mark_processing
    update_attributes(status: "processing")
  end

  def mark_successful
    update_attributes(status: "success", error: nil)
  end

  def mark_failure(error)
    update_attributes(status: "failed", error: error.to_s)
  end

  def process(cleanup = nil)
    mark_processing
    yield
    mark_successful
  rescue => ex
    mark_failure(ex)
  ensure
    cleanup.try(:call)
  end
end
