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
        if rows.length >= 1
          duration = rows[0].elements[0].duration.text.replace("minutes", "min")
          url = "http://maps.google.com/?saddr=#{latitude1},#{longitude1}&daddr=#{latitude2},#{longitude2}&dirflg=w"
          node.find(".icon-spinner.tertiary").replaceWith("<span>#{duration} <a href='#{url}' target='_blank'><i class='icon-external-link'></i></a></span>")
    )

  getStopInfos = (latitude, longitude) ->
    $(".waiting.main").removeClass("hide")
    $(".address .default_message").addClass("hide")
    $(".address .text").removeClass("hide").html("#{latitude},#{longitude}")
    geocoder = new google.maps.Geocoder()
    latlng = new google.maps.LatLng(latitude, longitude)
    geocoder.geocode {'latLng': latlng}, (results, status) ->
      if (status == google.maps.GeocoderStatus.OK)
        if (results[1])
          $(".address .text").removeClass("hide").html results[1].formatted_address

    $.ajax
      url: '/stops',
      type: 'GET',
      dataType: 'json',
      data: {lat: latitude, lng: longitude},
      success: (data) ->
        $(".waiting.main").addClass("hide")
        $(".stops_list").removeClass("hide").empty()
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
                  <div class='span6 offset3 text-left'>
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
                old_line_name = null
                $(data2).each () ->
                  mode = this.mode
                  line_name = this.line_name
                  line_mode = this.mode
                  new_node2 = $("
                    <div class='row next_arrival'>
                      <div class='span1 offset3 line_name_block'>
                        <span class='#{mode}-#{line_name} line_name'>#{line_name}</span>
                      </div>
                      <div class='span5 line_directions'>
                      </div>
                    </div>
                  ")
                  $(this.line_directions).each () ->
                    direction_name = this.direction_name
                    scheduled_remaining_times = this.scheduled_remaining_times.join(", ")
                    new_node3 = $("
                      <div class='row-fluid'>
                        <div class='span12'>
                          <span class='line_direction'>
                            <i class='icomoon-#{mode}'></i>
                            <i class='icon-long-arrow-right'></i>
                            #{direction_name}
                          </span>
                        </div>
                        <div class='span12'>
                          <span class='scheduled_remaining_times'><i class='icon-time'></i> #{scheduled_remaining_times}</span>
                        </div>
                      </div>
                    ")
                    $(".line_directions", new_node2).append(new_node3)
                  $(".next_arrivals_list", new_node).append(new_node2)
              complete: (xhr, status) ->
                $(".icon-spinner.secondary", new_node).addClass("hide")
              error: (xhr, status, error) ->
                error_type = xhr.responseJSON.error
                if error_type == "NoNextArrivals"
                  new_node2 = $("
                    <div class='row next_arrival'>
                      <div class='span12'>
                        <em class='error'>Aucun résultat pour cette station...</em>
                      </div>
                    </div>
                  ")
                $(".next_arrivals_list", new_node).append(new_node2)

          i++

  if Modernizr.geolocation
    $(".waiting.main").removeClass("hide")
    $(".address .default_message").removeClass("hide")
    navigator.geolocation.getCurrentPosition(
      (pos) ->
        getStopInfos(pos.coords.latitude, pos.coords.longitude)
      (error) ->
        $(".waiting.main").addClass("hide")
        $(".address .default_message").addClass("hide")
        $(".form").toggleClass("hide")
        true
      {timeout: 5000}
    )
  else
    $(".form").toggleClass("hide")

  $(".do-displayForm").on "click", (e) ->
    e.preventDefault()
    $(".form").toggleClass("hide")

  $(".form form").on "submit", (e) ->
    e.preventDefault()

  input = $("#search").get(0)
  autocomplete = new google.maps.places.Autocomplete(input)
  google.maps.event.addListener autocomplete, 'place_changed', () ->
    place = autocomplete.getPlace()
    location = place.geometry.location
    getStopInfos location.lat(), location.lng()


