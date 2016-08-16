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
      ["OPEN","OPEN"],
      ["CLOSED","CLOSED"],
      ["RESOLVED","RESOLVED"]
    ]
  end

  def servity
    [["LOW","LOW"],["MEDIUM","MEDIUM"],["HIGH","HIGH"]]
  end

  def date_issue_resolved(date_resolved)
    return nil if date_resolved.blank?
    date_resolved = date_resolved.to_date.strftime("%m/%d/%Y") rescue date_resolved if date_resolved.respond_to?(:to_date)
    date_resolved
  end

end
