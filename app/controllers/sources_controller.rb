class SourcesController < ApplicationController

  def new
    @source = Source.new
    render :layout => false
  end

  def create
    @source = Source.new(source_params)
    if @source.save
      redirect_to source_url(@source)
    else
      render :new
    end
  end

  def show
    @source  = Source.find(params[:id])
    @montage = Montage.new(:source_id => @source.id)
  end

  private

  def source_params
    params.require(:source).permit(:image, :url)
  end

end
