class VotesController < ApplicationController
  def create
    p params[:actions]
    p vote_params

    render json: { response_type: "ephemeral", replace_original: true, text: "Thank you for voting." }, status: :ok
  end

  def vote_params
    params.require(:actions)
  end
end
