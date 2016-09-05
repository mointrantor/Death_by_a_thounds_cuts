class UserNotifier < ActionMailer::Base
  
  include ActionView::Helpers::TextHelper

  default from: "DBTC Trantor <dbtctrantor@gmail.com>"

  def issue_comment(comment, issue, project, receiver_id)
    @comment = comment
    @issue = issue
    @project = project
    @receiver = User.find_by(objectId: receiver_id)
    mail(to: @receiver.email, subject: "#{@comment.user} has posted a comment about #{project.ProjectName}")
  end

  def new_cut(issue, project, receiver_id, creator)
    @issue = issue
    @creator = creator
    @project = project
    @receiver = User.find_by(objectId: receiver_id)
    mail(to: @receiver.email, subject: "#{@creator.short_name} has added a cut for #{project.ProjectName}")    
  end

  def send_create_notification_mail object
    setup_mail object, "DBTC: #{object.Project} issue created: "+truncate(object.title, length: 25)
  end

  def send_update_notification_mail object
    setup_mail object, "DBTC: #{object.Project} issue updated: "+truncate(object.title, length: 25)
  end

  def send_delete_notification_mail object
    setup_mail object, "DBTC: #{object.Project} issue deleted: "+truncate(object.title, length: 25)
  end

  def send_close_notification_mail object
    setup_mail object, "DBTC: #{object.Project} issue updated: "+truncate(object.title, length: 25)
  end

  def send_mobile_notification_mail header, body
    @body_data = body
    mail(:to => (User::EMAILNOTIFYMAIN).join(',') , :subject => header )
  end

  def setup_mail object, sub
    @object_data = object
    mail(:to => (User::EMAILNOTIFYMAIN).join(',') , :subject => sub )
  end

end