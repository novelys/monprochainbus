class LineSerializer < ActiveModel::Serializer
  attributes :name, :mode
  has_many :line_directions, include_data: true
  belongs_to :stop
end
