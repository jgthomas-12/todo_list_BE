require "rails_helper"
require "rack/test"

RSpec.describe "POST API V1 tasks request", type: :request do
  describe "POST /api/v1/tasks" do
    describe "happy path" do
      it "creates a task from valid parameters without an image" do
        new_task_params = {
          task: {
            name: "Make POST request",
            description: "Establish the ability to post tasks via an endpoint for the front end",
            completed: false
          }
        }

        expect(Task.all.count).to eq(0)
        expect(ActiveStorage::Blob.count).to eq(0)

        post api_v1_tasks_path, params: new_task_params, as: :json

        expect(response.status).to eq(201)
        expect(response).to be_successful

        new_task_response = JSON.parse(response.body, symbolize_names: true)

        expect(Task.all.count).to eq(1)
        expect(ActiveStorage::Blob.count).to eq(0)

        expect(new_task_response).to be_a(Hash)
        expect(new_task_response).to have_key(:task)
        expect(new_task_response[:task]).to have_key(:id)
        expect(new_task_response[:task]).to have_key(:taskname)
      end

      subject { post "/api/v1/tasks", params: params }

      let(:params) { { task: { name: taskname, description: description, completed: false, image: image } } }
      let(:taskname) { "Test task" }
      let(:description) { "Test Description" }
      let(:image) { fixture_file_upload("image.png") }

      it "creates a task with an attached image if there is one" do
        expect(Task.all.count).to eq(0)
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
          expect(response).to have_http_status :created
        end

        it "returns a JSON response" do
          subject

          expect(JSON.parse(response.body)).to eql(
            "task" => {
              "id" => Task.last.id,
              "taskname" => "Test task"
            }
          )
        end

        it "creates a task" do
          expect { subject }.to change { Task.count }.from(0).to(1)
        end

        it "creates a blob" do
          expect { subject }.to change { ActiveStorage::Blob.count }.from(0).to(1)
        end

        it "attaches the image" do
          expect(Task.last&.image).to be_nil
          subject
          expect(Task.last.image).to be_attached
        end
      end
    end
  end
end