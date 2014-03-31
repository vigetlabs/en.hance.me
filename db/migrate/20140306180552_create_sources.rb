class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.string :image, :null => false
      t.timestamps
    end
  end
end
