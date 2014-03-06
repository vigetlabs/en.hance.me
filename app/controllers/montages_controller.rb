class MontagesController < ApplicationController
  
  def create
    @montage = Montage.new(
      Image.find(params[:image_id]),
      params[:x], params[:y],
      params[:w], params[:h]
    )
    
    @montage.create
    
    render :json => {}
  end
  
end