class Line
  attr_reader :name, :mode, :stop, :directions

  class << self
    def all; @objects; end
    def first; @objects.first; end
    def last; @objects.last; end
    def at(i); @objects[i]; end
    def count; @objects.size; end
    def delete_all; @objects = []; end

    def loadFromJson(json)
      @objects ||= []
      added = json['lines'].map { |object| new(object) }
      @objects += added
      added
    end
  end

  def initialize(json = {})
    @name, @mode = json['name'], json['mode']

    @stop = Stop.find(json['stop_id'])
    @stop.add_line(self)
    self.directions = json['line_directions']
  end

  def directions=(json)
    @directions = Direction.loadFromJson(json)
  end

  def color
    AppColors.send "#{mode}#{name}"
  end

  def attributedName
    icon = (mode == "bus" && "0xe002" || "0xe001").hex.chr(Encoding::UTF_8)
    string = "#{icon} #{name.to_s}"

    label_attrs = {
      NSForegroundColorAttributeName => UIColor.whiteColor,
      NSFontAttributeName => UIFont.fontWithName("Droid Sans", size: 16)
    }
    icon_attrs = {
      NSForegroundColorAttributeName => UIColor.whiteColor,
      NSFontAttributeName => UIFont.fontWithName("icomoon", size: 14)
    }

    attrStr = NSMutableAttributedString.alloc.initWithString(string, attributes: label_attrs)
    attrStr.setAttributes(icon_attrs, range: NSMakeRange(0, 1))
    attrStr
  end
end
