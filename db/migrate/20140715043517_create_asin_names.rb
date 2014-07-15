class CreateAsinNames < ActiveRecord::Migration
  def change
    create_table :asin_names do |t|

      t.timestamps
    end
  end
end
