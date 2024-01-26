require "rails_helper"
require "rack/test"

RSpec.describe "POST API V1 upload request", type: :request do
  describe "POST /api/v1/upload" do
    describe "happy path" do

      subject { post "/api/v1/upload", params: params }

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

        it "creates a blob and attaches the image" do
          expect { subject }.to change { ActiveStorage::Blob.count }.from(0).to(1)
          expect(Task.last.image).to be_attached
        end
      end
    end
  end
end