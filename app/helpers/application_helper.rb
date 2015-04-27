#13.02.2014 - Добавлена функция my_collection_select(collection, list_name, form_name, base_item, prompt)
#14.02.2014 - Добавлена функция buttons_in_line([{},{}])
#26.03.2014 - select_topic_for_comments(c_id) соответствие категорий контента темам гостевой
#29.07.2014 - добавлена панелька для администратора

module ApplicationHelper
require 'open-uri' #для парсера
require 'iconv' #для парсера
	
	def alter_logo
		logo = "/img/main_page.jpg"
		logo = @alter_logo if @alter_logo != nil
		return "background-image: url(#{logo});background-size: cover;"
	end
	def header_1 #h1 тэг
		("<h1>#{@header}</h1><br />").html_safe if @header != nil 
	end
	def header_2 #h2 тэг
		("<h2>#{@title_2}</h2>").html_safe if @title_2 != nil
	end
	def js_functions 
		return @add_functions.html_safe if @add_functions != nil
	end
	def central_field_style #динамичный стиль для central_field
		style_hash = {:width => '1100px', :min_width => '1100px', :height => '700px'}
		if @cf_style != nil
			style_hash[:width] = @cf_style[:width] if @cf_style[:width] != nil 
			style_hash[:min_width] = @cf_style[:min_width] if @cf_style[:min_width] != nil 
			style_hash[:height] = @cf_style[:height] if @cf_style[:height] != nil 
		end
		return "style = 'width: #{style_hash[:width]}; min-width: #{style_hash[:min_width]}; height: #{style_hash[:height]};'"
	end
	
	def select_topic_for_comments(c_id)
		if c_id != nil
			if c_id == 4 or c_id == 5 #Свободные полёты и Моторные полеты в раздел Парапланеризм
				return 1
			elsif c_id == 2 #Кайтинг в кайтинг
				return 2
			elsif c_id == 1 or c_id == 3 #Клубные мероприятия в клубные мероприятия
				return 4
			elsif c_id == 1 #Разное в беседку
				return 3
			else 
				return 3
			end
		end
	end
	
	def my_title
		if @title != nil and @title != ''
			return @title
		else
			return '"ВЫСОТА"-Самарский Парапланерный Клуб'
		end
	end
	
	def menu_array
	[
					  {
					   :name => 'Главная', 
					   :link => "#{root_path}", 
					   :title => "На главную",
					   :drop_items => 'none'
					  }, #page_name, part_id, page_id, title

					  {
					   :name => 'О клубе', 
					   :link => "/about_us", 
					   :title => "История клуба",
					   :drop_items => 'none'
					  },
					  {
					   :name => 'Новости', 
					   :link => "/events", 
					   :title => "Новости",
					   :drop_items => 'none'
					  },
					  {
					   :name => 'Фото', 
					   :link => "/photo_albums", 
					   :title => "Фотоальбомы",
					   # :links_list => [
										# {:name => 'Свободные полёты', :link => "/photo_albums?category=paragliding"},
										# {:name => 'Моторные полёты', :link => "/photo_albums?category=power_paragliding"},
										# {:name => 'Кайтинг', :link => "/photo_albums?category=kiting"},
										# {:name => 'Клубные мероприятия', :link => "/photo_albums?category=club_events"},
										# {:name => 'Разное', :link => "/photo_albums?category=another"}
									   # ],
						:link_list_width => '170px',
						:id => 'nav_photos',
						:drop_items => 'none'
					  },
					  {
					   :name => 'Видео', 
					   :link => "/videos", 
					   :title => "Видеоматериалы",
					   # :links_list => [
										# {:name => 'Свободные полёты', :link => "/videos?category=paragliding"},
										# {:name => 'Моторные полёты', :link => "/videos?category=power_paragliding"},
										# {:name => 'Кайтинг', :link => "/videos?category=kiting"},
										# {:name => 'Клубные мероприятия', :link => "/videos?category=club_events"},
										# {:name => 'Разное', :link => "/videos?category=another"}
									   # ],
						:link_list_width => '170px',
						:id => 'nav_videos',
						:drop_items => 'none'
					  },
					  {
					   :name => 'Клубная жизнь', 
					   :link => "/visota_life", 
					   :title => "Общение (в прошлом Гостевая)",
					 #  :links_list => topic_link_list,
					   :link_list_width => '170px',
					   :id => 'nav_topics',
					   :drop_items => 'none'
					  },
					  {
					   :name => 'Материалы', 
					   :link => "/articles", 
					   :title => "Отчёты, Отзывы, Документация, полезные ссылки",
					   # :links_list => [
										# {:name => 'Отчёты', :link => '/reports'},
										# {:name => 'Статьи', :link => '/club_articles'},
										# {:name => 'Отзывы', :link => '/reviews'},
										# {:name => 'Отчёты о ЛП', :link => '/flight_accidents'},
										# {:name => 'Восставшие из руин', :link => '/risen_from_the_ruin'},
										# {:name => 'Документы', :link => '/documents'}
									   # ],
						:link_list_width => '170px',
						:id => 'nav_materials',
					    :drop_items => 'none'
					  },
					   {
					   :name => 'Контакты', 
					   :link => "/contacts", 
					   :title => "Контактная информация",
					   :drop_items => 'none'
					  }
					 ]
	end
	def user_session_menu
		if user_type == 'guest'
			b = [
					{:name => 'Вход', :link => '/signin'},
					{:name => 'Регистрация', :link => '/signup'}
				]
		else
			b = [
					{:name => 'Лента событий', :link => '/feed'},
					{:name => 'Профиль', :link => user_path(current_user)},
					{:name => 'Выйти', :link => '/signout'}
				]
		end
		v = ''
		b.each do |i|
			v += (current_page?(i[:link]))? "<li id = 'c_nav_li' style = 'color: white;' link_to = '#{i[:link]}'>#{i[:name]}</li>":"<li link_to = '#{i[:link]}'>#{i[:name]}</li>"
		end
		return "<ul>#{v}</ul>"
	end
	def put_link_type #формирование меню сайта
		value = ""
		menu_array.each do |item|
			value += "<li id = '#{is_selected(item)}'><a href = '#{item[:link]}'><span>#{item[:name]}</span></a>#{ '&#9662;' if item[:drop_items] != 'none' and item[:drop_items] != nil}#{menu_drop_list(item)}</li>"
		end
		
		return "<ul>#{value}</ul>"
	end
	
	def is_selected(item)
		if menu_array.index(item) != 0
			if @curMenuItem == item[:name] || current_page?(item[:link])
				return 'c_nav_li' 
			end
		end

	end
	
	def nav_menu #основное меню сайта
				"
					#{put_link_type}
				"
	end
	
	def menu_drop_list(item) #Формирует выпадающие списки основного меню.
		value = ''
		if item[:links_list] != nil and item[:links_list] != []
			item[:links_list].each do |sub_item|
				value += "<a style = 'text-decoration: none;' href = '#{sub_item[:link]}'><li style = 'display: block; font-size: 12pt;' class = 's_nav_li'>#{sub_item[:name]}</li></a>"
			end
			
		end
		return "<div style = 'display: none; width: #{item[:link_list_width]};' class = 'menu_drop_list'><ul>#{value}</ul></div>"
	end
