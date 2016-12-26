import DS from 'ember-data';

export default DS.Model.extend({
  name: DS.attr('string'),
  mode: DS.attr('string'),
  stop: DS.belongsTo('stop'),
  lineDirections: DS.hasMany('line-direction')
});
