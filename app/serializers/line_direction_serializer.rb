class LineDirectionSerializer < ActiveModel::Serializer
  attributes :name, :mode, :scheduled_times
  belongs_to :line
end
