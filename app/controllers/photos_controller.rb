class PhotosController < ApplicationController
include MessagesHelper
  # GET /photos
  # GET /photos.json
  def index
	@js_photos = [{:id => 'null'}] #application.js getMsgPhotosToForm(msgId, el)
	jsPhotos = []
	if params[:message_id] != nil
		@photos = Photo.find_all_by_message_id(params[:message_id])
	elsif params[:photo_album_id] != nil
		@photos = Photo.find_all_by_photo_album_id(params[:photo_album_id])
	else
		 @photos = Photo.all
	end
	if @photos != [] and params[:format] == 'json'
		@photos.each do |photo|
			jsPhotos[jsPhotos.length] = {:id => photo.id, :link => photo.link.to_s, :thumb => photo.link.thumb.to_s, :description => photo.description}
		end
		@js_photos = jsPhotos
	
	end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @js_photos }
    end
  end

  # GET /photos/1
  # GET /photos/1.json
  def show
    @photo = Photo.find_by_id(params[:id])
	if userCanSeePhoto?(@photo)
		@photos = []
		@j_photo = {:id => @photo.id, :link => @photo.link.to_s, :thumb => @photo.link.thumb.to_s, :description => @photo.description}
		@prev_photo = nil
		@next_photo = nil
		@return_to = photo_path(@photo)
		if @photo.photo_album != nil
			@photos = @photo.photo_album.visible_photos
			@album = @photo.photo_album
		end
		if @photo.message != nil
			@message_to = @photo.message
			@photos = @photo.message.photos
			@theme = @message_to.theme if @message_to.theme != nil
		end
		if @photo.theme != nil
			@theme = @photo.theme
			@photos = @photo.theme.photos
		end
		if @photos == []
			@photos = @photo.article.visible_photos if @photo.article != nil
		end
		if @photos != []
			@prev_photo = photo_path(@photos[@photos.index(@photo) - 1]) if @photos.index(@photo) > 0
			@next_photo = photo_path(@photos[@photos.index(@photo) + 1]) if @photos.index(@photo) < (@photos.length - 1)
		end
		respond_to do |format|
		  format.html {render :layout => 'photo_show'}# show.html.erb
		  format.json { render :json => @j_photo }
		end
	else
		@j_photo = {:id => 'null', :link => 'null', :thumb => 'null'}
		respond_to do |format|
			  format.html {redirect_to '/404'}
			  format.json { render :json => @j_photo }
		end
	end
	 
	
  end

  # GET /photos/new
  # GET /photos/new.json
  def new
    @photo = Photo.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @photo }
    end
  end

  # GET /photos/1/edit
  def edit
    @photo = Photo.find(params[:id])
  end

  def edit_photos
	@theme = nil
	@album = nil
	@event = nil
	@message = nil
	@article = nil
	@link_to = nil
	@photos = []
	@entity = params[:e]
	case @entity
	when "theme" #Фотографии в теме...
		@theme = Theme.find_by_id(params[:e_id])
		redirect_to '/404' if !isEntityOwner?(@theme)
		@photos = @theme.photos
		@link_to = theme_path(@theme.id)
	when "photo_album" #Фотографии в альбоме...
		@album = PhotoAlbum.find_by_id(params[:e_id])
		redirect_to '/404' if !isEntityOwner?(@album)
		@photos = @album.photos
		@link_to = photo_album_path(@album.id)
	when "message" #Фотографии в теме...
		@message = Message.find_by_id(params[:e_id])
		redirect_to '/404' if !isEntityOwner?(@message)
		@photos = @message.photos
		@link_to = theme_path(@message.theme_id)
	when "article" #Фотографии в статье...
		@article = Article.find_by_id(params[:e_id])
		redirect_to '/404' if !isEntityOwner?(@article)
		@photos = @article.photos
		@link_to = article_path(@article)
	when "event" #Фотографии в Новостях...
		@event = Event.find_by_id(params[:e_id])
		redirect_to '/404' if !is_admin? and user_type != 'manager'
		@photos = @event.photos
		@link_to = event_path(@event)
	end
	redirect_to '/404' if @theme == nil && @album == nil && @event == nil && @message == nil && @article == nil
  end
  
  def update_photos
	if user_type != 'guest' and user_type != 'bunned'
		photos_params = params[:photo_editions][:photos]
		flag = 'no_changes'
		photos_params.each do |x|
				photo = Photo.find_by_id(x[1][:id])
				if photo != nil
					if photo.name != x[1][:name] or photo.description != x[1][:description]
						flag = 'updated'
						photo.update_attributes(:name => x[1][:name], :description => x[1][:description])
					end
				end
		end
		respond_to do |format|
			format.html { redirect_to params[:photo_editions][:link_to] }
			format.json { render :json => {:status => :flag}}
		end
	else
		redirect_to '/404'
	end
  end
  
  # POST /photos
  # POST /photos.json
  def create
	if user_type != 'guest' and user_type != 'bunned'
		params[:photo][:user_id] = current_user.id	
		@photo = Photo.new(params[:photo])
		respond_to do |format|
		  if @photo.save
			format.html { redirect_to @photo, :notice => 'Фото успешно добавлено' }
			format.json { render :json => @photo, :status => :created, :location => @photo }
		  else
			format.html { render :action => "new" }
			format.json { render :json => @photo.errors, :status => :unprocessable_entity }
		  end
		end
	else 
		redirect_to '/404'
	end
  end

  # PUT /photos/1
  # PUT /photos/1.json
  def update
    @photo = Photo.find(params[:id])
    respond_to do |format|
      if @photo.update_attributes(params[:photo])
        format.html { redirect_to @photo, :notice => 'Фото успешно обновлено' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @photo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.json
  def destroy
    @photo = Photo.find(params[:id])
    if userCanDeletePhoto?(@photo)
		if @photo.isNotFullDelete?
			@photo.set_as_delete
		else
			if @photo.destroy
				respond_to do |format|
				  format.html { redirect_to photos_url }
				  format.json { render :json => {:callback => 'success'} }
				end
			end
		end
	else
		if isEntityOwner?(@photo)
			render :json => {:callback => 'Невозможно удалить фотографию'}
		else
			redirect_to '/404'
		end
	end
  end
  def recovery
	@photo = Photo.find(params[:id])
	if isEntityOwner?(@photo)
		if @photo.isNotFullDelete?
			@photo.set_as_delete
		else
			if @photo.destroy
				respond_to do |format|
				  format.html { redirect_to photos_url }
				  format.json { render :json => {:callback => 'success'} }
				end
			end
		end
	else
		redirect_to '/404'
	end
  end
end