#slider
	def topSlider
		"
						<div class='slider'>
						<ul>
							<li><img src='/sliderImages/1.jpg' alt=''></li>
							<li><img src='/sliderImages/2.jpg' alt=''></li>
							<li><img src='/sliderImages/3.jpg' alt=''></li>
						</ul>
						</div>"
	end
	
#slider end
	def topic_link_list #Формирует массив для формирования выпадающего списка.
		val_arr = []
		topics = Topic.all(:order => 'name ASC')
		topics.each do |topic|
			val_arr[val_arr.length] = {:name => topic.name, :link => topic_path(topic)}
		end
		val_arr[val_arr.length] = {:name => 'Старая гостевая', :link => '/old_messages'}
		return val_arr
	end
	
	def wheather_panel
	"
		<div id = 'wheather_panel' class = 'wheather_panel'>
			<div  id = 'wheather_button' align = 'center'  class = 'wheather_link'>
				<b><a style = 'position: relative;'><img src = '/files/wheather.png' style = 'height: 80px; padding-top: 5px;'></a></b>
			</div>
			<div id = 'wheather' style = 'display: block;' class = 'wheather_content'>
					<div id = 'wheather_blocks' style = 'text-align: center; height: 100%; margin-left: 10px; padding-right: 5px; display: none; position: relative;'>
							<br />
							<a class = 'b_link' target = '_blank' href = 'http://rp5.ru/7259/ru'><b>Самара</b></a>
							<br />
							<EMBED src='http://rp5.ru/informer/100x100/1/17.swf' loop=false menu=false quality=high scale=noscale wmode=transparent bgcolor=#CCCCCC flashvars='id=7259&lang=ru&um=00000' WIDTH='100' HEIGHT='100' NAME='loader' ALIGN='' TYPE='application/x-shockwave-flash' PLUGINSPAGE= 'http://www.macromedia.com/go/getflashplayer'></EMBED>
					</div>
					<div id = 'wheather_blocks' style = 'text-align: center; height: 100%; display: none; position: relative; padding-right: 5px;'>
							<br />
							<a class = 'b_link' target = '_blank'  href = 'http://rp5.ru/123798/ru'><b>Б. Раковка</b></a><br />
							<br />
							<EMBED src='http://rp5.ru/informer/100x100/1/17.swf' loop=false menu=false quality=high scale=noscale wmode=transparent bgcolor=#CCCCCC flashvars='id=123798&lang=ru&um=00000' WIDTH='100' HEIGHT='100' NAME='loader' ALIGN='' TYPE='application/x-shockwave-flash' PLUGINSPAGE= 'http://www.macromedia.com/go/getflashplayer'></EMBED>
					</div>
					<div id = 'wheather_blocks' style = 'text-align: center; height: 100%; display: none; position: relative; padding-right: 5px;'>
						<a href='http://6.pogoda.by/28807' title='Прогноз атмосферного давления,скорости и направления ветра по данным UKMET. Самара' target='_blank'>
						<img src='http://pogoda.by/mg/366/egrr_W28807.gif' width='366' height='100' border='1' alt='График элементов погоды P, Ws, Wa г. Самара прогноз на 126 ч.'></a>
					</div>
					<div id = 'wheather_blocks' style = 'height: 100%; display: none; position: relative; width: 140px; '>
							<a class = 'b_link' target = '_blank' href = 'http://meteo.paraplan.net/forecast/summary.html?place=4954'><b>Подробный прогноз по Самаре</b></a> <hr />
							<a class = 'b_link' target = '_blank' href = 'http://meteoinfo.by/radar/?q=RUSM&t=10'><b>Радиолокационная карта метеоявлений</b></a><br><br>
					</div>
			</div>
		</div>
	"
	end
	def my_collection_select(collection, list_name, form_name, base_item, prompt) #структура collection [{:value => integer, :name => string}]
		if collection != {} and collection != nil and list_name != nil and list_name != '' and form_name != nil and form_name != ''
			options = ""
			options += "<option value = ''>#{prompt}</option>" if prompt != ''
			options += "<option value = '#{base_item[:value]}'>#{base_item[:name]}</option>" if base_item != {}
			collection.each do |item|
				options += "<option value = '#{item[:value]}'>#{item[:name]}</option>" if item != base_item
			end
			return ("<select class = 'c_select' id = '#{form_name}_#{list_name}' name = '#{form_name}[#{list_name}]'>#{options}</select>").html_safe
		else
			return ("<select class = 'c_select'><option>Пусто</option></select>").html_safe
		end
	end
