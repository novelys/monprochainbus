Monprochainbus.Line = DS.Model.extend
  name: DS.attr()
  mode: DS.attr()
  stop: DS.belongsTo('stop')
  line_directions: DS.hasMany('line_direction')
