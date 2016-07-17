class ProjectsController < ApplicationController

	before_filter :authenticate_user!

	def index
		@project = Project.new
		@projects = Project.all.sort_by(&:ProjectName)
	end	

	def create
		@error = nil
		@project = Project.new(params[:project])
		params[:project][:ProjectName] = params[:project][:ProjectName].strip.upcase
		params[:project][:Archived] = false
		@error = "Project should be unique, please reload page to get new projects if project is not in list" if Project.find_by_ProjectName(params[:project][:ProjectName])
		if @error.nil?
			if @project.save
				@success = "Project #{params[:project][:ProjectName]} created successfully"
			else
				@error = @project.errors
			end	
		end	
	end

	def destroy
		project = Project.find_by_objectId(params[:id])
		respond_to do |format|
			if project
				if project.destroy
					format.html { render text: "Project deleted successfully", layout: false, valid: true }
				else
					format.html { render text: "Something went wrong", layout: false, valid: false }
				end
			else
				format.html { render text: "Project deleted successfully", layout: false, valid: true }
			end
		end
	end

	def archive
		@project = Project.find_by_objectId(params[:id])
		
		respond_to do |format|
			if @project
				@project.Archived = !@project.Archived
				@project.save
				flash.now[:notice] = 'Project archived successfully!'
				format.js { render :archive }
			else
				flash.now[:error] = 'No project exist of this kind!'
				format.js { render '/shared/ajax_error' }
			end
    end

	end

end
