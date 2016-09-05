class CommentsController < ApplicationController

  def create
    redirect_to root_path, notice: 'Something messed up with params' if params[:comment].blank?
    params[:comment][:user_id] = current_user.objectId
    params[:comment][:created_at] = Time.now

    respond_to do |format|
      if @comment = Comment.create(params[:comment])
        flash.now[:notice] = 'Comment added successfully.'

        issue = Issues.find_by objectId: @comment.issue_id
        project = Project.find_by(ProjectName: issue.Project)
        users_projects = UsersProjects.where(ProjectId: project.objectId)
        users_projects = users_projects.reject {|up| up.UserId == current_user.objectId }
        users = users_projects.collect { |up| up.UserId }
        users.each do |user|
          UserNotifier.issue_comment(@comment, issue, project, user).deliver
        end

        format.js
      else
        flash.now[:error] = 'Can not save comment'
        format.js { render '/shared/ajax_error' }
      end
    end
  end

end
