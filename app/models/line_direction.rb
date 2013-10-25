class LineDirection
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :name, :mode, :scheduled_times

  def attributes
    {
      mode: mode,
      name: name,
      scheduled_times: scheduled_times
    }
  end
end