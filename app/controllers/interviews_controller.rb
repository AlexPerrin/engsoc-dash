class InterviewsController < ApplicationController
  load_and_authorize_resource
  before_action :set_interview, only: [:show, :edit, :update, :destroy]

  # GET /job_applications/:job_application_id/interviews/new
  def new
    @job_application = JobApplication.find(params[:job_application_id])
    if @job_application.job_posting.status != "interviewing"
      flash[:danger] = "Job Posting has not been set to begin interviewing, which can only be done after the posting deadline.
                        <br>You can only begin scheduling interviews after the posting is set to begin interviewing."
      redirect_back(fallback_location: manage_interviews_path)
    end
    # Required resources for calendar
    @managing_jobs = Job.includes(:positions).where(positions: { :user_id => current_user.id })
    @managed_orgs = Organization.includes(:jobs).where(jobs: { :role => ["management", "admin"] })
    @managed_jobs = Job.where(:organization_id => @managed_orgs.ids)
    @interviewing_postings = JobPosting.where(:job_id => @managed_jobs.ids, :status => "interviewing").order("deadline").paginate(:page => params[:page], :per_page => 10)
    @applications = JobApplication.where(:job_posting_id => @interviewing_postings.ids, :status =>"interview_scheduled")
    @interviews = Interview.where(:job_application_id => @applications.ids).order(end_time: :asc)
    # end

    if @job_application.interview.present?
      redirect_to manage_interviews_path, :info => "This application already has a scheduled interview"
    else
      @job_posting = JobPosting.find(@job_application.job_posting_id)
      @interview = Interview.new
    end
  end

  # GET /interviews/1/edit
  def edit
  end

  # POST /interviews
  def create
    @interview = Interview.new(interview_params)

    if @interview.save!
      flash[:success] = "Interview Scheduled"
      @job_application = JobApplication.find(@interview.job_application_id)
      @job_application.status = "interview_scheduled"
      @job_application.save
      redirect_to manage_interviews_path
    else
      render :new
    end
  end

  # PATCH/PUT /interviews/1
  def update
    if @interview.update_attributes(interview_params)
      redirect_to manage_interviews_path, success: 'Interview was successfully updated.'
    else
      render :edit
    end
  end

  # Removed destroy action for now... even if interview cancels, applications should be processed as
  # a non-hire, instead of a destroying of an interview object...

  # GET /interviews/manage
  def manage
    @managing_jobs = Job.includes(:positions).where(positions: { :user_id => current_user.id })
    @managed_orgs = Organization.includes(:jobs).where(jobs: { :role => ["management", "admin"] })
    @managed_jobs = Job.where(:organization_id => @managed_orgs.ids)
    @interviewing_postings = JobPosting.where(:job_id => @managed_jobs.ids, :status => "interviewing").order("deadline").paginate(:page => params[:page], :per_page => 10)
    @applications = JobApplication.where(:job_posting_id => @interviewing_postings.ids, :status =>"interview_scheduled")
    @interviews = Interview.where(:job_application_id => @applications.ids).order(end_time: :asc)
  end

  def admin
    @interviews = Interview.all.order("end_time").reverse_order
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_interview
      @interview = Interview.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def interview_params
      params.require(:interview).permit(:job_application_id, :start_time, :end_time)
    end
end
