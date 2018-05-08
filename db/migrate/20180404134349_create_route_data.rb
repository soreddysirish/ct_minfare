class CreateRouteData < ActiveRecord::Migration[5.1]
  def change
    create_table :route_data do |t|
      t.string :relegion
      t.text :community

      t.timestamps
    end
  end
end
