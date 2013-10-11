require 'soap_client'
require 'csv'

class Stop
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug
  include Geocoder::Model::Mongoid
  reverse_geocoded_by :coordinates

  slug :code

  field :name
  field :google_transit_name
  field :code, type: Integer
  field :coordinates, type: Array

  index({ coordinates: "2d" }, { min: -200, max: 200 })

  def next_arrivals(time: Time.now)
    time = Time.new(time) unless time.is_a? Time
    response = self.class.cts_soap_client.call :recherche_prochaines_arrivees_web,
      message: { code_arret: self.code, heure: time, nb_horaires: 1}
    response = response.body[:recherche_prochaines_arrivees_web_response]
    response[:recherche_prochaines_arrivees_web_result][:liste_arrivee][:arrivee]
  rescue
    []
  end

  def timesheets
    response = self.class.cts_soap_client.call :recherche_fiches_horaires,
      message: { code_arret: self.code }
    response = response.body[:recherche_fiches_horaires_response]
    response = response[:recherche_fiches_horaires_result]
    response[:fiches_horaires][:fiche_horaire]
  end

  def self.load_google_transit_infos
    CSV.foreach("stops.txt", headers: true) do |row|
      code = row["stop_code"].to_i
      stop = Stop.where(code: code).first
      if !row.empty?
        if stop.present?
          if row["stop_lat"].present? && row["stop_lon"].present?
            stop.coordinates = [row["stop_lon"].to_f, row["stop_lat"].to_f]
            stop.save!
            puts "Saving #{stop.name}"
          else
            puts "Empty coordinates"
          end
        else
          puts "Stop not found :("
        end
      else
        puts "empty row..."
      end
    end
  end

  def self.fetch_all
    next_page_exists = true
    # letter = 'a'
    page = 1
    # while letter <= 'z'
      while next_page_exists
        response = cts_soap_client.call(:rechercher_codes_arrets_depuis_libelle, message: { saisie: '', no_page: page }).body[:rechercher_codes_arrets_depuis_libelle_response][:rechercher_codes_arrets_depuis_libelle_result]
        puts "Fetching page #{page}"

        response[:liste_arret][:arret].each do |arret|
          stop = Stop.find_or_initialize_by code: arret[:code]
          stop.name = arret[:libelle]
          stop.save!
          puts "Saving #{stop.name}"
        end

        next_page_exists = response[:suite]
        page += 1
      end
      # letter!
    # end
  end

  def self.do_everything!
    fetch_all
    load_google_transit_infos
  end

private

  def self.cts_soap_client
    @cts_soap_client ||= SoapClient.new
  end
end