#Блок отрисовки кнопок----------------------------------------------------------
def buttons_in_line(buttons) #buttons => {:name => 'Перейти', :title => "Перейти на страницу пилота", :access => ['all'], :type => 'b_green', :link => user_path(user)}
	value = ""
	if @active_button != nil
		buttons[@active_button][:selected]
	end
	if buttons != nil and buttons != []
		buttons.each do |button|
			if button[:access] == true
				button[:type] = 'c_loc_li' if button[:selected] == true
				value += "<a #{button_attrs(button)}><li id = '#{button[:type]}'>#{button[:name]}</li></a>"
			end
		end
		value = "<div class = 'l_menu'><ul>#{value}</ul></div>"
	end
	return value
end

def button_attrs(button)
	val = ''
	val += "href = '#{button[:link]}'" if button[:link] != '' and button[:link] != nil
	val += "data-confirm = '#{button[:data_confirm]}'" if button[:data_confirm] != '' and button[:data_confirm] != nil
	val += "data-method = '#{button[:data_method]}'" if button[:data_method] != '' and button[:data_method] != nil
	val += "rel = '#{button[:rel]}'" if button[:rel] != '' and button[:rel] != nil
	val += "onclick = '#{button[:onclick]}'" if button[:onclick] != '' and button[:onclick] != nil
	val += "id = '#{button[:id]}'" if button[:id] != '' and button[:id] != nil
	val += "title = '#{button[:title]}'" if button[:title] != '' and button[:title] != nil
	val += "name = '#{button[:e_name]}'" if button[:e_name] != '' and button[:e_name] != nil
	val += "alt = '#{button[:alt]}'" if button[:alt] != '' and button[:alt] != nil
	val += "data-remote = '#{button[:remote]}'" if button[:remote] != '' and button[:remote] != nil
	return val
