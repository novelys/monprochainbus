import DS from 'ember-data';
import moment from 'moment';

export default DS.Model.extend({
  name: DS.attr('string'),
  mode: DS.attr('string'),
  line: DS.belongsTo('line'),
  scheduledTimes: DS.attr(),

  isBus: Ember.computed('mode', function() {
    return this.get("mode") == "bus"
  }),

  isTram: Ember.computed('mode', function() {
    return this.get("mode") == "tram"
  }),

  formattedScheduledTimes: Ember.computed('scheduledTimes', function() {
    let res = "formattedScheduledTimes not defined"
    res = this.get("scheduledTimes").map( function (time) {
      let text = moment(time).fromNow().replace("dans ", "").replace("minutes", "min").replace("minute", "min").replace("heures", "h").replace("heure", "h").replace("une", "1")
      return `<span class='inline-block'>${text}</span>`
    }).join(", ")
    return res
  })

});
