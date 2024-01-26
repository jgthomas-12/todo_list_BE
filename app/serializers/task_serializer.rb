class TaskSerializer
include JSONAPI::Serializer

attributes :name, :description, :completed, :image_url
end