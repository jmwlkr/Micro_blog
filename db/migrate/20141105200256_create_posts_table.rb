class CreatePostsTable < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.integer :user_id
      t.datetime  :timestamp
    end
  end
end
