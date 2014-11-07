class AddTextColumnToPostsTable < ActiveRecord::Migration
  def change
    add_column :posts, :text, :string
  end
end
