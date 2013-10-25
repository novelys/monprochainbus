Monprochainbus.LineDirection = DS.Model.extend
  name: DS.attr()
  mode: DS.attr()
  line: DS.belongsTo('line')
  scheduled_times: DS.attr()
  formatted_scheduled_times: (() ->
    @get("scheduled_times").map( (time) ->
      to = moment(time)
      number_of_minutes = Math.abs moment().diff(to, 'minutes')
      if number_of_minutes >= 60
        number_of_hours = Math.floor(number_of_minutes / 60)
        remaining_number_of_minutes = number_of_minutes - (number_of_hours * 60)
        "#{ number_of_hours } h #{ remaining_number_of_minutes } min"
      else if number_of_minutes == 0
        "moins d'1 min"
      else
        "#{ number_of_minutes } min"
    ).map( (text) ->
      "<span class='inline-block'>#{text}</span>"
    ).join(", ")
  ).property("scheduled_times")
