$(document).on "ready", () ->
  getDistanceInfo = (node, latitude1, longitude1, latitude2, longitude2) ->
    origin      = new google.maps.LatLng(latitude1, longitude1);
    destination = new google.maps.LatLng(latitude2, longitude2);

    service = new google.maps.DistanceMatrixService()
    service.getDistanceMatrix(
      origins: [origin]
      destinations: [destination]
      travelMode: google.maps.TravelMode.WALKING
      unitSystem: google.maps.UnitSystem.METRIC
    , (response, status) ->
      if status == "OK"
        rows = response.rows
        # console.log response
        if rows.length >= 1
          duration = rows[0].elements[0].duration.text.replace("minutes", "min")
          url = "http://maps.google.com/?saddr=#{latitude1},#{longitude1}&daddr=#{latitude2},#{longitude2}&dirflg=w"
          node.find(".icon-spinner.tertiary").replaceWith("<span>#{duration} <a href='#{url}' target='_blank'><i class='icon-external-link'></i></a></span>")
    )

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
          latitude2 = this.lat
          longitude2 = this.lng
          new_node = $("
            <div class='row stop'>
              <div class='span12'>
                <div class='row'>
                  <div class='span9 offset3 text-left'>
                    <span class='stop_name'>#{ name }</span>
                    <i class='icon-spinner icon-spin secondary'></i>
                    <span class='distance'>
                      <i class='icomoon-walking'></i>
                      <i class='icon-long-arrow-right'></i>
                      <i class='icon-spinner icon-spin tertiary'></i>
                    </span>
                  </div>
                </div>
                <div class='next_arrivals_list'>
                </div>
              </div>
            </div>
          ")
          $(".stops_list").append(new_node)
          getDistanceInfo(new_node, latitude, longitude, latitude2, longitude2)
          if i < 5
            $.ajax
              url: "/stops/#{code}/next_arrivals",
              type: 'GET',
              dataType: 'json',
              success: (data2) ->
                $(data2).each () ->
                  mode = this.mode
                  console.log mode
                  line_name = this.line_name
                  line_direction = this.line_direction
                  scheduled_remaining_times = this.scheduled_remaining_times.join(", ")
                  new_node2 = $("
                    <div class='row next_arrival'>
                      <div class='span6'>
                        <span class='#{mode}-#{line_name} line_name'>#{line_name}</span>
                        <span class='line_direction'>
                          <i class='icomoon-#{mode}'></i>
                          <i class='icon-long-arrow-right'></i>
                          #{line_direction}
                        </span>
                      </div>
                      <div class='span6'>
                        <span class='scheduled_remaining_times'><i class='icon-time'></i> #{scheduled_remaining_times}</span>
                      </div>
                    </div>
                  ")
                  $(".next_arrivals_list", new_node).append(new_node2)
                $(".icon-spinner.secondary", new_node).addClass("hide")
          i++

  if Modernizr.geolocation
    navigator.geolocation.getCurrentPosition (pos) ->
      getStopInfos(pos.coords.latitude, pos.coords.longitude)