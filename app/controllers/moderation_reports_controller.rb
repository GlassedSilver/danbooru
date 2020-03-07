class ModerationReportsController < ApplicationController
  respond_to :html, :xml, :json, :js
  before_action :member_only, only: [:new, :create]
  before_action :moderator_only, only: [:index]

  def new
    @moderation_report = ModerationReport.new(moderation_report_params)
    check_privilege(@moderation_report)
    respond_with(@moderation_report)
  end

  def index
    @moderation_reports = ModerationReport.visible(CurrentUser.user).paginated_search(params, count_pages: true)
    @moderation_reports = @moderation_reports.includes(:creator, :model) if request.format.html?

    respond_with(@moderation_reports)
  end

  def show
    redirect_to moderation_reports_path(search: { id: params[:id] })
  end

  def create
    @moderation_report = ModerationReport.new(moderation_report_params.merge(creator: CurrentUser.user))
    check_privilege(@moderation_report)
    @moderation_report.save

    flash.now[:notice] = @moderation_report.valid? ? "Report submitted" : @moderation_report.errors.full_messages.join("; ")
    respond_with(@moderation_report)
  end

  private

  def model_type
    params.fetch(:moderation_report, {}).fetch(:model_type)
  end

  def model_id
    params.fetch(:moderation_report, {}).fetch(:model_id)
  end

  def check_privilege(moderation_report)
    raise User::PrivilegeError unless moderation_report.model.reportable_by?(CurrentUser.user)
  end

  def moderation_report_params
    params.fetch(:moderation_report, {}).permit(%i[model_type model_id reason])
  end
end
