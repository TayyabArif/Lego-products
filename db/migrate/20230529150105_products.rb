class Products < ActiveRecord::Migration[6.1]
  def change
      create_table :products do |t|
      t.string :name
      t.string :set_num
      t.integer :year
      t.integer :theme_id
      t.integer :num_parts
      t.string :img_url
      t.timestamps
    end
  end
end
