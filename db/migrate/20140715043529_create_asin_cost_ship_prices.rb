class CreateAsinCostShipPrices < ActiveRecord::Migration
  def change
    create_table :asin_cost_ship_prices do |t|

      t.timestamps
    end
  end
end
