class ArticleComment < ApplicationRecord
  belongs_to :article
  has_many :comment_comments
  VALID_COMMENT_REGEX = /\A[\w|[=,.!]]+(\s+[\w|[=,.!]]+)*\z/i
  validates :comment, presence: true, length: { in: 1..1024},  
    format: { with: VALID_COMMENT_REGEX, message: "not a valid comment. Use only letters, numbers, underscore and permitted symbols(=, <comma>, <period>.)" }
end
