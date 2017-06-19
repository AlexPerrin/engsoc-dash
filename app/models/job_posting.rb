class JobPosting < ApplicationRecord
  include Filterable

  scope :status, -> (status) { where status: status }
  scope :job_department, -> (department) { joins(job: :organization).where(organizations:{ department: Organization.departments[department] }) }
  scope :job_type, -> (job_type) { joins(:job).where(jobs: { :job_type => job_type }) }


  #Relationships
  #a job posting belongs to a job
  belongs_to :job, :foreign_key => :job_id, dependent: :destroy
  #a job posting belongs to a user
  belongs_to :user, :foreign_key => :creator_id

  #delete job applications if the related job posting is deleted
  has_many :job_applications, dependent: :destroy
  #delete job posting questions if the related job posting is deleted
  has_many :job_posting_questions, dependent: :destroy

  #different statuses for a job posting
  enum status: [:waiting_approval, :draft, :open, :interviewing, :closed, :extension_pending]

  #Validations
  #make sure a job_id is present
  validates :job_id, presence: true
  #title must be minimum length of five characters
  validates :title, presence: true, length: { minimum: 5, maximum: 100 }
  #description must be at least fifteen characters
  validates :description, presence: true, length: { minimum: 15, maximum: 4000 }
  validates :deadline, presence: true

  # Remove to manual 'validations' as admins must approve postings, for greater flexibility
  # validate :deadline_cannot_be_in_the_past
  # validate :deadline_cannot_be_within_two_weeks

  private

    def deadline_cannot_be_in_the_past
      errors.add(:deadline, "cannot be in the past") if self.deadline < Date.today
    end

    def deadline_cannot_be_within_two_weeks
      two_weeks_later = Date.today + 2.weeks
      errors.add(:deadline, "cannot be within 2 weeks") if self.deadline < two_weeks_later
    end
end
