$(document).on "ready", () ->
  getStopInfos = (latitude, longitude) ->
    $.ajax
      url: '/stops',
      type: 'GET',
      dataType: 'json',
      data: {lat: latitude, lng: longitude},
      success: (data) ->
        $(".icon-spinner.main").addClass("hide")
        $(".stops_list").removeClass("hide")
        i = 0
        $(data).each () ->
          name = this.name
          code = this.code
          new_node = $("<li class='stop'><span class='stop_name'>#{ name }</span> <i class='icon-spinner icon-spin secondary'></i><ul class='unstyled next_arrivals_list'></ul></li>")
          $(".stops_list").append(new_node)
          if i < 5
            $.ajax
              url: "/stops/#{code}/next_arrivals",
              type: 'GET',
              dataType: 'json',
              success: (data2) ->
                $(data2).each () ->
                  mode = this.mode
                  line_name = this.line_name
                  line_direction = this.line_direction
                  scheduled_remaining_times = this.scheduled_remaining_times.join(", ")
                  new_node2 = $("<li class='next_arrival clearfix'><span class='#{mode}-#{line_name} pull-left'>#{line_name}</span><span class='line_direction pull-left'>#{line_direction}</span><span class='scheduled_remaining_times pull-left'><i class='icon-time'></i> #{scheduled_remaining_times}</span></li>")
                  $(".next_arrivals_list", new_node).append(new_node2)
                $(".icon-spinner.secondary", new_node).addClass("hide")
          i++

  if Modernizr.geolocation
    navigator.geolocation.getCurrentPosition (pos) ->
      getStopInfos(pos.coords.latitude, pos.coords.longitude)