class NoNextArrivals < StandardError; end

class Line
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :name, :mode, :stop, :line_directions

  def stop_id
    stop.slug
  end

  def self.fetch(stop: stop, number: 1)
    code = stop.code
    response = SoapClient.new.call :recherche_prochaines_arrivees_web,
      message: { code_arret: code, nb_horaires: number}
    response = response.body[:recherche_prochaines_arrivees_web_response]
    res = response[:recherche_prochaines_arrivees_web_result][:liste_arrivee].try(:[], :arrivee)
    raise NoNextArrivals if res.blank?
    res = [res] unless res.is_a? Array

    ary = res.inject({}){|memo, obj|
      scheduled_remaining_time = obj[:horaire]
      mode = obj[:mode].to_s.downcase
      head, *tail = obj[:destination].split(" ")
      line_name = head
      direction_name = tail.join(" ")

      if (line = memo[ line_name ]).blank?
        line_direction = LineDirection.new name: direction_name, mode: mode, scheduled_times: [ scheduled_remaining_time ]
        line = Line.new stop: stop, mode: mode, name: line_name, line_directions: [ line_direction ]
        memo[ line_name ] = line
      else
        if (already_existing_line_direction = line.line_directions.detect{|x| x.mode == mode && x.name == direction_name }).blank?
          line.line_directions << LineDirection.new(name: direction_name, mode: mode, scheduled_times: [ scheduled_remaining_time ])
        else
          already_existing_line_direction.scheduled_times << scheduled_remaining_time
        end
      end
      memo
    }.values

    ary.sort!{|x,y| x.name <=> y.name }

    ary.each{|x|
      x.line_directions.sort!{|x,y| x.name <=> y.name }
    }
  end
end