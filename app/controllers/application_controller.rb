class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user, :projects, :users
  before_filter :accessible_projects

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def authenticate_user!
    unless current_user
      flash[:notice] = "Not Authorised to use"
      redirect_to log_in_path
    end
  end

  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def accessible_projects
    @accessible_projects = current_user.projects
  end

  def projects
    raise "calling `projects` method from action contoller"
    @projects = []
    projects = Project.all.map(&:ProjectName)
    @projects = projects.collect! { |c| [ c, c ] }  if projects
  end

  def users
    @users = []
    users = current_user.isAdmin ? User.all.map(&:Name) : ['RAJAT JULKA']
    @users = users.collect! { |c| [c, c] } if users
  end
end
