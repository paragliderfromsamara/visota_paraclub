class VideosController < ApplicationController
include MessagesHelper
include ApplicationHelper
  # GET /videos
  # GET /videos.json
  def index
    @videos = Video.all
	@title = 'Видео'
	@per_page = 18
	@video = Video.new
	case params[:c]
	when 'paragliding'
		@videos = Video.paginate(:page => params[:page], :per_page => @per_page, :order => 'created_at DESC').find_all_by_category_id(5)
		@category_name = 'Свободные полёты'
	when 'power_paragliding'
		@videos = Video.paginate(:page => params[:page], :per_page => @per_page, :order => 'created_at DESC').find_all_by_category_id(4)
		@category_name = 'Моторные полёты'
	when 'kiting'
		@videos = Video.paginate(:page => params[:page], :per_page => @per_page, :order => 'created_at DESC').find_all_by_category_id(2)
		@category_name = 'Кайтинг'		
	when 'club_events'
		@videos = Video.paginate(:page => params[:page], :per_page => @per_page, :order => 'created_at DESC').find_all_by_category_id(3)
		@category_name = 'Клубные мероприятия'
	when 'another'
		@videos = Video.paginate(:page => params[:page], :per_page => @per_page, :order => 'created_at DESC').find_all_by_category_id(1)
		@category_name = 'Разное'
	else
		@videos = Video.paginate(:page => params[:page], :per_page => @per_page, :order => 'created_at DESC').all
		@category_name = 'Все видео'
	end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @videos }
    end
  end
  
  # GET /videos/1
  # GET /videos/1.json
  def show
    @video = Video.find(params[:id])
	if @video != nil
		@title = @video.alter_name
		@return_to = video_path(@video)
		@page_params = {:part_id => 5,:page_id => 1,:entity_id => @video.id}
		@path_array = [
						{:name => 'Видео', :link => videos_path},
						{:name => @video.category_name, :link => videos_path(:c => @video.category_path)},
						{:name => @video.alter_name, :link => '/'}
					  ]
		@comments = @video.messages.where(:status_id => 1).order('created_at ASC')
		respond_to do |format|
		  format.html # show.html.erb
		  format.json { render :json => @video }
		end
	end
  end

  # GET /videos/new
  # GET /videos/new.json
  def new
	if user_type != 'guest' and user_type != 'bunned' and user_type != 'new_user'
		@video = Video.new
		
		@title = 'Новое видео'
		respond_to do |format|
		  format.html # new.html.erb
		  format.json { render :json => @video }
		end
	else
		redirect_to '/404'
	end
  end

  # GET /videos/1/edit
  def edit
    @video = Video.find(params[:id])
	if @video.user == current_user or user_type == 'admin' or user_type == 'super_admin' 
	
	else
		redirect_to '/404'
	end
  end

  # POST /videos
  # POST /videos.json
  def create
	if user_type != 'guest' and user_type != 'bunned' and user_type != 'new_user'
		params[:video][:user_id] = current_user.id
		@video = Video.new(params[:video])
		respond_to do |format|
		  if @video.save
			format.html { redirect_to @video, :notice => 'Видео успешно добавлено' }
			format.json { render :json => @video, :status => :created, :location => @video }
		  else
			format.html { render :action => "new" }
			format.json { render :json => @video.errors, :status => :unprocessable_entity }
		  end
		end
	else
		redirect_to '/404'
	end
  end

  # PUT /videos/1
  # PUT /videos/1.json
  def update
    @video = Video.find(params[:id])
	if @video.user == current_user or user_type == 'admin' or user_type == 'super_admin' 
		respond_to do |format|
		  if @video.update_attributes(params[:video])
			format.html { redirect_to @video, :notice => 'Видео успешно обновлено' }
			format.json { head :no_content }
		  else
			format.html { render :action => "edit" }
			format.json { render :json => @video.errors, :status => :unprocessable_entity }
		  end
		end
	else
		redirect_to '/404'
	end
  end

  # DELETE /videos/1
  # DELETE /videos/1.json
  def destroy
    @video = Video.find(params[:id])
	if @video.user == current_user or user_type == 'admin' or user_type == 'super_admin'
		@video.destroy

		respond_to do |format|
		  format.html { redirect_to videos_url }
		  format.json { head :no_content }
		end
	else
		redirect_to '/404'
	end
  end
  def new_comment
    @video = Video.find(params[:id])
	if user_type != 'guest' and user_type != 'bunned'
		@draft = current_user.message_draft
		@add_functions = "initMessageForm(#{@draft.id});"
		@path_array = [
						{:name => 'Видео', :link => videos_path},
						{:name => @video.category_name, :link => videos_path(:c => @video.category_path)},
						{:name => @video.alter_name, :link => video_path(@video)}, 
						{:name => 'Новый комментарий', :link => '/'} 
					  ]
		@message = Message.new
		@message_to = Message.find_by_id(params[:m])
	else
		redirect_to '/404'
	end
  end
end
