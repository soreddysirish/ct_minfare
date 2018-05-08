class CreateKsaRoutes < ActiveRecord::Migration[5.1]
  def change
    create_table :ksa_routes do |t|
      t.string :source
      t.string :destination

      t.timestamps
    end
  end
end
