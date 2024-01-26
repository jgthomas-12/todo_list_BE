require "rails_helper"

RSpec.describe "GET API V1 tasks request", type: :request do
  describe "GET /api/v1/tasks" do
    describe "happy path" do
      it "returns a list of tasks" do

        task_1 = Task.create!(name: "Create Front End", description: "Make React app after this dawggy", completed: false )
        task_2 = Task.create!(name: "Connect the two", description: "Connect front and back end", completed: false )


        get api_v1_tasks_path

        expect(response.status).to eq(200)
        expect(response).to be_successful

        all_tasks_response = JSON.parse(response.body, symbolize_names: true)

        expect(all_tasks_response[:data].count).to eq(2)
        all_tasks_response[:data].each do |task|
          expect(task).to be_a(Hash)

          expect(task).to have_key(:id)
          expect(task[:id].to_i).to be_an(Integer)

          expect(task).to have_key(:type)
          expect(task[:type]).to eq("task")

          expect(task[:attributes]).to have_key(:name)
          expect(task[:attributes][:name]).to be_a(String)
          expect(task[:attributes][:description]).to be_a(String)
          # expect(task[:attributes][:completed]).to be_a(Boolean)
        end
      end

      it "returns one task JSON object by id" do

        task_1 = Task.create!(name: "Create Front End", description: "Make React app after this dawggy", completed: false )
        task_2 = Task.create!(name: "Connect the two", description: "Connect front and back end", completed: false )

        get api_v1_task_path(task_1)

        expect(response.status).to eq(200)
        expect(response).to be_successful

        task_response = JSON.parse(response.body, symbolize_names: true)

        expect(task_response).to be_a(Hash)

        expect(task_response).to have_key(:data)
        expect(task_response[:data]).to be_a(Hash)

        expect(task_response[:data]).to have_key(:id)
        expect(task_response[:data][:id].to_i).to be_an(Integer)

        expect(task_response[:data]).to have_key(:type)
        expect(task_response[:data][:type]).to be_a(String)

        expect(task_response[:data][:attributes]).to have_key(:name)
        expect(task_response[:data][:attributes]).to have_key(:description)
        expect(task_response[:data][:attributes]).to have_key(:image_url)

        expect(task_response[:data][:attributes][:name]).to be_a(String)
        expect(task_response[:data][:attributes][:description]).to be_a(String)
        expect(task_response[:data][:attributes][:image_url]).to be(nil)

        expect(task_response[:data][:attributes][:name]).to eq(task_1.name)
        expect(task_response[:data][:attributes][:description]).to eq(task_1.description)

        expect(task_response[:data][:attributes][:name]).to_not eq(task_2.name)
        expect(task_response[:data][:attributes][:description]).to_not eq(task_2.description)
      end

      let(:image) { fixture_file_upload("image.png") }

      it "returns one task JSON object, with image URL, by id if there is an image attached" do

        task_1 = Task.create!(name: "Create Front End", description: "Make React app after this dawggy", completed: false, image: image )
        image_string = rails_blob_url(task_1.image)
        cleaned_up_image_string = image_string.gsub("http://www.example.com", "")

        get api_v1_task_path(task_1)

        expect(response.status).to eq(200)
        expect(response).to be_successful

        task_response = JSON.parse(response.body, symbolize_names: true)

        expect(task_response[:data][:attributes]).to have_key(:image_url)
        expect(task_response[:data][:attributes][:image_url]).to be_a(String)

        expect(task_response[:data][:attributes][:image_url]).to include(cleaned_up_image_string)
      end
    end
  end
end