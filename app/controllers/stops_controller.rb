class StopsController < ApplicationController

  def index
    lat, lng = params[:lng].to_f, params[:lat].to_f
    @stops = Stop.geo_near([lat, lng]).max_distance(0.7/111.12).to_a[0, 10]
    render json: @stops
  end
end
