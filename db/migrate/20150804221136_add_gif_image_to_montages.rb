class AddGifImageToMontages < ActiveRecord::Migration
  def change
    add_column :montages, :gif_image, :string
  end
end
