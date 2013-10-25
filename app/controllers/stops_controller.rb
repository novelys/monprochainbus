class StopsController < ApplicationController

  def index

    respond_to do |format|
      format.html {
        render nothing: true, layout: true
      }
      format.json {
        @stops = Stop.near([params[:lat], params[:lng]], 1, :units => :km)[0, 5]
        render json: @stops
      }
    end
  end
end
