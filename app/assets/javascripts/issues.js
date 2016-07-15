$(document).ready(function(){
	$('.datepicker').datepicker({
		format : 'dd-mm-yyyy'
	});
	var startDate=null;
	var endDate=null;
	var nowTemp = new Date();
	var now = new Date(nowTemp.getFullYear(), nowTemp.getMonth(), nowTemp.getDate(), 0, 0, 0, 0);
	
	$('.startDate').datepicker({
		format : 'dd-mm-yyyy',
		onRender: function(date) {
			return date.valueOf() > now.valueOf() ? 'disabled' : '';
		}
	}).on('changeDate', function(ev){
		startDate=new Date(ev.date.getFullYear(),ev.date.getMonth(),ev.date.getDate(),0,0,0);
		if(endDate!=null && endDate!='undefined'){
			if(endDate < startDate){
				alert("End Date is less than Start Date");
				$('.startDate').val('');
			}
		}
	});
	
	$('.endDate').datepicker({
		format : 'dd-mm-yyyy',
		onRender: function(date) {
			return date.valueOf() > now.valueOf() ? 'disabled' : '';
		}
	}).on('changeDate', function(ev){
		endDate=new Date(ev.date.getFullYear(),ev.date.getMonth(),ev.date.getDate(),0,0,0);
		if(startDate!=null && startDate!='undefined'){
			if(endDate < startDate){
				alert("End Date is less than Start Date");
				$('.endDate').val('');
			}
		}
	});

	$("checkbox").bootstrapSwitch();

	$('#project_list_drop').change(function() {
		var val = $("#project_list_drop option:selected").text();
		window.history.pushState("object or string", "Title",'issues?project='+val);
		$.blockUI({ css: { 
			border: 'none', 
			padding: '15px', 
			backgroundColor: '#000', 
			'-webkit-border-radius': '10px', 
			'-moz-border-radius': '10px', 
			opacity: .5, 
			color: '#fff' 
		} 
	}); 

	$.get('/issues/fetch_issue',{'project': val} , function(data){
			$('.project_list_div').empty();
			$('.project_list_div').html(data)
			$.unblockUI();
			configureIssueTable($('#table-issues'));
		});	
	});

	$('.find_issues').on('click',function(event){
		event.preventDefault();
		var project = $('#project_list_report').val();
		var start_date = $('#dateStartReport').val();
		var end_date = $('#dateEndReport').val();
		if(project.length == 0 || start_date.length == 0 || end_date.length == 0  )
		{
			alert("please enter information")
			return false;
		}else{
			if($(this).attr('data_pdf') == "true")
			{
				$.blockUI({ css: { 
					border: 'none', 
					padding: '15px', 
					backgroundColor: '#000', 
					'-webkit-border-radius': '10px', 
					'-moz-border-radius': '10px', 
					opacity: .5, 
					color: '#fff' 
				}
			});
			// window.location = '/issues/pdf_report.pdf?project='+project+'&start_date='+start_date+'&end_date=' + end_date
			window.open('/issues/pdf_report.pdf?project='+project+'&start_date='+start_date+'&end_date=' + end_date, '_blank');
			// $.get('/issues/pdf_report.pdf',{'project': project , 'start_date': start_date , 'end_date': end_date} , function(data){
   		//  		});
	    $.unblockUI();
			}else{
				$.blockUI({ css: {
					border: 'none',
					padding: '15px',
					backgroundColor: '#000',
					'-webkit-border-radius': '10px',
					'-moz-border-radius': '10px',
					opacity: .5,
					color: '#fff' }
				});
				$.get('/issues/fetch_issue_report',{'project': project , 'start_date': start_date , 'end_date': end_date} , function(data){
					$('.project_list_report_div').empty();
					$('.project_list_report_div').html(data)
					$.unblockUI();
					configureIssueReportTable($('#table-issues-report'));
				});
			}
		}
	});

	var description_field =  $('#new_issue_create_form #description');
	$('#create_issue').on('click',function(){
		var name = $('#issue_user_name').val();
		var isClosed = false
		var closedBy = '' 
		var project =  $('#new_issue_create_form #project').val();
		var description =  description_field.val();
		var mitigationPlan =  $('#new_issue_create_form #mitigationPlan').val();
		var dateIdentified =  $('#new_issue_create_form #dateIdentified').val();
		var dateResolved =  $('#new_issue_create_form #dateResolved').val();
		var status =  $('#new_issue_create_form #status').val();
		var severity =  $('#new_issue_create_form #severity').val();
		var manageable = $('#new_issue_create_form #ismanageable').prop('checked');
		var assignedto = $('#new_issue_create_form #assignedto').val();
		var project_select = $('#project_list_drop').val();
		var cut_title = $('#cut_title').val()
		var issueType =  $('#new_issue_create_form #issueType').val();
		var isClientIssue =  $('#new_issue_create_form #isclientissue').prop('checked');
		var projectOwner =  $('#new_issue_create_form #projectOwner').val();
		var accountManager =  $('#new_issue_create_form #accountManager').val();
		
		// if(cut_title.length == 0)
		// {
		// 	alert("Please Enter cut title")
		// 	return false;
		// }

		if(project.length == 0)
		{
			alert("Please Select a Project")
			return false;
		}

		if(description.length == 0){
			description_field.addClass('error-cuts-creation');
			message = "Please Enter issue description";
			$('#error-message').html(message)
			return false;
		}

		if(manageable == true){
			assignedto = ''
		}

		if(status == "CLOSED"){
			isClosed = true
			closedBy = name
		}

		data_form  = {
			'issues[Project]' : project,
			'issues[Description]' : description,
			'issues[mitigationPlan]' : mitigationPlan,
			'issues[dateIdentified]' : dateIdentified,
			'issues[dateResolved]' : dateResolved,
			'issues[Status]' : status,
			'issues[Severity]' : severity,
			'issues[isClosed]' : isClosed,
			'issues[closedBy]' : closedBy,
			'issues[isManagementIssue]' : manageable,
			'issues[assignedTo]' : assignedto,
			'issues[title]' : cut_title,
			'issues[IssueType]' : issueType,
			'issues[isClientIssue]' : isClientIssue,
			'issues[ProjectOwner]' : projectOwner,
			'issues[AccountManager]' : accountManager,
			'project' : project_select
		}
		
		$('#create_new_issue').modal('hide');
		
		$.blockUI({ css: { 
			border: 'none', 
			padding: '15px', 
			backgroundColor: '#000', 
			'-webkit-border-radius': '10px', 
			'-moz-border-radius': '10px', 
			opacity: .5, 
			color: '#fff' } 
		});

		$.post('/issues', data_form, function(data){
			$('.project_list_div').empty();
			$('.project_list_div').html(data)
			$.unblockUI();
			configureIssueTable($('#table-issues'));
			$("#new_issue_div").toggle();
			$('#new_issue_create_form')[0].reset();
			var fieldAssignedTo = document.getElementById("assignedto");
			if(fieldAssignedTo) fieldAssignedTo.disabled=false;
			var isExist = !!$('#project_list_drop option').filter(function() {
				return $(this).attr('value').toLowerCase() === project.toLowerCase();
			}).length;
			if (!isExist) {
				$('<option>').val(project.toUpperCase()).text(project.toUpperCase()).appendTo($('#project_list_drop'));
			}
		});
	});

	$('.create_new_issue').on('click',function(){
		$("#new_issue_div").collapse('toggle');
		// $("#update_issue_div").hide();
	});	

	$('.create_new_issue').on('click',function(){
	$("#new_issue_div").collapse('toggle');
	// $("#update_issue_div").hide();
    });	

	$('#update_issue').on('click',function(){
		$("#update_issue_div").toggle();
		$("#new_issue_div").hide();
	});	

	$(".project_list_div").delegate(".issue_delete", "click", function(event) {
		event.preventDefault();
		object_id = $(this).attr('data_id')
		$('#id-confirm-delete').attr('data_id',object_id)
		$('#delete_issue').modal('show')
	});	

	$(".project_list_div").delegate(".issue_update", "click", function(event) {
		object_id = $(this).attr('data_id')
		project = $('#project_list_drop').val();
		$(this).attr('href','/issues/'+object_id+'/edit?project='+project )
	});

	$(".project_list_div").delegate("#id-confirm-delete", "click", function(event) {
		event.preventDefault();
		$('#delete_issue').modal('hide')
		project = $('#project_list_drop').val();
		object_id = $(this).attr('data_id')
		$.blockUI({ css: { 
			border: 'none', 
			padding: '15px', 
			backgroundColor: '#000', 
			'-webkit-border-radius': '10px', 
			'-moz-border-radius': '10px', 
			opacity: .5, 
			color: '#fff' 
		} 
	});
		$.ajax({
			url: '/issues/'+object_id+'?project='+project,
			type: 'DELETE',
			success: function(result) {
				$('.project_list_div').empty();
				$('.project_list_div').html(result)
				$.unblockUI();
				configureIssueTable($('#table-issues'));
			}
		});
	});

	$('#new_issue_create_form #status').change(function(){
		var val = $("#new_issue_create_form #status option:selected").text();
		if(val == "CLOSED"){
			$('#dateResolved').val(Date.today().toString("dd-MM-yyyy"))
			$('#issues_dateResolved').val(Date.today().toString("dd-MM-yyyy"))
		}else{
			$('#dateResolved').val('')
		}
	});

	$('.edit_issues #issues_Status').change(function(){
		var val = $(".edit_issues #issues_Status option:selected").text();
		if(val == "CLOSED"){
			$('#issues_dateResolved').val(Date.today().toString("dd-MM-yyyy"))

		}else{
			$('#issues_dateResolved').val('')
		}
	});

	$('#new_issue_create_form #ismanageable').change(function(){
		if($('#new_issue_create_form #ismanageable').prop('checked')){
			document.getElementById("assignedto").disabled=true;
			document.getElementById("assignedto").value = "RAJAT JULKA"
		}else
		{
			document.getElementById("assignedto").disabled=false;
		}
	});	

	$('.edit_issues #issues_isManagementIssue').change(function(){
		if($('.edit_issues #issues_isManagementIssue').prop('checked')){
			document.getElementById("issues_assignedTo").disabled=true;
			document.getElementById("issues_assignedTo").value = "RAJAT JULKA"
		}else
		{
			document.getElementById("issues_assignedTo").disabled=false;
		}
	});

	$(".project_list_div").delegate("#panel-body-active button", "click", function(event) {	
		$('#panel-body-active button').removeClass('active');
		$(this).addClass('active');
	});

	$("#flash_create_message").hide();
	$("#flash_error_message").hide();
	
	$('#create_project_button').on('click', function(){
		if($('#project_ProjectName').val().length > 0){ 	
			$(this).prop('disabled', true).html("please wait");
			$('#new_project').submit();
		}
	})

	$('.title_link').on('click', function(){
		$(this).parents('tr').removeClass('unread_issue').addClass('read_issue');
	});

	//Delete Project
	$("#project_list_create_form").delegate(".delete_project", "click", function(event) {
		event.preventDefault();
		obj = $(this);
		object_id = $(this).attr('data_id');
		$.blockUI({
			css: { 
				border: 'none', 
				padding: '15px', 
				backgroundColor: '#000', 
				'-webkit-border-radius': '10px', 
				'-moz-border-radius': '10px', 
				opacity: .5, 
				color: '#fff' 
			} 
		});
		$.ajax({
			url: '/projects/' + object_id,
			type: 'DELETE',
			success: function(result) {
				$.unblockUI();
				console.info('Destroying project ', object_id);
				if(result == "Project deleted successfully")
				{
					obj.parent().remove();
					$.each($("#new_issue_create_form #project option"), function(){
						if($(this).val() == obj.parent().text().split(' ')[0].trim().toUpperCase()) {
							$(this).remove();
						}
					});
				}	
			}
		});
	});

	$('#create_new_issue').on('hide.bs.modal', function (e) {
		description_field.removeClass('error-cuts-creation');
		$('#error-message').html('');
	})
});
