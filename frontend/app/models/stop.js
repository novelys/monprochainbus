import DS from 'ember-data';

export default DS.Model.extend({
  lat: DS.attr('number'),
  lng: DS.attr('number'),
  name: DS.attr('string'),
  code: DS.attr('string'),
  walkingTime: DS.attr('string'),
  navigationUrl: DS.attr('string'),
  lines: DS.hasMany('line')
});
