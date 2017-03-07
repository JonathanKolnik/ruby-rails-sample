class VotesController < ApplicationController
  skip_before_filter  :verify_authenticity_token

  def create
    p params[:payload]

    render json: { response_type: "ephemeral", replace_original: true, text: "Thank you for voting." }, status: :ok
  end
end