end

def control_buttons(buttons)
	value = ""
	if buttons != nil and buttons != []
		buttons.each do |button|
			if button[:access] == true
				button[:type] = 'c_loc_li' if button[:selected] == true
				value += "<a #{button_attrs(button)}><li>"
				value += "<img src = '/files/#{button[:type]}_b.png' style = 'float: left;' height = '20px' />" if button[:type] != nil and button[:type] != ''
				value += "#{button[:name]}</li></a>"
			end
		end
		value = "<div id = 'cButWrapper' ><ul class = 'ctrl_but'>#{value}</ul></div>" if value != ""
	end
	return value
end

#my_search engine


def themes_search(p)
	themeParams = p[:th]
	themes = []
	if themeParams != nil and themeParams != []
	else
		return themes
	end
end
def isLikebleText?(dwnCaseText, qText)
	i = 0
	p = 0.0
	arr = dwnCaseText.mb_chars.split(/\s/)
	arr_2 = qText.mb_chars.split(/\s/)
	if arr.length > 0
		arr.each do |s|
			arr_2.each do |qS|
				i+= 1 if s.mb_chars.index(qS) != -1 and s.mb_chars.index(qS) != nil and qS.mb_chars.length > 3 #ищем в тексте совпадения
			end
		end
	end
	p = (i.to_f)/(arr_2.length.to_f)*100 #определяем процент совпадений
	return true if p > 30
	return false
	#todo
end
#my_search engine end
# def button_accessed?(access_list)
	# enable = false
	# if user_type != 'guest'
		# enable = true if access_list.index(user_type) != nil || access_list.index(current_user.id) != nil || access_list[0] == 'all'
	# else
		# enable = true if access_list[0] == 'all' || access_list.index(user_type) != nil
	# end
	
	# return enable
# end


