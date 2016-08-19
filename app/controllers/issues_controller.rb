require 'csv'

class IssuesController < ApplicationController
	before_filter :authenticate_user!
	before_filter :check_read, only: [:index, :fetch_issue, :create, :destroy]
	before_filter :mark_read, only: [:show, :edit]
	
	def index
    archived = Project.archived.include?(params[:project]) if params[:project].present?

    if archived
      flash[:notice] = "Project #{params[:project]} has been archived!"
      redirect_to '/'
    end

    @issues = if params[:project] && params[:project] != 'ALL'
      issue_query(params[:project])
    else
      issue_query
    end
    @serverty, @closed  = category(@issues)
		#@projects = all_projects @issues # Moin - remove if all well
		#@users = all_users # Moin - remove if all well
	end	


	def fetch_issue
		@issues = params[:project] == "ALL" ?	issue_query : issue_query(params[:project])
		@serverty, @closed  = category(@issues)
		format_create response
	end

	def create
		@issues = []
		params[:issues][:isClosed] = params[:issues][:isClosed] == "true" ? true : false
		params[:issues][:isManagementIssue] = params[:issues][:isManagementIssue] == "true" ? true : false
		params[:issues][:isClientIssue] = params[:issues][:isClientIssue] == "true" ? true : false
		params[:issues][:isDeleted] = false

    assigned_user_id = params[:issues][:assignedTo]
    params[:issues][:AccountManager] = params[:issues][:AccountManager]
		params[:issues][:ProjectOwner] = params[:issues][:ProjectOwner]

    # Set assigned_to with UserId name.
    params[:issues][:assignedTo] = User.find_by_objectId(assigned_user_id).Name unless params[:issues][:assignedTo].blank?

		params[:issues][:assignedTo] = 'RAJAT JULKA' if params[:issues][:assignedTo].blank?
		params[:issues][:createdBy] = current_user.Name
		params[:issues][:Project] = ((params[:issues][:Project]).strip).upcase
		params[:issues][:CommentsArray] = []
		@issue = Issues.new(params[:issues])

		if @issue.save
			# @issues = issue_query params[:issues][:Project]
			send_mail @issue if params[:issues][:Status] == "CLOSED"
			send_notification "create", @issue, assigned_user_id
			# UserNotifier.send_create_notification_mail(@issue).deliver!
			@issues = params[:project] == "ALL" ?	issue_query : issue_query(params[:project]) if params[:project]
			@serverty, @closed  = category(@issues)
		else
			@issues = params[:project] == "ALL" ?	issue_query : issue_query(params[:project]) if params[:project]
			@serverty, @closed  = category(@issues)
		end
		format_create response
	end

	def upload_issues
    if request.post?
      if params[:file].blank?
        flash[:notice] = "Pleae provide file to upload in xlsx format." 
      else
        if get_file_format(params[:file]) == 'xlsx'
          begin
            Issues.import(params[:file], current_user.Name)
            flash[:notice] ="Issues imported successfully" 

          rescue Exception => e
            flash[:error] = "#{e}" 
            redirect_to '/issues' and return
          end
        else
          flash[:error] = "Invalid file format, Please upload .xlsx file."
        end
      end
      redirect_to '/issues'
    end
	end

	def sample_issues_csv
		# headers_for_csv = ["S.No", "Project", "Title", "Description", "MitigationPlan", "DateIdentified", "Status", "Severity", "assignedTo", "Is Management Issue"]
    dir_path = "#{Rails.root}/"
    FileUtils.mkdir_p(dir_path) unless File.directory?(dir_path)
    file_name = 'upload_cuts_sample_format.xlsx'
    file_path = "#{dir_path}/#{file_name}"

    # CSV.open(file_path, "w") do |file|
    #   file << headers_for_csv
    #   file << ["1", "LinkYogi", "My first Cut title", "My first Cut description", "Plan detail", "26-10-2015", "OPEN/IN-PROGRESS/CLOSED/ASSIGNED/ON HOLD/RESOLVED", "LOW/MEDIUM/HIGH", "UserName", "true/false"]
    # end

    send_data File.read(file_path), :filename => 'upload_cuts_sample_format.xlsx', :disposition => 'attachment'

  # spreadsheet = StringIO.new 
  # book.write spreadsheet 
  # send_data spreadsheet.string, :filename => "yourfile.xls", :type =>  "application/vnd.ms-excel"
	end

	def edit
		@object_issues = Issues.find_by_objectId(params[:id])
		if @object_issues.nil?
			flash[:notice] = "Issue not found"
			redirect_to issues_path, :notice => "Cut not found"
		end
	end

	def show
		@object_issues = Issues.find_by_objectId(params[:id])
		redirect_to issues_path, notice: 'Cut not found' if @object_issues.blank?
    @comment = Comment.new
    @comments = Comment.where(issue_id: @object_issues.objectId).order('created_at DESC').all
		@users = all_users
	end

	def update
		@object_issues = Issues.find_by_objectId(params[:id])
		closed_status = (@object_issues.Status == 'CLOSED')
		params[:issues][:isClosed] = params[:issues][:Status] == 'CLOSED' ? true : false
		params[:issues][:closedBy] = params[:issues][:Status] == 'CLOSED' ? current_user.Name : ''

    assigned_user_id = params[:issues][:assignedTo]
    if assigned_user_id.present?
      assigned_user_name = User.find_by_objectId(assigned_user_id).Name
      params[:issues][:assignedTo] = assigned_user_name
      params[:issues][:AccountManager] = assigned_user_name unless params[:issues][:AccountManager].blank?
      params[:issues][:ProjectOwner] = assigned_user_name unless params[:issues][:ProjectOwner].blank?
    else
      params[:issues][:assignedTo] = 'RAJAT JULKA'
    end

		params[:issues][:isManagementIssue] = params[:issues][:isManagementIssue] == '1' ? true : false
		params[:issues][:isClientIssue] = params[:issues][:isClientIssue] == '1' ? true : false

		# comment = [[params[:issues][:CommentsArray],"Update By #{current_user.username} on #{Time.now.strftime("%d-%m-%Y %I:%M:%S")}"]]
		# if (@object_issues.CommentsArray.nil? || @object_issues.CommentsArray.blank? ) && !params[:issues][:CommentsArray].blank?
		# 	params[:issues][:CommentsArray] = comment
		# elsif ( !@object_issues.CommentsArray.nil? || !@object_issues.CommentsArray.blank?) && params[:issues][:CommentsArray].blank?	
		# 	# params[:issues][:CommentsArray] = @object_issues.CommentsArray
		# 	params[:issues].delete :CommentsArray
		# elsif ( !@object_issues.CommentsArray.nil? || !@object_issues.CommentsArray.blank?) && !params[:issues][:CommentsArray].blank?
		# 	params[:issues][:CommentsArray] = @object_issues.CommentsArray + comment	
		# elsif (@object_issues.CommentsArray.nil? || @object_issues.CommentsArray.blank?) && params[:issues][:CommentsArray].blank?
		# 	# params[:issues][:CommentsArray] = []
		# 	params[:issues].delete :CommentsArray
		# end	
		
    params[:issues][:lastUpdatedBy] = current_user.Name
		params[:issues][:Project] = ((params[:issues][:Project]).strip).upcase	
		@issue = @object_issues.update_attributes(params[:issues])
		
		if @issue
			# send_notification "update", @object_issues, assigned_user_id
			mark_unread @object_issues.objectId
			if params[:issues][:Status] == "CLOSED" && !closed_status
				# send_mail @object_issues
			else	
				# UserNotifier.send_update_notification_mail(@object_issues).deliver!
			end
		end

		redirect_to issues_path(project: params[:project])
	end


	def destroy 
		issue = Issues.find_by_objectId(params[:id])
		issue_create = issue.update_attributes(isDeleted: true ,deletedBy: current_user.Name, lastUpdatedBy: current_user.Name) if issue

    #assigned_user_id = User.find_by_Name(issue.assignedTo).objectId
		if issue_create
			# send_notification "delete", issue, assigned_user_id
			mark_unread issue.objectId
			# UserNotifier.send_delete_notification_mail(issue).deliver!
		end	
		@issues = params[:project] == "ALL" ?	issue_query : issue_query(params[:project]) if params[:project]
		@issues = issue_query if @issues.blank?
		@serverty, @closed  = category(@issues)	
		format_create response	
	end	

	def issue_query(project = nil)
		issues = Issues.where(query(project)).all
		unless current_user.isAdmin
			issues = issues + Issues.where(get_created_by_data(project)).all
		end
    archived_projects = Project.archived
    issues = issues.select {|issue| !archived_projects.include?(issue.Project) }
    unless current_user.isAdmin
      assigned_projects = current_user.project_names
      issues = issues.select {|issue| assigned_projects.include?(issue.Project) }
    end
    issues
	end

  def query(project)
    query = { isDeleted: false }
    query.merge!(assignedTo: current_user.Name) unless current_user.isAdmin
    query.merge!(Project: project) if project
    query
  end

	def get_created_by_data(project)
		query = { isDeleted: false }
		#query.merge!(createdBy: current_user.Name) # show all project's issues that is assigned to current user
		query.merge!(Project: project)  if project
		query
	end

	def format_create response
		respond_to do |format|
			format.html { render :partial => "project_list" , :layout => false }
		end
	end	

	def report
		@users = all_users
		@issues_obj = issue_query
		@issues = []
		@projects = @issues_obj.map(&:Project).uniq if @issues_obj
		@projects.collect! { |c| [ c, c ] unless c.nil?}  if @projects
	end	

	def fetch_issue_report
		@issues = setupdata params
		respond_to do |format|
			format.html { render :partial => "project_list_report" , :layout => false }
		end
	end	
	def pdf_report
		@issues = setupdata params
		respond_to do |format|
			format.html
			format.pdf do
				render	:pdf => "sample",
								:header => {:html => { :template => 'issues/header.html.erb'}, :spacing => 5},
								:footer => {:html => { :template => 'issues/footer.html.erb'}}
      end
    end
  end	

  def send_mail object
  	UserNotifier.send_close_notification_mail(object).deliver!
  end	

  def setupdata params
  	if params[:project] == "ALL"
  		@issues = issue_query
  		@issues.select{|issue| ((params[:start_date].to_date)..(params[:end_date].to_date)) === issue.dateIdentified.to_date }
  	else
  		@issues = issue_query params[:project]
  		@issues.select{|issue| ((params[:start_date].to_date)..(params[:end_date].to_date)) === issue.dateIdentified.to_date }
  	end
  end	

  def all_users
  	users =  current_user.isAdmin ? User.all.map(&:Name) : ['RAJAT JULKA']
  	users.collect! { |c| [ c, c ] } if users
  end

  def all_projects issues
  	projects = @issues.map(&:Project).uniq if issues
  	projects.collect! { |c| [ c, c ] }  if projects
  end

  def category issues
  	serverty = status = []
  	if issues 
  		serverty = issues.map(&:Severity)
  		status = issues.map(&:Status)
  	end
  	return 	serverty, status
  end

  def check_read
  	@read_issues = []
  	read_iss = WebRead.find_all_by_user_id(current_user.objectId)
 	@read_issues = read_iss.map(&:issues_id) if !read_iss.blank?
  end	

  def mark_read
  	read_issues = WebRead.where(:user_id =>current_user.objectId ,:issues_id => params[:id] ).first
  	WebRead.create(:user_id => current_user.objectId, :issues_id => params[:id] ) if read_issues.nil?
  end	

  def mark_unread id
	read_issues = WebRead.find_all_by_issues_id id
	read_issues.select!{|s| s.user_id != current_user.objectId}
	WebRead.destroy_all(read_issues) unless read_issues.blank?
  end	

  def send_notification type, object, assigned_user_id
  	data =  if type == "create"
  		{ :alert => "Cut #{object.title} for project #{object.Project} has been created by user #{object.createdBy}" }
  	elsif type == "update"
  		{ :alert => "Cut #{object.title} for project #{object.Project} has been updated by user #{object.lastUpdatedBy}"}
  	elsif type == "delete"
  		{ :alert => "Cut #{object.title} for project #{object.Project} has been delete by user #{object.deletedBy}"}
  	end	
  	
  	push = Parse::Push.new(data)

  	query = Parse::Query.new(Parse::Protocol::CLASS_INSTALLATION).eq('GCMSenderId', assigned_user_id)
  	push.where = query.where
  	push.save
  end

end
