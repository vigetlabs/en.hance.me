class CreateMontages < ActiveRecord::Migration
  def change
    create_table :montages do |t|
      t.integer :source_id
      t.integer :crop_x
      t.integer :crop_y
      t.integer :crop_width
      t.integer :crop_height
      t.string :image

      t.timestamps
    end
  end
end
