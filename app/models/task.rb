class Task < ApplicationRecord

  validates :name, presence: true
  validates :description, presence: true
  validates :completed, inclusion: { in: [true, false] }

  has_one_attached :image

  def image_url
    if image.attached?
      Rails.application.routes.url_helpers.rails_blob_url(image, host: 'localhost', port: 3002)
    else
      nil
    end
  end

end

