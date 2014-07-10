class CreateCftdExperimentsItemsResults < ActiveRecord::Migration
  def change
    create_table :cftd_experiments_items_results do |t|

      t.timestamps
    end
  end
end
