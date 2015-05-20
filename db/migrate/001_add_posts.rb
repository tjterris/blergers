class AddPosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string   :title
      t.text     :content
      t.datetime :date
      t.string   :format
    end
  end
end
