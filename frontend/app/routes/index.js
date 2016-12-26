import Ember from 'ember';

export default Ember.Route.extend({

  actions: {
    loadStopsFromPosition: function(lat, lng) {
      this.get('store').query('stop', {lat: lat, lng: lng}).then((stops) => {
        this.controllerFor('index').set('stops', stops)
      })
    }
  }

});
