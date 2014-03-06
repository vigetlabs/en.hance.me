class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :source, :null => false
      t.string :montage

      t.timestamps
    end
  end
end
