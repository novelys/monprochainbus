class Stop
  attr_reader :id, :name, :code, :lat, :lng, :lines

  class << self
    def all; @objects; end
    def first; @objects.first; end
    def last; @objects.last; end
    def at(i); @objects[i]; end
    def count; @objects.size; end
    def delete_all; @objects = []; end

    def find(id)
      @objects.find { |stop| stop.id.to_s == id.to_s }
    end

    def loadFromJson(json)
      @objects ||= []
      added = json['stops'].map { |object| new(object) }
      added.reject! {|stop| @objects.find {|o| o.id == stop.id }}
      @objects += added
      added
    end

    def paramsForLines
      @objects.map { |stop| "stop_ids[]=#{stop.id.to_s}" }.join('&')
    end
  end

  def initialize(json = {})
    @id, @name, @code, @lat, @lng = json['id'], json['name'], json['code'], json['lat'], json['lng']
    @lines = []
  end

  def add_line(line)
    @lines << line unless @lines.find { |l| l.name == line.name }
  end
end
