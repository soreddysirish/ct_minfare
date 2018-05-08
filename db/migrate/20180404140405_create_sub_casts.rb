class CreateSubCasts < ActiveRecord::Migration[5.1]
  def change
    create_table :sub_casts do |t|
      t.string :community
      t.text :response

      t.timestamps
    end
  end
end
