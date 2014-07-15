class CreateAsinUrls < ActiveRecord::Migration
  def change
    create_table :asin_urls do |t|

      t.timestamps
    end
  end
end
