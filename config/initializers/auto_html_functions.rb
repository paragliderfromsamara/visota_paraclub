AutoHtml.add_filter(:vk_video).with(:width => 640, :height => 480, :span => false) do |text, options|
	regex = /<iframe\s+src="(http:\/\/vk\.com\/video_ext\.php)\?oid=(\d+)&id=(\d+)&hash=(.+)(&hd=(\d{1}))?"\s+width="(\d{1,3})"\s+height="(\d{1,3})"\s+frameborder="(\d{1})"(.+)?><\/iframe>/
	text.gsub(regex) do
		url = "#{$1}?"
		url += "oid=#{$2}" if $2 != nil or $2 != ''
		url += "&id=#{$3}" if $3 != nil or $3 != ''
		url += "&hash=#{$4}" if $4 != nil or $4 != ''
		url += "&hd=#{$6}" if $6 != nil or $6 != ''
		width = options[:width]
		height = options[:height]
		span = options[:span]
		# width = $7 if $7 != nil or $7 != ''
		# height = $8 if $8 != nil or $8 != ''
		if span == true
			%{<br /><div id = 'video' class = 'central_field' style = 'width: #{width}px;'><iframe src = '#{url}' width = '#{width}' height = '#{height}' frameborder='0'></iframe></div><br />}
		else
			%{<iframe src = '#{url}' width = '#{width}' height = '#{height}' frameborder='0'></iframe>}
		end

	end
end
AutoHtml.add_filter(:vk_video_msg).with(:width => 640, :height => 480, :span => false) do |text, options|
	regex = /&lt;iframe\s+src=&quot;(http:\/\/vk\.com\/video_ext\.php)\?oid=(\d+)&amp;id=(\d+)&amp;hash=(.+)(&amp;hd=(\d{1}))?&quot;\s+width=&quot;(\d{1,3})&quot;\s+height=&quot;(\d{1,3})&quot;\s+frameborder=&quot;(\d{1})&quot;(.+)?&gt;&lt;\/iframe&gt;/
	text.gsub(regex) do
		url = "#{$1}?"
		url += "oid=#{$2}" if $2 != nil or $2 != ''
		url += "&id=#{$3}" if $3 != nil or $3 != ''
		url += "&hash=#{$4}" if $4 != nil or $4 != ''
		url += "&hd=#{$6}" if $6 != nil or $6 != ''
		width = options[:width]
		height = options[:height]
		span = options[:span]
		# width = $7 if $7 != nil or $7 != ''
		# height = $8 if $8 != nil or $8 != ''
		if span == true
			%{<br /><div id = 'video' class = 'central_field' style = 'width: #{width}px;'><iframe src = '#{url}' width = '#{width}' height = '#{height}' frameborder='0'></iframe></div><br />}
		else
			%{<iframe src = '#{url}' width = '#{width}' height = '#{height}' frameborder='0'></iframe>}
		end

	end
