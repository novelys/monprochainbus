$(document).on "ready", () ->
  navigator.geolocation.getCurrentPosition (pos) ->
    $.ajax
      url: '/stops',
      type: 'GET',
      dataType: 'json',
      data: {lat: pos.coords.latitude, lng: pos.coords.longitude},
      success: (data) ->
        $(".icon-spinner.main").addClass("hide")
        $(".stops_list").removeClass("hide")
        i = 0
        $(data).each () ->
          name = this.name
          code = this.code
          new_node = $("<li class='stop'>#{ name } <i class='icon-spinner icon-spin secondary'></i><ul class='unstyled next_arrivals_list'></ul></li>")
          $(".stops_list").append(new_node)
          if i < 5
            $.ajax
              url: "/stops/#{code}/next_arrivals",
              type: 'GET',
              dataType: 'json',
              success: (data2) ->
                $(data2).each () ->
                  destination = this.destination
                  horaire = this.horaire
                  console.log(this)
                  new_node2 = $("<li class='next_arrival'>Destination: #{destination} <br/> à #{horaire}</li>")
                  $(".next_arrivals_list", new_node).append(new_node2)
                $(".icon-spinner.secondary", new_node).addClass("hide")
          i++