#Блок отрисовки кнопок end------------------------------------------------------

	def my_time(date)
		time = Time.now
		value = ''
		if time.year == date.year and time.month == date.month
			days_difference = time.day - date.day
			if days_difference == 0
				value = date.strftime("Сегодня в %H:%M")
			elsif days_difference == 1 
				value = date.strftime("Вчера в %H:%M")
			elsif days_difference == -1 
				value = date.strftime("Завтра в %H:%M")
			elsif days_difference < -1 
				value = "#{date.strftime("%d #{ru_month(date.month.to_i, 'rod_padej')}")}"
			elsif days_difference > 1 
				value = "#{date.strftime("%d #{ru_month(date.month.to_i, 'rod_padej')}")}"
			end
		elsif time.year == date.year and time.month != date.month
			value = "#{date.strftime("%d #{ru_month(date.month.to_i, 'rod_padej')}")}"
		elsif time.year != date.year
			value = "#{date.strftime("%d.%m.%Y")}"
		end
		return value
	end
	
	def ru_month(m, type) #type == partial or full or родительный падеж
		value = ''
		month_array = [
						[1, 'Январь', 'Янв.', 'Января'],
						[2, 'Февраль', 'Фев.', 'Февраля'],
						[3, 'Март', 'Мар.', 'Марта'],
						[4, 'Апрель', 'Апр.', 'Апреля'],
						[5, 'Май', 'Май', 'Мая'],
						[6, 'Июнь', 'Июн.', 'Июня'],
						[7, 'Июль', 'Июл.', 'Июля'],
						[8, 'Август', 'Авг.', 'Августа'],
						[9, 'Сентябрь', 'Сент.', 'Сентября'],
						[10, 'Октябрь', 'Окт.', 'Октября'],
						[11, 'Ноябрь', 'Ноя.', 'Ноября'],
						[12, 'Декабрь', 'Дек.', 'Декабря']
					  ]
		month_array.each do |month|
			value = month[1] if month[0] == m and type == 'full'
			value = month[2] if month[0] == m and type == 'partial'
			value = month[3] if month[0] == m and type == 'rod_padej'
		end
	return value
  end
  
  	
  #smiles_part
  def smiles_draw
	smiles_count = 34
	onclick = 'presssmile(this)'
	smiles_path = '/smiles/'
	value = ''
	i = 0
	begin
		i += 1
		value += "<img class = 'smiles' src='#{smiles_path}#{i}.gif' title='' smilecode ='*sm#{i}*' onclick='#{onclick}'>"
	end until(i == smiles_count)
	return ("<div class = 'smiles_field'>#{value}</div>").html_safe
  end
  #smiles_part end
  
  
  def hidden_object_count
	themes = Theme.find_all_by_status_id(2)
	messages = Message.find_all_by_status_id(2)
	photos = Photo.find_all_by_status_id(2)
	return themes.count + messages.count + photos.count
  end
  
  def deleted_object_count
	themes = Theme.find_all_by_status_id(3)
	messages = Message.find_all_by_status_id(3)
	photos = Photo.find_all_by_status_id(3)
	return themes.count + messages.count + photos.count
  end
  def disabled_events_count
	events = Event.find_all_by_status_id(1)
	return events.count.to_s
  end
	
	def random_photos(count)
		value = ''
		new_arr = @photos.shuffle!
		photos = Photo.find_all_by_id((new_arr[0..count-1]))
		photos.each do |photo|
			max_name_length =  30 - photo.parent[:parent_type].length - 2
			
			value += "<div class = 'photo_thumbs' style = 'background-image: url(#{photo.link.thumb});'>
					  		<div style = 'position: absolute; height: 50px; bottom: 0; width: 100%;'>
							<div style = 'bottom: 0; width: 100%; height: 100%; background-color: black; opacity: 0.7; position: absolute; '>
							</div>
							<div style = 'position: absolute; left: 5px; bottom: 10px; color: white; font-weight: bolder; font-size: 12px; z-index: 150;'>#{photo.parent[:parent_type] + ': ' +  link_to(truncate(photo.parent[:parent_name], :length => max_name_length), photo.parent[:parent_link], :class => 'black_bg_link') if photo.parent[:parent_name] != ''}<br />#{ 'Разместил: ' + link_to(truncate(photo.user.name, :length => 20), photo.user, :class => 'black_bg_link', :title => 'Перейти к профилю') if photo.user != nil}</div>
							</div>
					  </div>"
		end
		return value
	end
