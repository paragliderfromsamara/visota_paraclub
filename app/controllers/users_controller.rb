class UsersController < ApplicationController
include UsersHelper
  # GET /users
  # GET /users.json
  def index
	category = params[:g]
	if category == 'club_friends'
		@title = 'Друзья клуба'
		@active_button = 1 
		@users = User.paginate(:page => params[:page], :per_page => 10).find_all_by_user_group_id(3)
	elsif category == 'just_came'
		@title = 'Вновь прибывшие'
		@active_button = 2
		@users = User.paginate(:page => params[:page], :per_page => 10).find_all_by_user_group_id(5)
	elsif category == 'bun_list' and is_admin?
		@title = 'Бан лист'
		@active_button = 3 
		@users = User.paginate(:page => params[:page], :per_page => 10).find_all_by_user_group_id(4)
	else 
		@title = 'Клубные пилоты'
		@active_button = 0
		@users = User.paginate(:page => params[:page], :per_page => 10).find_all_by_user_group_id([1, 0, 2, 6], :order => 'user_group_id DESC')
	end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @users }
    end
  end
  def videos
	@user = User.find_by_id(params[:id])
	if @user != nil
		@title = 'Видео'
		@per_page = 18
		case params[:c]
		when 'paragliding'
			@videos = @user.videos.paginate(:page => params[:page], :per_page => @per_page, :order => 'created_at DESC').find_all_by_category_id(5)
			@category_name = 'Свободные полёты'
		when 'power_paragliding'
			@videos = @user.videos.paginate(:page => params[:page], :per_page => @per_page, :order => 'created_at DESC').find_all_by_category_id(4)
			@category_name = 'Моторные полёты'
		when 'kiting'
			@videos = @user.videos.paginate(:page => params[:page], :per_page => @per_page, :order => 'created_at DESC').find_all_by_category_id(2)
			@category_name = 'Кайтинг'		
		when 'club_events'
			@videos = @user.videos.paginate(:page => params[:page], :per_page => @per_page, :order => 'created_at DESC').find_all_by_category_id(3)
			@category_name = 'Клубные мероприятия'
		when 'another'
			@videos = @user.videos.paginate(:page => params[:page], :per_page => @per_page, :order => 'created_at DESC').find_all_by_category_id(1)
			@category_name = 'Разное'
		else
			@videos = @user.videos.paginate(:page => params[:page], :per_page => @per_page, :order => 'created_at DESC').all
			@category_name = 'Все видео'
		end
		@path_array = [
						{:name => 'Видео', :link => videos_path},
						{:name => "Видео пользователя #{@user.name}"}
					  ]
		respond_to do |format|
			format.html { render 'videos/index' }
			format.json { render :json => @videos }
		end
	else
		redirect_to '/404'
	end
  end
  def photo_albums
	@user = User.find_by_id(params[:id])
	if @user != nil
		@title = "Фотоальбомы пользователя #{@user.name}"
		@per_page = 18
		case params[:c]
		when 'paragliding'
			@albums = @user.photo_albums.paginate(:page => params[:page], :per_page => @per_page, :order => 'created_at DESC').find_all_by_category_id_and_status_id(5, 1)
			@category_name = 'Свободные полёты'
		when 'power_paragliding'
			@albums = @user.photo_albums.paginate(:page => params[:page], :per_page => @per_page, :order => 'created_at DESC').find_all_by_category_id_and_status_id(4, 1)
			@category_name = 'Моторные полёты'
		when 'kiting'
			@albums = @user.photo_albums.paginate(:page => params[:page], :per_page => @per_page, :order => 'created_at DESC').find_all_by_category_id_and_status_id(2, 1)
			@category_name = 'Кайтинг'		
		when 'club_events'
			@albums = @user.photo_albums.paginate(:page => params[:page], :per_page => @per_page, :order => 'created_at DESC').find_all_by_category_id_and_status_id(3, 1)
			@category_name = 'Клубные мероприятия'
			
		when 'another'
			@albums = @user.photo_albums.paginate(:page => params[:page], :per_page => @per_page, :order => 'created_at DESC').find_all_by_category_id_and_status_id(1, 1)
			@category_name = 'Разное'
		else
			@albums = @user.photo_albums.paginate(:page => params[:page], :per_page => @per_page, :order => 'created_at DESC').find_all_by_status_id(1)
			@category_name = 'Все альбомы'
		end
		respond_to do |format|
		  format.html {render 'photo_albums/index'}# index.html.erb
		  format.json { render :json => @photo_albums }
		end
	else
		redirect_to '/404'
	end
  end
  def articles
      @user = User.find_by_id(params[:id])
    	if @user != nil
    		@title = "Материалы пользователя #{@user.name}"
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
      	@articles = Article.find_all_by_article_type_id_and_status_id_and_visibility_status_id_and_user_id(@curArtCat[:value], 1, vStatus, @user.id, :order => 'accident_date DESC')
      	  respond_to do |format|
            format.html {render 'articles/index'}# index.html.erb
            format.json { render :json => @articles }
          end
      else
    		redirect_to '/404'
    	end
    end
  # GET /users/1
  # GET /users/1.json
  def show 
    @user = User.find_by_id(params[:id])
	if @user != nil
		#@alter_logo = @user.photo if @user.photo?
		@title = "#{@user.name}"
		respond_to do |format|
		  format.html # show.html.erb
		  format.json { render :json => @user }
		end
	else
		redirect_to '/404'
	end
  end

  # GET /users/new
  # GET /users/new.json
  def new
	if user_type == 'guest'
		@user = User.new
		@action_type = 'new'
		@title = @header = "Регистрация на сайте"
		@add_functions = "userFieldsChecking();"
		respond_to do |format|
		  format.html # new.html.erb
		  format.json { render :json => @user }
		end
	else
		redirect_to '/404'
	end
  end

  # GET /users/1/edit
  def edit
    @user = User.find_by_id(params[:id])
	if userCanEditUserCard?(@user)
		if @user.mailer == nil and params[:tab] == 'notification_upd'
			#send mail_check if @user.make_mailer
		end
		@title = "Изменение данных"
		@action_type = 'edit'
	else
		redirect_to '/404'
	end
  end

  # POST /users
  # POST /users.json
  def create
    if user_type == 'guest'
			params[:user][:user_group_id] = 5
			params[:user][:email_status] = 'Проверка'
			@user = User.new(params[:user])
			@add_functions = "userFieldsChecking();"
			if @user.image_valid?(params[:abi][:value], params[:abi][:name])
				respond_to do |format|
				  if @user.save
					UserMailer.user_check(@user, params[:password]).deliver
					user = User.authenticate(params[:user][:name],
											params[:user][:password])
					sign_in user
					format.html { redirect_to "/welcome", :notice => 'Вы успешно зарегистрировались...' }
					format.json { render :json => @user, :status => :created, :location => @user }
				  else
					format.html { render :action => "new" }
					format.json { render :json => @user.errors, :status => :unprocessable_entity }
				  end
				end
		else
			respond_to do |format|
				format.html {redirect_to :back, :notice => 'Неправильно введён текст изображения', @user => params[:user]}
			end
		end
	else
		redirect_to "/404"
	end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])
	if userCanEditUserCard?(@user)
		my_notice = 'Профиль успешно обновлён'
		case params[:tab]
		when 'email_upd' 
			my_notice = 'E-mail адрес обновлён. На новый адрес отправлено проверочное сообщение.' if UserMailer.mail_check(@user).deliver
			params[:user][:email_status] = 'Проверка'
		when 'password_upd'
			my_notice = 'Пароль обновлён.'
		end
		respond_to do |format|
		  if @user.update_attributes(params[:user])
			format.html { redirect_to @user, :notice => my_notice }
			format.json { head :no_content }
		  else
			format.html { render :action => 'edit' }
			format.json { render :json => @user.errors, :status => :unprocessable_entity }
		  end
		end
	else
		redirect_to '/404'
	end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find_by_id(params[:id])
	if is_super_admin?
		@user.destroy
		respond_to do |format|
		  format.html { redirect_to users_url }
		  format.json { head :no_content }
		end
	else
		redirect_to '/404'
	end
  end
  
  def welcome
	@title = @header = 'Приветствуем в нашей крылатой компании!!!'
	@photo_albums
	@videos
	@articles
	#redirect_to '/404' if user_type != 'new_user'
  end
  
  def thanks
	@title = 'Аккаунт успешно активирован!!!'
  end
  
  def update_mailer
	if user_type != 'guest'
		@mailer = Mailer.find(params[:id])
		if @mailer != nil and (@mailer.user == current_user or user_type == 'super_admin')
			respond_to do |format|
			  if @mailer.update_attributes(params[:mailer])
				format.html { redirect_to edit_user_path(:id => @mailer.user.id, :tab => 'notification_upd'), :notice => 'Список уведомлений успешно обновлён' }
				format.json { head :no_content }
			  end
			end
		else
			redirect_to '/404'
		end
	else
		redirect_to '/404'
	end
  end
  
  def user_check
	user = User.find_by_name_and_salt_and_email(params[:name], params[:value], params[:email])
	if user != nil
		if user.user_group_id == 5
			value = Value.find_by_value_id(user.id)
			user.update_attributes(:user_group_id => 3, :email_status => "Активен", :password => value.value, :password_confirmation => value.value)
			mailer = Mailer.new(
								:user_id => user.id, 
								:album => 'no',  # Уведомление о новых фотоальбомах
								:video => 'no',  # Уведомление о новых видеозаписях
								:message => 'no', # Уведомление о всех новых сообщениях
								:article => 'no', # Уведомление о всех новых статьях
								:photo_comment => 'no', # Уведомление о всех новых комментариях к фото в альбомах пользователя
								:video_comment => 'no', # Уведомление о всех новых комментариях к видео пользователя
								:email => user.email
								)
			mailer.save
			redirect_to edit_user_path(:id => user.id, :tab => 'notification_upd'), :notice => 'Ваш аккаунт успешно подтверждён'
		end
	else
		redirect_to '/404'
	end		
  end
  
  def password_mail_sent
		redirect_to '/404' if signed_in? or (params[:mail] == '' or params[:mail] == nil or params[:mail] == []) 
		@title = 'Восстановление пароля'
  end
  
  def remember_password
	redirect_to '/404' if signed_in?
	@header = @title = 'Восстановление пароля'
  end
  
  def make_mail
	nikname = (params[:user][:name]).strip
	eaddr = (params[:user][:email]).strip
	if (eaddr != '' and nikname != '' and eaddr != nil and nikname != nil)
		user = User.find_by_name_and_email(params[:user][:name], params[:user][:email])#(params[:name], params[:value], params[:created_at])
		if user == nil
			redirect_to '/remember_password', :notice => ("<span class = 'err'>Пользователь с именем</span> <b>#{params[:user][:name]}</b> <span class = 'err'>и почтовым адресом</span> <b>#{params[:user][:email]}</b> <span class = 'err'>не найден</span>").html_safe
		else
			redirect_to "/password_mail_sent?mail=#{user.email}" if UserMailer.mail_remember_password(user).deliver
		end
	else
		redirect_to '/remember_password', :notice => ("<span class = 'err'>Поля</span> 'Ник' <span class = 'err'>и</span> 'Почтовый адрес' <span class = 'err'>должны быть заполнены</span>").html_safe
	end
  end
  
  def mail_switcher
	action = params[:action_type]
	user = User.find_by_salt_and_name_and_email(params[:value], params[:name], params[:email])
	if action != nil and action != '' and user != nil
		current_user = user
		case action
		when 'mail_check'
			user.mailer.update_attributes(:email => user.email)
			redirect_to edit_user_path(:id => user.id, :tab => 'notification_upd'), :notice => "Ваш E-mail: #{user.email} успешно активирован" if user.update_attributes(:email_status => 'Активен')
		when 'remember_password'
			redirect_to edit_user_path(:id => user.id, :tab => 'password_upd', :value_s => user.salt) if sign_in user
		when 'user_check'
			new_user_group = 3 if user.user_group_id == 5
			new_user_group = user.user_group_id if user.user_group_id != 5
			user.update_attributes(:email_status => 'Активен', :user_group_id => 3) #активирует E-mail и переводит пользователя в группу Друг Клуба
			redirect_to edit_user_path(:id => user.id, :tab => 'notification_upd'), :notice => 'Ваш аккаунт успешно подтверждён'
		else
			redirect_to '/404'
		end
	else
		redirect_to root_path #redirect_to '/404'
	end
	
  end
  
  def check_email_and_name
	user = nil
	@status = {:status => 'false'}
	user = User.find_by_email(params[:email]) if params[:email] != nil and params[:email] != ''
	user = User.find_by_name(params[:name]) if params[:name] != nil and params[:name] != ''
	@status = {:status => 'true'} if user != nil
	respond_to do |format|
		format.json { render :json => @status }
	end
  end
  
  def mail_test
	#UserMailer.user_check(current_user).deliver
	#UserMailer.mail_remember_password(current_user).deliver
	#UserMailer.mail_check(current_user).deliver
  end
  
  def steps
	if is_super_admin?
		@user = User.find_by_id(params[:id])
		@steps = Step.find_all_by_user_id(@user.id)
		respond_to do |format|
			format.html { render 'steps/index' }
			format.json { render :json => @steps }
		end
	else
		redirect_to '/404'
	end
  end
end
