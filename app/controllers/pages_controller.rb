class PagesController < ApplicationController
include PagesHelper
#include EventsHelper
#include PhotoAlbumsHelper
#include VideosHelper

  def index
	@title = "Главная"
	@topSlider = true
	@add_functions = "myParalaxes();"
	@events = Event.find_all_by_display_area_id(([1, 3]), :order => 'post_date DESC', :limit => 5)
	@albums = PhotoAlbum.find_all_by_status_id(1, :order => 'created_at DESC', :limit => 5)
	@videos = Video.all(:order => 'created_at DESC', :limit => 3)
  end

  def school
	@title = "Обучение"
  end

  def equipment
	@title = 'Снаряжение'
  end
	
  def contacts
	@title = "Контакты"
  end

  def about_us
	@title = "О клубе"
  end
  
  def styles
	@title = "Стили"
  end
  
  def new_template
	render :layout => 'new_layout' 
  end 
  
  def feed
	if user_type != 'guest'
		@title = "Лента событий"
		@title_2 = feed_part_name
		@entity_array = feed_blocks
		@photos = Photo.select(:id)
		@events = Event.find_all_by_display_area_id(([2, 3]), :order => 'post_date DESC', :limit => 3)
		if current_feed_part[:en_name] == 'answers'
			@entity_on_page = 15
		elsif current_feed_part[:en_name] == 'themes' # or current_feed_part[:en_name] == 'comments'
			@entity_on_page = 15
		elsif current_feed_part[:en_name] == 'albums'
			@entity_on_page = 10
		elsif current_feed_part[:en_name] == 'videos'
			@entity_on_page = 10
		elsif current_feed_part[:en_name] == 'articles' 
			@entity_on_page = 5
		elsif current_feed_part[:en_name] == 'comments' 
			@entity_on_page = 10
		end
	else
		redirect_to '/404'
	end
  end
  
  def search
	visota_search("Нет ничего лучше борща с грибами, Shit'a Fuck'a", 'all')
  end
end
