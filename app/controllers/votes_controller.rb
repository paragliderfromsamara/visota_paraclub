class VotesController < ApplicationController
  def index
	@completed_votes = Vote.where("end_date < :time_now", {:time_now => Time.now})
	@active_votes = Vote.where("end_date > :time_now", {:time_now => Time.now})
	@path_array = [
						{:name => 'Клубная жизнь', :link => '/visota_life'},
						{:name => 'Опросы'}
				  ]
          @title = 'Опросы'
	respond_to do |format|
	  format.html # index.html.erb
      format.json { render :json => @votes }
	end
  end

  def show
	@vote = Vote.find(params[:id])
  @title = @vote.name
	@path_array = [
						{:name => 'Клубная жизнь', :link => '/visota_life'},
						{:name => 'Опросы', :link => votes_path},
						{:name => @vote.name}
				  ]
	if user_type != 'guest'
		user_voice = Voice.find_by_user_id_and_vote_id(current_user, @vote.id)
		@add_functions = "voteShowPath(#{@vote.id});" if user_voice.nil?
	end
	respond_to do |format|
		format.html # show.html.erb
	  format.json { render :json => @vote }
	end
  end

  def new
	if !is_not_authorized?
		@vote = Vote.new
		@title = 'Новый опрос'
		@add_functions = "initVoteForm('#new_vote');"
		@path_array = [
						{:name => 'Клубная жизнь', :link => '/visota_life'},
						{:name => 'Опросы', :link => votes_path},
						{:name => 'Новый опрос'}
					  ]
	else 
		redirect_to '/404'
	end
  end

  def create
	if !is_not_authorized?
		params[:vote][:user_id] = current_user.id
		@vote = Vote.new(params[:vote])
		respond_to do |format|
		 if @vote.save
			format.html { redirect_to @vote, :notice => 'Опрос добавлен...' }
			format.json { render :json => @vote, :status => :created, :location => @vote }
		 else
			@title = 'Новый опрос'
			@add_functions = "initVoteForm('#new_vote');"
			@path_array = [
						{:name => 'Клубная жизнь', :link => '/visota_life'},
						{:name => 'Опросы', :link => votes_path},
						{:name => 'Новый опрос'}
					  ]
			format.html { render :action => "new"}
			format.json { render :json => @vote.errors, :status => :unprocessable_entity }
		 end
		end
	else 
		redirect_to '/404'
	end
  end

  def edit
  end

  def update
  end

  def destroy
    vote = Vote.find_by_id(params[:id])
    if userCanEditVote?(vote)
      vote.destroy
      redirect_to votes_path
    else 
      redirect_to '/404'
    end
  end
end
