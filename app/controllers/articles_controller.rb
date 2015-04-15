class ArticlesController < ApplicationController
  # GET /articles
  # GET /articles.json
  def index
	article = Article.new
	@curArtCat = article.types.first
	article.types.each do |t|
		if params[:c] == t[:link]
			@curArtCat = t
			break
		end
	end  
	@title = @curArtCat[:multiple_name]
  vStatus = (is_not_authorized?)? [1]:[1,2]
	@articles = Article.find_all_by_article_type_id_and_status_id_and_visibility_status_id(@curArtCat[:value], 1, vStatus, :order => 'accident_date DESC')
	  respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @articles }
    end
  end


  # GET /articles/1
  # GET /articles/1.json
  def show
    @article = Article.find(params[:id])
	@photos = Photo.select(:id)
	@events = Event.find_all_by_display_area_id(([2, 3]), :order => 'post_date DESC', :limit => 3)
	@path_array = [
					{:name => 'Материалы', :link => '/articles'},
					{:name => @article.type_name_multiple, :link => @article.type_path},
					{:name => @article.alter_name, :link => article_path(@article)}
				  ]
	@title = @article.alter_name
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @article }
    end
  end

  # GET /articles/new
  # GET /articles/new.json
  def new
	@formArticle = Article.new
	@type = @formArticle.get_type_by_id(params[:c])
	if userCanCreateArticle? and @type != nil
		@draft = current_user.article_draft
    if @draft.article_type_id != 	params[:c].to_i
      @draft.clean
      @draft.update_attribute(:article_type_id, params[:c])
    end
		@title = "#{@type[:form_title]}"
		respond_to do |format|
		  format.html # new.html.erb
		  format.json { render :json => @formArticle }
		end
	else
		redirect_to '/404'
	end
  end

  # GET /articles/1/edit
  def edit
    @formArticle = Article.find(params[:id])
	if userCanEditArtilcle?(@formArticle)
		@type = @formArticle.type
		@draft = @formArticle
    redirect_to '/404' if @type == nil 
		@title = "Изменение материала"
	else 
		redirect_to '/404'
	end
	
  end

  # POST /articles
  # POST /articles.json
  def create
	if user_type != 'guest' and user_type != 'bunned'
		params[:article][:user_id] = current_user.id
    params[:article][:status_id] = 1
		@article = Article.new(params[:article])
		params[:v] = params[:article][:article_type_id]
		@type = @article.get_type_by_id(params[:v])
		respond_to do |format|
		  if @article.save
			format.html { redirect_to @article.type_path, :notice => 'Материал успешно добавлен' }
			format.json { render :json => @article, :status => :created, :location => @article }
		  else
			format.html { render :action => "new"  }
			format.json { render :json => @article.errors, :status => :unprocessable_entity }
		  end
		end
	else
		redirect_to '/404'
	end
  end

  # PUT /articles/1
  # PUT /articles/1.json
  def update
    @article = Article.find(params[:id])
	if userCanEditArtilcle?(@article)
		respond_to do |format|
		  if @article.update_attributes(params[:article])
			format.html { redirect_to @article, :notice => 'Статья успешно добавлена' }
			format.json { head :no_content }
		  else
			format.html { render :action => "edit" }
			format.json { render :json => @article.errors, :status => :unprocessable_entity }
		  end
		end
	else
		redirect_to '/404'
	end
  end

  # DELETE /articles/1
  # DELETE /articles/1.json
  def destroy
    @article = Article.find(params[:id])
	  type = @article.get_type_by_id(@article.article_type_id)
    @article.destroy

    respond_to do |format|
      format.html { redirect_to articles_path(:c=>type[:link]) }
      format.json { head :no_content }
    end
  end
  def upload_photos
	article = Article.find_by_id(params[:id]) 
	if isEntityOwner?(article)
		@photo = Photo.new(:article_id => article.id, :user_id => article.user.id, :link => params[:article][:uploaded_photos], :status_id => 1)
		if @photo.save
			render :json => {:message => 'success', :photoID => @photo.id }, :status => 200
		else
			render :json => {:error => @photo.errors.full_messages.join(',')}, :status => 400
		end
	else
		redirect_to '/404'
	end
  end
  def bind_videos_and_albums
    article = Article.find_by_id(params[:id])  
	if isEntityOwner?(article) and params[:format] == 'json'
		@albums = PhotoAlbum.find_all_by_article_id_and_status_id(([nil, article.id]), 1)
		@videos = Video.find_all_by_article_id([nil, article.id])
		a = []
		v = []
		@albums.each {|al| a[a.length] = {:id => al.id, :name => al.name, :link => photo_album_path(al)}} if @albums != []
		@videos.each {|vi| v[v.length] = {:id => vi.id, :name => vi.alter_name, :link => video_path(vi)}} if @videos != [] 
		render :json => {:albums => a, :videos => v}
	else
		redirect_to '/404'
	end
  end
end
