class AddScanToMtgListings < ActiveRecord::Migration
  def change
    add_column :mtg_listings, :scan, :string, :default => ""

  end
end
