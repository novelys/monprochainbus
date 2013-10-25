Monprochainbus.IndexController = Ember.Controller.extend

  hasGeoloc: Modernizr.geolocation

  geolocalising: false

  stops: Ember.ArrayProxy.create()

  geolocalised: (() ->
    @get("hasGeoloc") && @get("position")
  ).property("hasGeoloc", "position")

  geoAutocompleteDisplayForm: (() ->
    @get("displayForm") || @get("geolocFailed") || !@get("hasGeoloc")
  ).property("displayForm", "geolocFailed", "hasGeoloc")

  geolocalisingOrStopsFetching: (() ->
    @get("geolocalising") || @get("stopsFetching")
  ).property("geolocalising", "stopsFetching")

  init: ->
    @_super()
    if @get("hasGeoloc")
      @set("geolocalising", true)
      navigator.geolocation.getCurrentPosition(
        (pos) =>
          @set("geolocalising", false)
          @set("position", {
            lat: pos.coords.latitude
            lng: pos.coords.longitude
          })
        (error) =>
          @set("geolocalising", false)
          @set("geolocFailed", true)
        {timeout: 5000}
      )

  fetchStops: (() ->
    @get("store").find("stop", @get("position")).then (stops) =>
      @set("stops", stops)
  ).observes("position")

  fetchNextArrivals: (() ->
    stops = @get("stops")
    stop_ids = @stops.mapBy("id")
    $.getJSON("/lines", {stop_ids: stop_ids}).then( (lines) =>
      $.each lines.lines, (index, line) =>
        stop = stops.findBy("id", line.stop_id)
        line.stop = stop
        line_record = @store.createRecord "line", line
        $.each line.line_directions, (index, line_direction) =>
          line_direction.line = line_record
          @store.createRecord "line_direction", line_direction
    )
  ).observes("stops")

  fetchWalkingTime: (() ->
    origin_latitude  = @get("position.lat")
    origin_longitude = @get("position.lng")
    origin = new google.maps.LatLng(origin_latitude, origin_longitude)
    destinations = []
    stops = @get("stops")
    stops.forEach (stop) =>
      pos = new google.maps.LatLng(stop.get("lat"), stop.get("lng"))
      destinations.push pos

    service = new google.maps.DistanceMatrixService()
    service.getDistanceMatrix(
      origins: [origin]
      destinations: destinations
      travelMode: google.maps.TravelMode.WALKING
      unitSystem: google.maps.UnitSystem.METRIC
    , (response, status) ->
      if status == "OK"
        rows = response.rows
        if rows.length >= 1
          $.each rows[0].elements, (idx, element) =>
            stop = stops.get('content').objectAt(idx)
            destination_latitude = stop.get("lat")
            destination_longitude = stop.get("lng")
            walking_time = element.duration.text.replace("minutes", "min")
            stop.set("walking_time", walking_time)
            stop.set("navigation_url", "http://maps.google.com/?saddr=#{origin_latitude},#{origin_longitude}&daddr=#{destination_latitude},#{destination_longitude}&dirflg=w")
    )
  ).observes("stops")

  reverseGeocode: (() ->
    geocoder = new google.maps.Geocoder()
    latitude  = @get("position.lat")
    longitude = @get("position.lng")
    latlng = new google.maps.LatLng(latitude, longitude)
    geocoder.geocode {'latLng': latlng}, (results, status) =>
      if (status == google.maps.GeocoderStatus.OK)
        if (results[1])
          @set("reverseGeocodedPosition", results[1].formatted_address)
  ).observes("position")

  actions:
    doDisplayForm: () ->
      b = @get("geoAutocompleteDisplayForm")
      if b
        @set("geoAutocompleteDisplayForm", false)
      else
        @set("geoAutocompleteDisplayForm", true)
