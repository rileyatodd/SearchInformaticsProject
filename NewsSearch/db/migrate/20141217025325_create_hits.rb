class CreateHits < ActiveRecord::Migration
  def change
    create_table :hits do |t|
      t.string :url
      t.float :spamscore
      t.float :tfidf
      t.float :pagerank

      t.timestamps
    end
  end
end
