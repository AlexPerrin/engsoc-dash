class Resume < ApplicationRecord

  # https://www.tutorialspoint.com/ruby-on-rails/rails-file-uploading.htm

  mount_uploader :attachment, AttachmentUploader

  belongs_to :user

  validates :user_id, presence: true
  validates :name, presence: true
end
