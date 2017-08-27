class StaticPagesController < ApplicationController
  def home
    @job_postings = JobPosting.where(status: "open").order(:deadline).limit(3)
    @job_applications = JobApplication.where(user_id: current_user.id, status: ["submitted", "draft"]).order(:updated_at).reverse_order.limit(5)
    @job_interviews = Interview.includes(:job_application).where(:job_applications => { :user_id => current_user.id, :status => "interview_scheduled" }).limit(5)
  end

  def about
  end

  def contact
  end

  def credits
  end

  def settings
  end
end
