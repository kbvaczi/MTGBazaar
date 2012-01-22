class CreateMtgBlocks < ActiveRecord::Migration

    def up
      create_table :mtg_blocks do |t|
        t.string   :name           , :default => ""          , :null => false 
        t.string   :code           , :default => ""          , :null => false 

        t.timestamps
      end

      # any indexes go here
      add_index :mtg_blocks, :name,               :unique => true
      add_index :mtg_blocks, :code,               :unique => true

    end

    def down
      drop_table :mtg_blocks
    end

  end
