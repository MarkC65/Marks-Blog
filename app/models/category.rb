class Category < ApplicationRecord
  has_many :article_categories
  has_many :articles, through: :article_categories
  validates :name, presence: true, length: { in: 3..35}, uniqueness: { case_sensitive: false }
  before_save { 
    self.name = self.name.strip.split.map(&:capitalize).join(' ')
  }
end