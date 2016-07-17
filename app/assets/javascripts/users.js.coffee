$ = jQuery

$ ->
  $('#user_option').on 'change', ->
    userID = $(this).find(":selected").val();
    $.ajax "/users/#{userID}/assign_projects",
      type: 'GET'
      dataType: 'script'
      data: {
        user_id: userID
      }
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("AJAX Error: #{textStatus}")
      success: (data, textStatus, jqXHR) ->
        console.log("OK!")