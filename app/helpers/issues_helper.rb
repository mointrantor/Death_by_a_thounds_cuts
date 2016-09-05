module IssuesHelper

  def image_icon arg
    case arg
    when 'HIGH' then 'h_red_icon.png'
    when 'MEDIUM' then 'm_blue.png'
    when 'LOW' then 'l_green_icon.png'
    else 'l_green_icon.png'
    end
  end	

  def status
    [
      ['OPEN','OPEN'],
      ['CLOSED','CLOSED'],
      ['RESOLVED','RESOLVED']
    ]
  end

  def servity
    [['LOW','LOW'],['MEDIUM','MEDIUM'],['HIGH','HIGH']]
  end

  def date_issue_resolved(issue)
    return nil if issue.Status != 'RESOLVED'
    issue.updatedAt.to_date.strftime("%m/%d/%Y")
  end

  def show_page_fields
    [
      ['Project', 'Project'], 
      ['Description', 'Description'], 
      ['Status', 'Status'], 
      ['Severity', 'Severity'], 
      ['Date Reported', 'dateIdentified'], 
      ['Date Resolved', 'dateResolved'],
      ['Resolution', 'resolution']
    ]
  end

end
