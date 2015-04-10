class Step < ActiveRecord::Base
  attr_accessible :entity_id, :host_name, :ip_addr, :page_id, :part_id, :user_id, :visit_time
  belongs_to :user
  @page_params = {:part_id => 0, :page_id => 0, :entity_id => 0} if @page_params == nil
		if @page_params[:part_id] == 0 #pages
		elsif @page_params[:part_id] == 1 #topics
			make_signed_step
		elsif @page_params[:part_id] == 2 #users
		elsif @page_params[:part_id] == 3 #photo_albums
			make_step
		elsif @page_params[:part_id] == 4 #photos (внести изменения в контроллер)
			make_step
		elsif @page_params[:part_id] == 5 #videos
			make_step
		elsif @page_params[:part_id] == 6 #messages
		elsif @page_params[:part_id] == 7 #articles
			make_step
		elsif @page_params[:part_id] == 8 #events
		elsif @page_params[:part_id] == 9 #themes
			make_signed_step
		end
  
  def part_names 
	[
		{:id => 0, :name => 'Без имени'}, 
		{:id => 1, :name => 'Топик'}, 
		{:id => 2, :name => 'Страница пользователя'}, 
		{:id => 3, :name => 'Фотоальбом'}, 
		{:id => 4, :name => 'Фотографии'},
		{:id => 5, :name => 'Видеозаписи'},
		{:id => 6, :name => 'Сообщения'},
		{:id => 7, :name => 'Материалы'},
		{:id => 8, :name => 'Новости'},
		{:id => 9, :name => 'Темы'}
	]
  end
  def part_name
	part_names.each do |p|
		return p[:name] if p[:id] == self.part_id 
	end
	return 'Без имени'
  end
  def entity_name
	entity = {:name => 'Без имени', :link => nil}
	if entity_id != nil
		if part_id == 1
			topic = Topic.find_by_id(entity_id)
			entity = {:name => topic.name, :link => "/topics/#{topic.id}"} if topic != nil
		elsif part_id == 2
			user = User.find_by_id(entity_id)
			entity = {:name => user.name, :link => "/users/#{user.id}"} if user != nil
		elsif part_id == 3
			album = PhotoAlbum.find_by_id(entity_id)
			entity = {:name => album.name, :link => "/photo_albums/#{album.id}"} if album != nil
		elsif part_id == 4
			photo = Photo.find_by_id(entity_id)
			entity = {:name => "Перейти", :link => "/photos/#{photo.id}"} if photo != nil
		elsif part_id == 5
			video = Video.find_by_id(entity_id)
			entity = {:name => video.alter_name, :link => "/videos/#{video.id}"} if video != nil
		elsif part_id == 6
			message = Message.find_by_id(entity_id)
			entity = {:name => "Перейти", :link => "/messages/#{message.id}"} if message != nil
		elsif part_id == 7
			article = Article.find_by_id(entity_id)
			entity = {:name => article.alter_name, :link => "/articles/#{article.id}"} if article != nil
		elsif part_id == 8
			event = Event.find_by_id(entity_id)
			entity = {:name => event.title, :link => "/events/#{event.id}"} if event != nil
		elsif part_id == 9
			theme = Theme.find_by_id(entity_id)
			entity = {:name => theme.name, :link => "/themes/#{theme.id}"} if theme != nil
		end
	end
	return entity
  end
end
