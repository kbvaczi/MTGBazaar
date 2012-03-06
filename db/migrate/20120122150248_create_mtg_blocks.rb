class CreateMtg::Blocks < ActiveRecord::Migration

    def up
      create_table :mtg_blocks do |t|
        t.string   :name           , :default => ""          , :null => false 

        t.timestamps
      end

      # any indexes go here
      add_index :mtg_blocks, :name

    end

    def down
      drop_table :mtg_blocks
    end

  end
