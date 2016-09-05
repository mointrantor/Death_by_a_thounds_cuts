module ApplicationHelper
  
  def flash_class(level)
    case level.to_sym
    when :notice then 'alert alert-success'
    when :success then 'alert alert-success'
    when :error then 'alert alert-danger'
    when :alert then 'alert alert-danger'
    end
  end

  def options_for_projects_select(all = nil)
    user = current_user || nil
    projects = Project.active(user)
    projects.unshift('ALL') if all
    projects
  end

  def options_for_users_select
    User.active.map{|user| [user.Name.titleize, user.objectId] }.unshift(['Please Select', ''])
  end

  def format_date(dt)
    return nil if dt.blank?
    dt = dt.to_date  if dt.class == String
    dt.strftime('%m/%d/%Y')
  end
  
end
