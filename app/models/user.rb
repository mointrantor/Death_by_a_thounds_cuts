class User < ParseUser

	alias :email :username

	fields :username, :Name, :password, :email
	validates :username, :Name, :email, presence: true
  validates :password, length: { minimum: 6 }, allow_blank: true
	validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  
	EMAILNOTIFYTEST = ["nitish.verma@trantorinc.com","kapil.handa@trantorinc.com"]
	EMAILNOTIFYMAIN = ["rajat.julka@trantorinc.com","pradeep@trantorinc.com"]

  def self.active
    User.all.sort_by{|user| user.Name }
  end

  def projects
    UsersProjects.where(UserId: self.objectId)
  end

  def project_ids
    UsersProjects.where(UserId: self.objectId).collect {|up| up.ProjectId }
  end

  def project_names
    pnames = []
    project_ids.each do |pid|
      project = Project.find_by_objectId(pid)
      pnames << project.ProjectName if project
    end
    pnames
  end

  def short_name
    user = self.Name.present? ? self.Name.split(' ').first : ''
    user.capitalize
  end

end