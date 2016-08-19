class Comment < ParseResource::Base
   
  fields :user_id, :issue_id, :comment, :created_at, :updated_at
  validates :user_id, :issue_id, :comment, presence: true

  def user
    return nil if self.user_id.blank?
    User.find_by(objectId: self.user_id).Name.titleize rescue nil
  end

end