#Основные блоки
	# def main_entity_block(p)
		# ("
		
		# ")
	# end
	def c_box_block(p) #p = {:tContent => '', :fContent =>'', :classLvl_1 => '', :idLvl_1 => '', :classLvl_2 => '', :idLvl_2 => '', :classBg => '', :parity => integer}
		parity = '' 
		if p[:parity] != nil
			parity = ' odd' if p[:parity].odd?
			parity = ' even' if p[:parity].even?
		end
		val = ""
		tContent = ""
		fContent = ""
		bg = ""
		tContent = "<div class = 'central_field#{" "+p[:classLvl_2] if p[:classLvl_2] != nil}'#{" id='#{p[:idLvl_2]}'" if p[:idLvl_2] != nil}>#{p[:tContent]}</div>" if p[:tContent] != nil
		fContent = p[:fContent] if p[:fContent] != nil
		bg = "<div class='#{p[:classBg]}'></div>" if p[:classBg] != nil
		val = "
				<div class = 'c_box#{" "+p[:classLvl_1] if p[:classLvl_1] != nil}#{parity}'#{" id='#{p[:idLvl_1]}'" if p[:idLvl_1] != nil}>
					#{bg}#{tContent}#{fContent}					
				</div>
			  "
		return val
	end
	def list_attachments(attachment_files) #вложенные файлы
		value = ''
		if attachment_files != [] and attachment_files != nil
			value = '<div class = "g_field"><div class = "central_field" style = "width: 98%;"><b>Вложения:</b> <br /><table style = "width: 600px;">'
			attachment_files.each do |file|
				value += "<tr><td align = 'left' style = 'min-width: 25px;'><a class = 'b_link' href = '#{file.link}'>#{file.name}</a></td><td align = 'left'>Размер: #{file.alter_size}</td></tr> "
				value += "</table></div></div>" if file == attachment_files.last
			end
		end
		return value
  end
  def navigation_string #Навигационная строка 
	value = ''
	@path_array.each do |path|
		value += " <span id = 'splitter'>&raquo;</span> " if @path_array.first != path
		value += "#{link_to truncate(path[:name], :length => 50), path[:link], :title => path[:name], :class => 'b_link', :id => 'first'}" if @path_array.first == path
		value += "#{link_to truncate(path[:name], :length => 50), path[:link], :title => path[:name], :class => 'b_link'}" if path != @path_array.last and @path_array.first != path
		value += "<span id = 'cur_path'>#{truncate(path[:name], :length => 50)}</span>" if path == @path_array.last
	end
	return "<div class = 'nav_string'>#{value}</div>"
  end
#Основные блоки	end

#Моя погода------------------------------------------------------------------------------------------------------------------------------------------------------------
def myWheatherPanel
text = get_html('http://meteo.paraplan.net/forecast/summary.html?place=4954', 'false')
val = tag_keeper(text, 'table', 'id', 'forecast')[0][:tag_body]
return val
end
#Parser----------------------------------------------------------------------------------------------------------------------------------------------------------------


# link = 
	def capture_html(type, captured_link)
			directory = "public/raw_html/#{type}"
			time = (Time.now).to_s
			FileUtils.mkdir_p(directory) unless File.exists?(directory)
				File.open(Rails.root.join(directory, time), 'w') do |file|
					file.write find_body(open("#{captured_link}").read)
				end
			link = "/raw_html/#{type}/#{time}"
			page = HtmlPage.new(:link => link, :page_type => type)
			page.save
	end
	
	def get_html(link, convert)
		if convert == 'true'
			converter = Iconv.new('utf-8', 'windows-1251')
			result = converter.iconv(find_body(open("#{link}").read))
		elsif convert == 'false'
			result = find_body(open("#{link}").read)
		end
		return result
	end

	def pages_list
		content = ""
		if @html_pages != []
			@html_pages.each do |p|
				content += "#{p.link} <br />"
			end
		else
			content = "Нет ни одной страницы"
		end
		return content.html_safe	
	end
	
	def find_body(page)
		text_with_body = ''
		if page != ''
		body_start_tag = page.index('<body')
		body_end_tag = page.rindex('</body>')
		text_with_body = page[body_start_tag..(body_end_tag + 6)]
		end
		return text_with_body
	end