end
AutoHtml.add_filter(:img).with(:height => 240) do |text, options|
	regex = /\[img\](https?:\/\/.+?\.(jpg|jpeg|bmp|gif|png)(\?\S+)?)\[\/img\]/i
	text.gsub(regex) do
		url = "#{$1}?"
		# width = options[:width]
		height = options[:height]
		%{<a href = '#{url}' ><img src = '#{url}' style = 'display: inline-block; height: '#{height}px;'></a>}
	end
end
AutoHtml.add_filter(:smiles) do |text|
	regex = /\*sm(\d+)\*/
	text.gsub(regex) do |match|
		url = "#{$1}?"
		"<img src = '/smiles/#{$1}.gif'>"
	end
end
AutoHtml.add_filter(:my_youtube_msg).with(:width => 640, :height => 480, :frameborder => 0, :wmode => nil, :autoplay => false, :hide_related => false, :span => false) do |text, options|
  regex = /https?:\/\/(www.)?(youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/watch\?feature=(player_detailpage|player_embedded)&amp;v=)([A-Za-z0-9_-]*)(\&\S+)?(\?\S+)?/
  text.gsub(regex) do
    youtube_id = $4
    width = options[:width]
    height = options[:height]
    frameborder = options[:frameborder]
		wmode = options[:wmode]
    autoplay = options[:autoplay]
    hide_related = options[:hide_related]
		src = "//www.youtube.com/embed/#{youtube_id}"
    params = []
		params << "wmode=#{wmode}" if wmode
    params << "autoplay=1" if autoplay
    params << "rel=0" if hide_related
	span = options[:span]
    src += "?#{params.join '&'}" unless params.empty?
	if span == true
		%{<br /><div id = 'video' class = 'central_field' style = 'width: #{width}px;'><iframe width="#{width}" height="#{height}" src="#{src}" frameborder="#{frameborder}" allowfullscreen></iframe></div><br />}
	else
		%{<iframe width="#{width}" height="#{height}" src="#{src}" frameborder="#{frameborder}" allowfullscreen></iframe>}
	end
  end
end
AutoHtml.add_filter(:my_youtube).with(:width => 640, :height => 480, :frameborder => 0, :wmode => nil, :autoplay => false, :hide_related => false, :span => false) do |text, options|
  regex = /https?:\/\/(www.)?(youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/watch\?feature=(player_detailpage|player_embedded)&v=)([A-Za-z0-9_-]*)(\&\S+)?(\?\S+)?/
  text.gsub(regex) do
    youtube_id = $4
    width = options[:width]
    height = options[:height]
    frameborder = options[:frameborder]
		wmode = options[:wmode]
    autoplay = options[:autoplay]
    hide_related = options[:hide_related]
		src = "//www.youtube.com/embed/#{youtube_id}"
    params = []
		params << "wmode=#{wmode}" if wmode
    params << "autoplay=1" if autoplay
    params << "rel=0" if hide_related
	span = options[:span]
    src += "?#{params.join '&'}" unless params.empty?
	if span == true
		%{<br /><div id = 'video' class = 'central_field' style = 'width: #{width}px;'><iframe width="#{width}" height="#{height}" src="#{src}" frameborder="#{frameborder}" allowfullscreen></iframe></div><br />}
	else
		%{<iframe width="#{width}" height="#{height}" src="#{src}" frameborder="#{frameborder}" allowfullscreen></iframe>}
	end
  end
end

AutoHtml.add_filter(:my_vimeo).with(:width => 640, :height => 480, :show_title => false, :show_byline => false, :show_portrait => false, :span => false) do |text, options|
  text.gsub(/https?:\/\/(www.)?vimeo\.com\/([A-Za-z0-9._%-]*)((\?|#)\S+)?/) do
    vimeo_id = $2
    width  = options[:width]
    height = options[:height]
    show_title      = "title=0"    unless options[:show_title]
    show_byline     = "byline=0"   unless options[:show_byline]  
    show_portrait   = "portrait=0" unless options[:show_portrait]
	span = options[:span]
    frameborder     = options[:frameborder] || 0
    query_string_variables = [show_title, show_byline, show_portrait].compact.join("&")
    query_string    = "?" + query_string_variables unless query_string_variables.empty?
	if span == true
		%{<br /><div id = 'video' class = 'central_field' style = 'width: #{width}px;'><iframe src="//player.vimeo.com/video/#{vimeo_id}#{query_string}" width="#{width}" height="#{height}" frameborder="#{frameborder}"></iframe></div><br />}
	else
		%{<iframe src="//player.vimeo.com/video/#{vimeo_id}#{query_string}" width="#{width}" height="#{height}" frameborder="#{frameborder}"></iframe>}
	end
  end
end
AutoHtml.add_filter(:fNum) do |text|
	text.gsub(/\[fNum\](\n|\r)+((\d+\.\s.*(\n|\r)+)+)\[\/fNum\]/) do #\n((\d+\.\s.*\n)*)(\n)*\ \n\d+\.\s.*\n\[\/fNum\]
		c = $2
		if c != '' and c != nil 
			c = c.gsub(/(\d+)\.\s(.*)(\n|\r)/){"<li type = '1' value = #{$1}>#{$2}</li>"}
			"<ul class = 'cnt-un-num'>#{c}</ul>"
		else
			''
		end
		%{<ul class = 'cnt-un-num'>#{c}</ul>}
	  end
end
AutoHtml.add_filter(:my_quotes) do |text|
  variants = [
				{:tagName => 'quote', :className => 'cnt-quotes'},
				{:tagName => 'cAlign', :className => 'cnt-al-c'},
				{:tagName => 'rAlign', :className => 'cnt-al-r'}
				
			 ]
  cText = text
  variants.each do |v|
	  i = text.scan("[#{v[:tagName]}]").size
	  j = text.scan("[/#{v[:tagName]}]").size
	  newText = ''
	  if i == j and i != 0
		text = text.gsub("[#{v[:tagName]}]", "<div class = '#{v[:className]}'><p>").gsub("[/#{v[:tagName]}]", "</p></div>")
	  elsif i > j and j != 0 
		begin 
			newText = text.sub("[#{v[:tagName]}]", "<div class = '#{v[:className]}'><p>").sub("[/#{v[:tagName]}]", "</p></div>")
			text = newText
			j -= 1
		end until(j==0)
	  elsif i < j and i != 0
		begin 
			newText = text.sub("[#{v[:tagName]}]", "<div class = '#{v[:className]}'><p>").sub("[/#{v[:tagName]}]", "</p></div>")
			text = newText
			i -= 1
		end until(i==0)
	  end
  end
  text
end
AutoHtml.add_filter(:my_photo_hash) do |text|
  text.gsub(/#Photo(\d+)/) do
    photo = Photo.find_by_id($1)
	if photo != nil
		"<br /><div class = 'central_field' style = 'min-width: 100px;max-width:750px;'>#{"<p class = 'istring norm'>#{photo.description}</p>" if photo.description != nil and photo.description != ''}<img style = 'max-width: 750px;' src = '#{photo.link}'></div><br />" if photo.status_id == 1
	end
  end
end

AutoHtml.add_filter(:theme_hash) do |text|
  text.gsub(/#Theme(\d+)(\[(.+)\])?/) do
    theme = Theme.find_by_id($1)
	if theme != nil
		name = $3 if $3 != nil and $3 != ''
		name = theme.name if $3 == nil or $3 == ''
		"<a class = 'b_link' href = '/themes/#{theme.id.to_s}' target = '_blank'>#{name}</a>"
	end
  end
end

AutoHtml.add_filter(:user_hash) do |text|
  text.gsub(/#User(\d+)(\[(.+)\])?/) do
    user = User.find_by_id($1)
	if user != nil
		name = $3 if $3 != nil and $3 != ''
		name = user.name if $3 == nil or $3 == ''
		"<a class = 'b_link' title = 'Перейти к теме' href = '/users/#{user.id.to_s}' target = '_blank'>#{name}</a>"
	end
  end
end

