require 'rails_helper'

RSpec.describe Task, type: :model do
  describe "validations" do
    it { should validate_presence_of :name}
    it { should validate_presence_of :description}
    it { should validate_inclusion_of(:completed).in_array([true, false])}
  end

  describe "associations" do
    it { should have_one_attached(:image) }
  end

  describe "#image_url" do

    let(:image) { fixture_file_upload("image.png") }
    let(:task_1) { Task.create!(name: "Create Front End", description: "Make React app after this dawggy", completed: false, image: image ) }
    let(:task_2) { Task.create!(name: "Create Front End", description: "Make React app after this dawggy", completed: false) }

    context "when an image is attached" do
      it "returns a valid image URL" do
        expect(task_1.image_url).to include("/rails/active_storage/blobs/redirect/")
        expect(task_1.image_url).to include("localhost:3002")
      end
    end

    context "when no image is attached" do
      it "returns nil" do
        expect(task_2.image_url).to be_nil
      end
    end
  end
end
