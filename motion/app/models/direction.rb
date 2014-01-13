class Direction
  attr_reader :name, :times

  class << self
    def all; @objects; end
    def first; @objects.first; end
    def last; @objects.last; end
    def at(i); @objects[i]; end
    def count; @objects.size; end
    def delete_all; @objects = []; end

    def loadFromJson(json = [])
      @objects ||= []
      added = json.map { |object| new(object) }
      @objects += added
      added
    end
  end

  def initialize(json = {})
    @name = json['name']
    self.times = json['scheduled_times']
  end

  def times=(times)
    @times = times.map { |str| Time.iso8601_with_timezone str.gsub('.000', '') }
  end

  def timesSince
    now = Time.now

    @times.map do |time|
      seconds = time - now

      if seconds >= 3600
        hours = (seconds / 3600).floor
        min = ((seconds % 3600) / 60).floor
        "#{hours} h #{min} min"
      elsif seconds < 60
        "moins d'1 min"
      else
        min = ((seconds % 3600) / 60).floor
        "#{min} min"
      end
    end
  end

  def formattedTimes
    timesSince.join(', ')
  end
end
