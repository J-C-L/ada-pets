class PetsController < ApplicationController
  def index
    pets = Pet.all
    render json: pets.as_json(only: [:id, :name, :age, :human]), status: :ok
  end

  def show
    pet = Pet.find_by(id: params[:id])

    if pet
      render json: pet.as_json(only: [:id, :name, :age, :human]), status: :ok
    else
      #rende :not_found = 404
      render status: 404, json: { errors: "Could not find a pet with id #{params[:id]}"}
    end
  end

  def create
    pet = Pet.new(pet_params)
    if pet.save
      render status: :ok, json: { id: pet.id}
      #could send back name: pet.name ,  BUT the name might not be unique to that pet. Only guaranteed unique identifier is the id.
    else
      # :bad_request = 400
      render status: :bad_request, json: { errors: pet.errors.messages }
      # "Could not create a pet with the given data"
    end
  end



  private
  def pet_params
    params.require(:pet).permit(:name, :age, :human)
  end


end
