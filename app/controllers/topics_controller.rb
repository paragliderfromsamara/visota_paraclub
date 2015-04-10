class TopicsController < ApplicationController
include ThemesHelper
include EventsHelper
  # GET /topics
  # GET /topics.json
  def index
    @topics = Topic.all
	@title = "Клубная Жизнь"
    respond_to do |format|
	  format.html# index.html.erb
      format.json { render :json => @topics }
    end
  end

  # GET /topics/1
  # GET /topics/1.json
  def show
    @topic = Topic.find(params[:id])
	@title = @topic.name
	@themes_per_page = 25
	if is_not_authorized?
		@themes = @topic.themes.where('status_id in (1, 4) and visibility_status_id = 1').paginate(:page => params[:page], :per_page => @themes_per_page, :order => 'last_message_date DESC')
	else
		@themes = @topic.themes.where('status_id in (1, 4)and visibility_status_id in (1,2)').paginate(:page => params[:page], :per_page => @themes_per_page, :order => 'last_message_date DESC')
	end
	@path_array = [
					{:name => 'Клубная жизнь', :link => '/visota_life'},
					{:name => @topic.name, :link => topic_path(@topic)}
				  ]
    respond_to do |format|
      format.html# show.html.erb
      format.json { render :json => @topic }
    end
  end

  # GET /topics/new
  # GET /topics/new.json
  def new
	if user_type == 'super_admin'
		@topic = Topic.new
		respond_to do |format|
		  format.html# new.html.erb
		  format.json { render :json => @topic }
		end
	else
		redirect_to '/404'
	end
  end

  # GET /topics/1/edit
  def edit
	if user_type == 'super_admin'
		@topic = Topic.find(params[:id])
		@title = "Изменение раздела '#{@topic.name}'"
		respond_to do |format|
		  format.html# new.html.erb
		  format.json { render :json => @topic }
		end
	else
		redirect_to '/404'
	end
  end

  # POST /topics
  # POST /topics.json
  def create
	if user_type == 'super_admin'
		@topic = Topic.new(params[:topic])

		respond_to do |format|
		  if @topic.save
			format.html { redirect_to @topic, :notice => 'Раздел успешно создан' }
			format.json { render :json => @topic, :status => :created, :location => @topic }
		  else
			format.html { render :action => "new"}
			format.json { render :json => @topic.errors, :status => :unprocessable_entity }
		  end
		end
	else
		redirect_to '/404'
	end
  end

  # PUT /topics/1
  # PUT /topics/1.json
  def update
	if user_type == 'super_admin'
		@topic = Topic.find(params[:id])

		respond_to do |format|
		  if @topic.update_attributes(params[:topic])
			format.html { redirect_to @topic, :notice => 'Раздел успешно обновлён' }
			format.json { head :no_content }
		  else
			format.html { render :action => "edit"}
			format.json { render :json => @topic.errors, :status => :unprocessable_entity }
		  end
		end
	else
		redirect_to '/404'
	end
  end

  # DELETE /topics/1
  # DELETE /topics/1.json
  def destroy
	if user_type == 'super_admin'
		@topic = Topic.find(params[:id])
		@topic.destroy

		respond_to do |format|
		  format.html { redirect_to topics_url }
		  format.json { head :no_content }
		end
	else
		redirect_to '/404'
	end
  end
  
  
end
