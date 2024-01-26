require "rails_helper"
require 'database_cleaner/active_record'

RSpec.describe "PATCH API V1 tasks request", type: :request do

  describe "PATCH /api/v1/tasks/:id" do
    describe "happy path" do
      it "updates a task without an image by id" do
        Task.destroy_all

        task_1 = Task.create!(name: "Create Front End", description: "Make React app after this dawggy", completed: false )

        updated_task_params = {
          task: {
            name: "Listen to Gladiator soundtrack",
            description: "While working on this project",
            completed: false
          }
        }

        expect(Task.all.count).to eq(1)

        patch api_v1_task_path(task_1.id), params: updated_task_params

        expect(response.status).to eq(200)
        expect(response).to be_successful

        updated_task_response = JSON.parse(response.body, symbolize_names: true)

        expect(Task.all.count).to eq(1)
        expect(updated_task_response).to be_a(Hash)
        expect(updated_task_response).to have_key(:success)
        expect(updated_task_response).to have_value("Task updated successfully")
      end
    end

    describe "happy path with image" do

      subject { patch "/api/v1/tasks/#{task.id}", params: image_params }

      let(:task) { Task.create!(name: "Make Patch request", description: "Allow photo objects", completed: false ) }
      let(:image_params) { { task: { name: taskname, description: description, completed: false, image: image } } }
      let(:taskname) { "Still making patch request" }
      let(:description) { "With updated name, description AND an image" }
      let(:image) { fixture_file_upload("image.png") }

      it "updates a task with an attached image" do
        task
        expect(Task.all.count).to eq(1)
        expect(ActiveStorage::Blob.count).to eq(0)

        subject

        new_task_response = JSON.parse(response.body, symbolize_names: true)

        expect(Task.all.count).to eq(1)
        expect(ActiveStorage::Blob.count).to eq(1)

        expect(new_task_response).to be_a(Hash)
      end

      context "valid request with image" do
        it "returns status created" do
          subject
          expect(response).to have_http_status :ok
        end

        it "returns a JSON response" do
          subject
          expect(JSON.parse(response.body)).to eql(
            {"success"=>"Task updated successfully"}
          )
        end

        it "does not create a new task" do
          task
          expect { subject }.to_not change { Task.count }
        end

        it "creates a blob" do
          expect { subject }.to change { ActiveStorage::Blob.count }.from(0).to(1)
        end

        it "attaches an image" do
          task
          expect(Task.last.image.attached?).to be(false)
          subject
          expect(Task.last.image).to be_attached
        end
      end
    end
  end
end