class StopsController < ApplicationController

  def index

    respond_to do |format|
      format.html {
        @main_app_name = "Bus"
        @main_app_name = "Tram" if request.subdomains(0).any?{|x| x =~ /tram/ }
      }
      format.json {
        render json: Stop.near([params[:lat], params[:lng]], 1, :units => :km).to_json(methods: [:lat, :lng])
      }
    end
  end

  def next_arrivals
    @stop = Stop.find params[:id]
    @next_arrivals = @stop.next_arrivals(number: 3)

    respond_to do |format|
      format.html
      format.json {
        render json: @next_arrivals
      }
    end
  rescue NoNextArrivals => e
    respond_to do |format|
      format.html
      format.json {
        render json: {error: e.to_s}, status: 500
      }
    end
  end
end
