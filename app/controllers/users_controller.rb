class UsersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  def new 
    @user = User.new  
  end  
    
  def create  
    params[:user][:username] = (params[:user][:username]).downcase
    params[:user][:Name] = (params[:user][:Name]).upcase
    params[:user][:isAdmin] = false
    @user = User.new(params[:user])  
    if @user.save 
      redirect_to issues_path, :notice => "User created successfully"  
    else 
      flash.now[:danger] = @user.errors.full_messages.first
      render "new"  
    end
  end

  def edit
    @user = User.find_by_objectId(params[:id])
  end

  def update
    @user = User.find_by_objectId(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "User updated successfully"
      redirect_to edit_user_path  
    else
      flash.now[:danger] = @user.errors.full_messages.first
      redirect_to edit_user_path
    end  
  end

  def manage
    @projects = Project.where(Archived: false).sort_by{|project| project.ProjectName }
    if request.post?
      @user = User.find(params[:user][:name])
      if params[:projects] && params[:projects].any?
        params[:projects].each do |pid|
          UsersProjects.create(UserId: params[:user][:name], ProjectId: pid)
        end
      end
    else
      @user = current_user
    end
    @assigned_projects = @user.project_ids
  end

  def assign_projects
    @user = User.find(params[:user_id]) rescue nil if params[:user_id].present?
    respond_to do |format|
      if @user
        @projects = Project.where(Archived: false).sort_by{|project| project.ProjectName }
        @assigned_projects = @user.project_ids
        format.js { render :assign_projects }
      else
        flash.now[:error] = "Can not find user with ID #{params[:user_id]}"
        format.js { render '/shared/ajax_error' }
      end
    end
  end

end
