class LineDirection
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :line, :name, :mode, :scheduled_times

  def id
    [line.id, name].join("-").parameterize
  end

  def attributes
    {
      mode: mode,
      name: name,
      scheduled_times: scheduled_times
    }
  end
end