#Поиск тэгов в тексте	
	def tag_keeper(text, tag_name, param_name, value) #текст для анализа, имя тэга, имя параметра-критерия, значение параметра, выходные данные
		choosed_tags = []
		tags = []
		tags = group_tag_by_pairs(text, tag_name) if text != nil and text != '' and tag_name != nil and tag_name != '' and tag_name != 'img'
		tags = tag_ordering(text, tag_name) if tag_name == 'img' 
		if tags != [] and param_name != nil and value != nil and param_name != '' and value != '' 
			choosed_tags = get_tag(param_name, value, tags) 
			if choosed_tags != []
				return choosed_tags
			end
		else
			return tags
		end
	end
	
	def tag_ordering(text, tag_name) #Создает массив тэгов 
		tags_array = []
		first_tag = get_next_tag(text, tag_name, 0)
		
		if first_tag != {}
			i = 0
			tags_array[i] = first_tag
			next_index = first_tag[:end_index]
			begin 
				i += 1
				next_tag = get_next_tag(text, tag_name, next_index + 1)
				if next_tag != {} and next_tag != nil
					tags_array[i] = next_tag
					next_index = next_tag[:end_index]
				end
			end until(next_tag == {})
		end
		return tags_array
	end
	
	def get_next_tag(text, tag_name, next_index) #Ищет следующий тэг в тексте
		tag = {}
		open_start_tag = nil
		close_start_tag = nil
		end_tag = nil
		 if (text[next_index..text.length - 1]).include?("<#{tag_name}")
			open_start_tag = next_index + (text[next_index..(text.length - 1)]).index("<#{tag_name}") 
			close_start_tag = open_start_tag + (text[open_start_tag..text.length].index(">")) 
		 end
		end_tag = next_index + (text[next_index..(text.length)]).index("</#{tag_name}>") if (text[next_index..text.length]).include?("</#{tag_name}>")
		
		if open_start_tag != nil and end_tag != nil
			if open_start_tag < end_tag
				end_symbol_index = 
				tag = {
						:tag_type => 'open',
						:start_index => open_start_tag,
						:end_index => close_start_tag,
						:tag_content => text[open_start_tag..close_start_tag]
					  }
			elsif open_start_tag > end_tag
				tag = {
						:tag_type => 'close', 
						:start_index => end_tag,
						:end_index => end_tag + (tag_name.length + 1),
						:tag_content => text[end_tag..(end_tag + (tag_name.length + 2))]
					  }
			end
		elsif open_start_tag == nil and end_tag != nil
				tag = {
						:tag_type => 'close', 
						:start_index => end_tag,
						:end_index => end_tag + (tag_name.length + 1),
						:tag_content => text[end_tag..(end_tag + (tag_name.length + 2))]
					  }
		elsif open_start_tag == nil and end_tag == nil
			tag = {}
		end
		
		return tag
	end
	
	def group_tag_by_pairs(text, tag_name) #Находит тела тэгов
		array = tag_ordering(text, tag_name)
		new_array = []
		tag_element = {}
		i = -1
			begin
				j = -1
				flag = 0
				begin
					j += 1
					if array[j + 1] != nil and array[j + 1] != [] and array[j + 1] != '' 
						next_tag_type = array[j + 1][:tag_type]
						current_tag_type = array[j][:tag_type]
						if current_tag_type == 'open' and next_tag_type == 'close'
							flag = 1
							current_tag = array[j]
							next_tag = array[j + 1]
							tag_params = text[(array[j][:start_index] + tag_name.length + 1)..(array[j][:end_index] - 1)]
							tag_content = text[((array[j][:end_index]) + 1)..((array[j + 1][:start_index]) - 1)]
							tag_body = text[(array[j][:start_index])..(array[j + 1][:end_index])]
							tag_element = {
											:tag_params => tag_params,
											:tag_content => tag_content, 
											:tag_body => tag_body,
											:tag_name => tag_name
										  }
							i += 1
							new_array[i] = tag_element
							array.delete(current_tag)
							array.delete(next_tag)
						end
					else 
						flag = 1
						array = []
					end
				end until(flag == 1)
			end until(array == [] or array.size == 1)
		return new_array
	end
	
	def get_tag(param_name, value, tags) #поиск тэгов соответствующих входным параметрам
		i = -1
		tags_array = []
		if param_name != nil
			tags.each do |tag|
				tag_params_text = tag[:tag_params]
				if tag_params_text.include?("#{param_name}")
					text_for_find = change_symbol(remove_spaces(tag_params_text), "'", '"')
					if text_for_find != ''
						if text_for_find.index(param_name + '="' + value + '"') != nil
							i += 1
							tags_array[i] = tag
						end
					end
				end
			end
		else
			tags_array = tags
		end
		return tags_array
	end
