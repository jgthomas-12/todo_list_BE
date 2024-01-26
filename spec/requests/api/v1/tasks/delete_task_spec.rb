require "rails_helper"

RSpec.describe "DELETE API V1 tasks request", type: :request do
  describe "DELETE /api/v1/tasks" do
    describe "happy path" do
      it "deletes a task by id" do

        task_1 = Task.create!(name: "Create Front End", description: "Make React app after this dawggy", completed: false )

        expect(Task.all.count).to eq(1)

        delete api_v1_task_path(task_1.id)

        expect(response.status).to eq(200)
        expect(response).to be_successful

        deleted_task_response = JSON.parse(response.body, symbolize_names: true)

        expect(Task.all.count).to eq(0)
        expect(deleted_task_response).to be_a(Hash)
        expect(deleted_task_response).to have_key(:success)
        expect(deleted_task_response).to have_value("Task deleted successfully")
      end
    end
  end
end