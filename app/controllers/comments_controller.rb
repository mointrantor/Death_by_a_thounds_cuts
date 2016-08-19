class CommentsController < ApplicationController

  def create
    redirect_to root_path, notice: 'Something messed up with params' if params[:comment].blank?
    params[:comment][:user_id] = current_user.objectId
    params[:comment][:created_at] = Time.now

    respond_to do |format|
      if @comment = Comment.create(params[:comment])
        flash.now[:notice] = 'Comment added successfully.'
        format.js
      else
        flash.now[:error] = 'Can not save comment'
        format.js { render '/shared/ajax_error' }
      end
    end
  end

end
