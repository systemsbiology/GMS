class CreateMemberships < ActiveRecord::Migration
  def self.up
    create_table :memberships do |t|
      t.integer :id
      t.integer :pedigree_id
      t.integer :person_id
      t.string :draw_duplicate

      t.timestamps
    end
  end

  def self.down
    drop_table :memberships
  end
end
