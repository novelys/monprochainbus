class NoNextArrivals < StandardError; end

class NextArrival

  def self.fetch(code: nil, time: Time.now, number: 1)
    response = cts_soap_client.call :recherche_prochaines_arrivees_web,
      message: { code_arret: code, heure: time, nb_horaires: number}
    response = response.body[:recherche_prochaines_arrivees_web_response]
    now = Time.now
    res = response[:recherche_prochaines_arrivees_web_result][:liste_arrivee].try(:[], :arrivee)
    raise NoNextArrivals if res.blank?
    res = [res] unless res.is_a? Array
    first_pass = res.inject({}){|memo, obj|
      key = obj[:destination]
      if memo[ key ].present?
        memo[ key ][:schedules].push obj[:horaire]
        memo[ key ][:scheduled_remaining_times] << ApplicationController.helpers.time_ago_in_words((obj[:horaire] - now).seconds.from_now)
      else
        line_name, *line_direction = obj[:destination].split(" ")
        hsh = {
          mode: obj[:mode].downcase,
          line_name: line_name,
          line_direction: line_direction.join(" "),
          schedules: [ obj[:horaire] ],
          scheduled_remaining_times: [ ApplicationController.helpers.time_ago_in_words((obj[:horaire] - now).seconds.from_now) ]
        }
        memo[ key ] = hsh
      end
      memo
    }.values

    second_pass = first_pass.sort{|x,y|
      comp = x[:line_name] <=> y[:line_name]
      comp.zero? ? (x[:line_direction] <=> y[:line_direction]) : comp
    }

    third_pass = second_pass.inject({}){|memo, obj|
      key = obj[:line_name]
      if memo[ key ].blank?
        memo[ key ] = {
          line_name: obj[:line_name],
          mode: obj[:mode],
          line_directions: []
        }
      end

      memo[ key ][ :line_directions ] << {
        direction_name: obj[:line_direction],
        schedules: obj[:schedules],
        scheduled_remaining_times: obj[:scheduled_remaining_times]
      }

      memo
    }.values

    third_pass
  end

private

  def self.cts_soap_client
    @cts_soap_client ||= SoapClient.new
  end
end