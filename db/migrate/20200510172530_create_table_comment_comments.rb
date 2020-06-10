class CreateTableCommentComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comment_comments do |t|
      t.integer :article_comment_id
      t.timestamps
    end
  end
end
