class Issues < ParseResource::Base
	 
  fields :Project, :Description, :mitigationPlan, :dateIdentified, :dateResolved, :Status, :Severity, :title, :isManagementIssue, :IssueType, :isClientIssue, :ProjectOwner, :AccountManager, :resolution

  validates :Description, :Severity, presence: true

  def self.import(file, current_userName)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      #create_issue(row, current_userName) if !row["title"].blank? && find_by_title(row["title"]).blank?
      if row["Project"].present? && row["Description"].present? && find_by_Description(row["Description"]).blank?
        create_issue(row, current_userName)
      end
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".xlsx" then Roo::Excelx.new(file.path, packed: nil, file_warning: :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def self.create_issue(row, current_userName)
    row = row.select {|k,v| ["Project","title", "Description", 'dateIdentified', 'dateResolved', 'Status', 'Severity', "assignedTo", "isManagementIssue", "isClientIssue", "isClosed", 'closedBy', 'createdBy', 'IssueType', 'AccountManager', "ProjectOwner", "mitigationPlan"].include?(k) }
    
    row["Project"] = row["Project"].strip.upcase
    row["Status"] = row["Status"].strip.upcase
    row["Severity"] = row["Severity"].strip.upcase
    
    if row["isClosed"].present?
      row["isClosed"] = (row["isClosed"] == "true" || row["isClosed"] == 1 ? true : false)
    end
    
    if row["isManagementIssue"].present?
      row["isManagementIssue"] = (row["isManagementIssue"] == "true" || row["isManagementIssue"] == 1 ? true : false)
    end

    if row["isClientIssue"].present?
      row["isClientIssue"] = (row["isClientIssue"] == "true" || row["isClientIssue"] == 1 ? true : false)
    end

    row["isDeleted"] = false

    row["assignedTo"] = 'RAJAT JULKA' if row["isManagementIssue"] == true
    row["assignedTo"] = row["assignedTo"].blank? ? 'RAJAT JULKA' : row["assignedTo"].strip.upcase!

    row["createdBy"] = current_userName

    # Create the record for the issue.
    issue = Issues.new(row) 
    raise 'Headers/values are not in proper format' and return unless issue.save
  end

end