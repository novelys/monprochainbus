class LinesController < ApplicationController

  def index
    stop_ids = params[:stop_ids].present? ? params[:stop_ids] : [ params[:stop_id] ]
    @stops = Stop.find stop_ids

    @lines = []

    if Rails.env.development?
      @stops.each{|stop|
        begin
          res = stop.lines(number: 3)
        rescue NoNextArrivals
          res = []
        end
        @lines += res
      }
    else
      threads = []
      mutex = Mutex.new
      @stops.each{|stop|
        threads << Thread.new {
          begin
            res = stop.lines(number: 3)
          rescue NoNextArrivals
            res = []
          end
          mutex.synchronize {
            @lines += res
          }
        }
      }
      threads.each {|t| t.join}
    end

    respond_to do |format|
      format.html
      format.json {
        render json: @lines, each_serializer: LineSerializer
      }
    end
  end
end
