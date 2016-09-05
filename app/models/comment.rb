class Comment < ParseResource::Base

  extend ActiveModel::Callbacks
  define_model_callbacks :create
   
  fields :user_id, :issue_id, :comment, :created_at, :updated_at
  validates :user_id, :issue_id, :comment, presence: true

  after_create :notify_users

  def user
    return nil if self.user_id.blank?
    User.find_by(objectId: self.user_id).Name.titleize rescue nil
  end

  def notify_users
    issue = Issues.find_by objectId: self.issue_id
    project = Project.find_by(ProjectName: issue.Project)
    users_projects = UsersProjects.where(ProjectId: project.objectId)
    users_projects = users_projects.reject {|up| up.UserId == current_user.objectId }
    users = users_projects.collect { |up| up.UserId }
    users.each do |user|
      UserNotifier.issue_comment(self, issue, project, user).deliver
    end
  end
  
end