# end
#Извлечение параметров	
	def get_tag_parameters(tag, parameter)
		value = ""
		if tag[:tag_params] != nil
			if parameter == 'content'
				value = tag[:tag_content]
			else
				text = remove_spaces(tag[:tag_params])
				text.gsub(/#{parameter}\s?=\s?"((\w|\d|\s|,|;|'|\/|\.|\_|\-|:)+)"/){value += $1}
				#start_index = text.index("#{parameter}='") + parameter.size + 2
				# if start_index != nil
					# i = 0
					# text.from(start_index).chars do |ch|
						# if ch != "'"
							# value += ch
						# elsif ch == "'"
							# break
						# end
					# end
				# end
			end
		end
		return value
	end
	
	def determine_params(tag, param_name_list)
		text = remove_spaces(param_name_list)
		params_list = {}
		word = ''
		if text != ''
			i = 0
			j = -1
			text.chars do |ch|
				i += 1
				if ch != ';' and ch != ',' and i != text.size
					word += ch					
				else
					j += 1
					word += ch if i == text.size and ch != ';' and ch != ','
					param_name = word
					params_list[word.to_sym] = get_tag_parameters(tag, param_name)
					word = ''
				end
			end
			
		end
		return params_list
	end
	
	def remove_spaces(text)
		new_text = ""
		text.chars do |ch|
			if ch != " "
				new_text += ch
			end
		end
		return new_text
	end
	def remove_quotes(text)
		new_text = ""
		text.chars do |ch|
			if ch != "(" and ch != ")"
				new_text += ch
			end
		end
		return new_text
	end
	def change_symbol(text, old_symbol, new_symbol)
		new_text = ''
		text.chars do |ch|
			if ch == old_symbol
				new_text += new_symbol
			else
				new_text += ch
			end
		end
		return new_text
	end
	
	def tag_class(tag)
		value = ''
		value = determine_params(tag, 'class')[:class] if determine_params(tag, 'class')[:class] != ''
		return value
	end
#end	
	def get_parent_tag(link, tag_name, input_parameter, value) #выбор родительского тэга по ссылке
		text = get_html(link, 'true') #or true
		tags = tag_keeper(text, tag_name, input_parameter, value)
		parent_content = ''
		if tags != [] and tags != nil
			tags.each do |tag|
				parent_content += tag[:tag_content]
			end
		end
		return parent_content
	end
	
	def get_parent_tag_from_text(text, tag_name, input_parameter, value) #выбор родительского тэга из текста
		tags = tag_keeper(text, tag_name, input_parameter, value)
		parent_content = ''
		if tags != [] and tags != nil
			tags.each do |tag|
				parent_content += tag[:tag_content]
			end
		end
		return parent_content
	end
	
	def tags_array_test
		text = "<td id = 'first_class' class = 'layer'>1 2 3 4 5 6 7 8 9 0</td><td id = 'first_class' class = 'layer'>Раз, два, три, четыре</td><td>123456</td><span>Fuck</span>"
		tag_name = "td"
		tag = get_next_tag(text, tag_name, 141)#tag = get_html('http://www.lada.ru/cgi-bin/models.pl') #determine_params('div', text)# tag = get_parent_tag('http://catalog.drom.ru/')# tag = # 
		tag = "Пусто" if tag == nil or tag == nil or tag == ''
		return tag
	end
	
	# def get_image(text, param_name, value)
		# images = tag_keeper(text, 'img', param_name, value)
		# links = []
		# if images != nil
			# images.each do |tag|
				# links[links.length] = get_tag_parameters(tag, 'href')
			# end
		# end
		# return links
	# end
#Parser---end-------------------------------------------------------------------------------------------------------------------------------------------------------

end
