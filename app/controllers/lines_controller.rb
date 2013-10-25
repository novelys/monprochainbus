class LinesController < ApplicationController

  def index
    stop_ids = params[:stop_ids].present? ? params[:stop_ids] : [ params[:stop_id] ]
    @stops = Stop.find stop_ids

    threads = []
    @lines = []
    mutex = Mutex.new
    now = Time.now
    @stops.each{|stop|
      threads << Thread.new {
        res = stop.lines(number: 3, time: now)
        mutex.synchronize {
          @lines += res
        }
      }
    }
    threads.each {|t| t.join}

    respond_to do |format|
      format.html
      format.json {
        render json: @lines, each_serializer: LineSerializer
      }
    end
  end
end
