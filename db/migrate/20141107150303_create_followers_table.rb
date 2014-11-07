class CreateFollowersTable < ActiveRecord::Migration
  def change
    create_table :followers do |t|
      t.integer :follower_id
      t.integer :leader_id
    end
  end
end
