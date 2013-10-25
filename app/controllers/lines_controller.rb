class LinesController < ApplicationController

  def index
    stop_ids = params[:stop_ids].present? ? params[:stop_ids] : [ params[:stop_id] ]
    @stops = Stop.find stop_ids
    @lines = @stops.inject([]){|ary, stop|
      ary += stop.lines(number: 3)
    }

    respond_to do |format|
      format.html
      format.json {
        render json: @lines, each_serializer: LineSerializer
      }
    end
  end
end
