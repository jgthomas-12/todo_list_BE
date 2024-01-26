class Api::V1::TasksController < ApplicationController
  def index
    tasks = Task.all
    render json: TaskSerializer.new(tasks)
  end

  def show
    task = Task.find_by(id: params[:id])

    render json: TaskSerializer.new(task)
  end

  def create
    new_task = Task.new(new_task_params)

    if new_task.save
      render json: success_json(new_task), status: :created
    else
      render json: { errors: task.errors.full_messages }, status: :unprocessible_entity
    end
  end

  def destroy
    task = Task.find(params[:id])
    task.destroy
    render json: { success: "Task deleted successfully"}
  end

  def update
    task = Task.find_by(id: params[:id])

    task.update(new_task_params)
    render json: { success: "Task updated successfully"}, status: :ok
  end

  private

  def new_task_params
    params.require(:task).permit(:name, :description, :completed, :image)
  end

  def success_json(task)
    {
      task: {
        id: task.id,
        taskname: task.name
      }
    }
  end
end
