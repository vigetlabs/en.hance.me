class AddImageStatusToMontages < ActiveRecord::Migration
  def change
    add_column :montages, :status, :string, default: 'queued', null: false
    add_column :montages, :error, :text
  end
end
