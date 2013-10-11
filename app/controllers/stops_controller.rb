class StopsController < ApplicationController

  def index

    respond_to do |format|
      format.html
      format.json {
        render json: Stop.near([params[:lat], params[:lng]], 1, :units => :km)
      }
    end
  end

  def next_arrivals
    @stop = Stop.find params[:id]
    @next_arrivals = @stop.next_arrivals

    respond_to do |format|
      format.html
      format.json {
        render json: @next_arrivals
      }
    end
  end
end
