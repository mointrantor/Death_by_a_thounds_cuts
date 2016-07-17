class Project < ParseResource::Base
	
  fields :ProjectName, :Archived
  validates :ProjectName, presence: true, length: { maximum: 30 }

  def self.archived
    where(Archived: true).collect { |p| p.ProjectName }
  end

  def self.active(user = nil)
    all_active_projects = where(Archived: false).sort_by{|p| p.ProjectName}.collect { |p| p.ProjectName }
    return all_active_projects unless user
    return all_active_projects if user.isAdmin
    assigned_projects_names = user.project_names
    return [] if assigned_projects_names.empty?
    all_active_projects.delete_if{ |project| !assigned_projects_names.include?(project) }
  end

end