class VotesController < ApplicationController
  skip_before_filter  :verify_authenticity_token

  def create
    response = JSON.parse(params[:payload])
    gif = response["actions"].first
    user = response["user"]["name"]

    if Vote.where(user: user).where(created_at: 1.day.ago..DateTime.current).any?
      render json: { text: "C'mon, #{user}, you've already voted." }, status: :ok and return
    else
      Vote.create!(entry_id: gif[:name], user: user)
      render json: { response_type: "ephemeral", replace_original: true, text: "Thank you #{user} for voting." }, status: :ok
    end
  end
end
