import Ember from 'ember';

export default Ember.Controller.extend({

  // injected
  stops: null,

  // internal
  position: null,
  geolocation: Ember.inject.service(),
  geolocalising: false,
  geoAutocompleteDisplayForm: false,
  displayForm: false,

  geolocalised: Ember.computed('position', function(){
    return this.get('position')
  }),

  geoAutocompleteDisplayForm: Ember.computed('displayForm', 'geolocFailed', function(){
    return !!(this.get('displayForm') || this.get('geolocFailed'))
  }),

  geolocalisingOrStopsFetching: Ember.computed('geolocalising', 'stopsFetching', function(){
    return this.get('geolocalising') || this.get('stopsFetching')
  }),

  init: function() {
    this._super()

    this.set('geolocalising', true)

    let options = {
      geoOptions: {
        enableHighAccuracy: false,
        timeout: 5000,
        maximumAge: 0
      }
    }

    this.get('geolocation').getLocation(options).then((position) => {
      let lat = position.coords.latitude
      let lng = position.coords.longitude
      this.set('geolocalising', false)
      this.set('position', position)
      this.send('loadStopsFromPosition', lat, lng)
    }, (reason) => {
      this.set('geolocalising', false)
      this.set('geolocFailed', true)
      let propName = `geolocFailedReason${reason.code}`
      this.set(propName, true)
    })
  },

  fetchNextArrivals: Ember.observer('stops', function(){
    let stops = this.get('stops')
    if (stops.get('length') > 0) {
      this.set('linesFetching', true)
      let stop_ids = this.stops.mapBy('id')
      this.get('store').query('line', {stop_ids: stop_ids}).then((lines) => {
        this.set('linesFetching', false)
      })
    }
  }),

  fetchWalkingTime: Ember.observer('stops', function(){
    let stops = this.get('stops')
    if (stops.get('length') > 0) {
      let origin_latitude  = this.get('position').coords.latitude
      let origin_longitude = this.get('position').coords.longitude
      let origin = new google.maps.LatLng(origin_latitude, origin_longitude)
      let destinations = []

      stops.forEach((stop) => {
        let pos = new google.maps.LatLng(stop.get('lat'), stop.get('lng'))
        destinations.push(pos)
      })

      let service = new google.maps.DistanceMatrixService()
      service.getDistanceMatrix({
        origins: [origin],
        destinations: destinations,
        travelMode: google.maps.TravelMode.WALKING,
        unitSystem: google.maps.UnitSystem.METRIC
      }, function (response, status) {
        if (status == 'OK') {
          let rows = response.rows
          if (rows.length > 0) {
            $.each(rows[0].elements, (idx, element) => {
              let stop = stops.objectAt(idx)
              let destination_latitude = stop.get('lat')
              let destination_longitude = stop.get('lng')
              let walking_time = element.status
              if (element.duration) {
                walking_time = element.duration.text.replace('minutes', 'min')
              }
              let navigation_url = `http://maps.google.com/?saddr=${origin_latitude},${origin_longitude}&daddr=${destination_latitude},${destination_longitude}&dirflg=w`
              stop.set('walking_time', walking_time)
              stop.set('navigation_url', navigation_url)
            })
          }
        }
      })
    }
  }),

  reverseGeocode: Ember.observer('position', function(){
    let geocoder  = new google.maps.Geocoder()
    let latitude  = this.get('position').coords.latitude
    let longitude = this.get('position').coords.longitude
    let latlng = new google.maps.LatLng(latitude, longitude)
    geocoder.geocode({'latLng': latlng}, (results, status) => {
      if (status == google.maps.GeocoderStatus.OK) {
        if (results[0]) {
          this.set('reverseGeocodedPosition', results[0].formatted_address)
        }
      }
    })
  }),

  actions: {
    doDisplayForm: function() {
      let b = this.get('displayForm')
      if (b) {
        this.set('displayForm', false)
      } else {
        this.set('displayForm', true)
      }
      return false
    },

    submitPosition: function(lat, lng) {
      let position = {
        coords: {
          latitude: lat,
          longitude: lng
        }
      }
      this.set('position', position)
      this.send('updateStops', lat, lng)
    },

    updateStops: function(lat, lng) {
      this.send('loadStopsFromPosition', lat, lng)
    }
  }
});
