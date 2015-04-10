class VoicesController < ApplicationController
  def create
	@vote = Vote.find_by_id(params[:voice][:vote_id])
	if userCanGiveVoice?(@vote)
		params[:voice][:user_id] = current_user.id
		voice = Voice.new(params[:voice])
		respond_to do |format|
			if voice.save
				format.html {render :layout => false}
				format.json { render :json => @voice, :status => :created, :location => @vote }
			end
		end
	else
		redirect_to '/404'
	end
  end

  def destroy
  end
end
