class Post < ApplicationRecord
  has_many :comments, index_errors: true
  validates :subject, presence: true

  accepts_nested_attributes_for :comments
end
