Monprochainbus.Stop = DS.Model.extend
  lat: DS.attr()
  lng: DS.attr()
  name: DS.attr()
  code: DS.attr()
  walking_time: DS.attr()
  navigation_url: DS.attr()
  lines: DS.hasMany('line')
