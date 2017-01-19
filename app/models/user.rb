class User < ApplicationRecord
  has_and_belongs_to_many :organizations
  has_many :job_applications, dependent: :destroy
  has_many :job_postings, :foreign_key => :creator_id
  enum role: [:student, :management, :admin, :superadmin]
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
