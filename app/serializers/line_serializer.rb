class LineSerializer < ActiveModel::Serializer
  attributes :name, :mode, :stop_id
  has_many :line_directions
end
