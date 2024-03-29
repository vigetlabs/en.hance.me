class MontagesController < ApplicationController

  def create
    @montage = source.montages.build(montage_params)

    if @montage.save
      redirect_to @montage
    else
      redirect_to root_url
    end
  end

  def show
    @montage = Montage.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render :json => @montage.to_json }
    end
  end

  private

  def source
    @source ||= Source.find(params[:source_id])
  end

  def montage_params
    params.
      require(:montage).
      permit(:crop_x, :crop_y, :crop_width, :crop_height)
  end
end
