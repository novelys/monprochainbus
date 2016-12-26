import Ember from 'ember';

export default Ember.Component.extend({
  templateName: "address_autocomplete_form",

  didInsertElement: function() {
    let input = $("#search").get(0)
    let autocomplete = new google.maps.places.Autocomplete(input)
    google.maps.event.addListener(autocomplete, 'place_changed', () => {
      let place = autocomplete.getPlace()
      let location = place.geometry.location
      this.sendAction('submitPosition', location.lat(), location.lng())
    })
  }
})

