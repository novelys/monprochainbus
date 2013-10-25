Monprochainbus.AddressAutocompleteForm = Ember.View.extend
  templateName: "address_autocomplete_form"

  didInsertElement: () ->
    input = $("#search").get(0)
    autocomplete = new google.maps.places.Autocomplete(input)
    google.maps.event.addListener autocomplete, 'place_changed', () =>
      place = autocomplete.getPlace()
      location = place.geometry.location
      position = {
        lat: location.lat()
        lng: location.lng()
      }
      @set("controller.position", position)