class StopSerializer < ActiveModel::Serializer
  attributes :id, :name, :code, :lat, :lng

  def id
    object.slug.to_s
  end
end
