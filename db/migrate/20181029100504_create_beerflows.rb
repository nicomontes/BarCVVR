class CreateBeerflows < ActiveRecord::Migration[5.0]
  def change
    create_table :beerflows do |t|
      t.decimal :quantity
      t.references :drink, foreign_key: true

      t.timestamps
    end
  end
end
