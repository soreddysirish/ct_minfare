class CreateStoreSaFares < ActiveRecord::Migration[5.1]
  def change
    create_table :store_sa_fares do |t|
      t.string :source
      t.string :destination
      t.date :dep_date
      t.integer :fare
      t.string :currency

      t.timestamps
    end
  end
end
