module GrantsHelper
	def is_not_authorized?
		user_type == 'guest' || user_type == 'bunned' || user_type == 'new_user' || user_type == 'deleted'
	end
	def is_admin?
		user_type == 'admin' || user_type == 'super_admin'
	end
	def is_super_admin? 
		user_type == 'super_admin'
	end
#votes
	def vote_completed?(vote)
		vote.end_date < Time.now
	end
	def userCanGiveVoice?(vote)
		if vote != nil and user_type != 'guest'
			voice = Voice.find_by_vote_id_and_user_id(vote.id, current_user.id)
			if vote_completed?(vote) and voice != nil
				return false
			else
				return true
			end
		else
			return false
		end
	end
	def user_could_see_vote_result?(vote)
		
		if user_type != 'guest' and vote != nil
			voice = Voice.find_by_user_id_and_vote_id(current_user.id, vote.id) 
			if voice != nil || vote_completed?(vote)
				return true
			else	
				return false
			end
		else
			if vote_completed?(vote)
				return true
			else
				return false
			end
		end
	end
#votes end
#photos_part
	def userCanSeePhoto?(photo)
		f = false
		if photo != nil
			if photo.theme != nil
				f = userCanSeeTheme?(photo.theme)
			elsif photo.message != nil
				f = userCanSeeMessage?(photo.message)
			elsif photo.photo_album != nil
				f = userCanSeeAlbum?(photo.photo_album)
			elsif photo.article != nil
				f = isEntityOwner?(photo.article)
			end
		end
		return f
	end
	def userCanDeletePhoto?(photo) #может ли пользователь удалить фотографию?
		if isEntityOwner?(photo)
			th_flag = true
			alb_flag = true
			msg_flag = true
			art_flag = true
			evnt_flag = true
			if photo.theme != nil
				th_flag = false if (!userCanEditTheme?(photo.theme) || photo.theme.content.strip == '') and photo.theme.status != 'draft'
			end
			if photo.message != nil
				msg_flag = false if (!userCanEditMsg?(photo.message) || (photo.message.content.strip == '' and photo.message.photos.count == 1)) and photo.message.status != 'draft'
			end
			if photo.photo_album != nil
				alb_flag = false if !userCanEditAlbum?(photo.photo_album) || photo.photo_album.photos.count == 1
			end
			if photo.article != nil
				art_flag = false if !userCanEditArtilcle?(photo.article) || (photo.article.photos.count == 1 and photo.article.content.strip == '')
			end
			if photo.event != nil
				evnt_flag = false if !userCanEditEvent?(photo.event) || (photo.event.photos.count == 1 and photo.event.content.strip == '')
			end
			return th_flag & alb_flag & msg_flag & art_flag & evnt_flag
		end
		return false
	end
	#photos_part_end
	#articles_part
	def userCanCreateArticle?
		if !is_not_authorized?
			if user_type != 'friend'
				return true
			end
		end
		return false
	end
	def userCanEditArtilcle?(article)
		isEntityOwner?(article) || is_super_admin?
	end
	#articles_part end
	#events_part
	def userCanEditEvent?(event)
		return true if (is_admin? || user_type == 'manager') and event != nil
		return false
	end
	#events_part end
	#photo_albums_part
		def userCanSeeAlbum?(album)
			if album != nil
				return true if (album.status == 'hidden' and !is_not_authorized?) || (album.status == 'visible')
				return true if is_admin?
			end
			return false
		end
		def userCanEditAlbum?(album)		
			if isEntityOwner?(album) 
				return true if album.status_id == 1
				return true if is_admin?
			end
			return false
		end
	#photo_albums_part end
	#users_part
		def userCanEditUserCard?(user)
			(is_super_admin? || (user == current_user and user_type != 'bunned')) and user != nil  
		end
	#users_part end
	#topics_part
		def userCreateThemeInTopic?(topic)
			!is_not_authorized? || (user_type == 'new_user' and topic.id == 6) 
		end
	#topics_part
	#themes_part
	def userCanDeleteTheme?(theme)
		if theme != nil
			((isThemeOwner?(theme) || is_admin?) and (theme.status == 'open' || theme.status == 'closed')) || is_super_admin?
		else
			return false
		end
	end
	def isThemeOwner?(theme)
		if theme != nil
		(theme.user == current_user and user_type != 'bunned' and user_type != 'guest' and user_type != 'deleted') || is_super_admin?
		else
			return false
		end
	end
	def isEntityOwner?(entity)
		if entity != nil
			(entity.user == current_user and user_type != 'bunned' and user_type != 'guest') || is_super_admin?
		else
			return false
		end
	end
	def userCanEditTheme?(theme) #проверка может ли пользователь редактировать тему
		(isThemeOwner?(theme) and theme.status == 'open') || is_super_admin?
	end
	def userCanSwitchTheme?(theme) #проверка может ли пользователь открывать/закрывать тему
		(isThemeOwner?(theme) and (theme.status == 'open' || theme.status == 'closed')) || is_admin?
	end
	def userCanCreateMsgInTheme?(theme) #проверка может ли пользователь редактировать тему
		f = false
			if theme != nil
				if theme.status == 'open' 
					if theme.v_status == 'visible'
						f = true if !is_not_authorized? || (user_type == 'new_user' and (theme.topic.id == 6 || current_user == theme.user))
					elsif theme.v_status == 'hidden'
						f = true if !is_not_authorized?
					end
				end
			end
		return f
	end
	def userCanSeeTheme?(theme)
		f = false 
		if theme != nil
			if theme.v_status == 'hidden' and (theme.status == 'open' or theme.status == 'closed') 
					f = true if !is_not_authorized?
					f = true if theme.user == current_user
			elsif (theme.v_status == 'hidden' or theme.v_status == 'visible') and (theme.status == 'open' or theme.status == 'closed') 
				f = true
			end
			f = true if theme.status == 'draft' and isEntityOwner?(theme)
			f = true if is_super_admin?
		end 
		return f
	end
	#themes_part end

	#messages_part
	def userCanCreateMsg? #может ли пользователь создавать сообщение
		th_flag = true
		alb_flag = true
		ph_flag = true
		if @theme != nil
			th_flag = userCanCreateMsgInTheme?(@theme)
		end
		if @album != nil
			alb_flag = !is_not_authorized? #условие для альбома
		end
		if @photo != nil
			ph_flag = !is_not_authorized? #условие для фото
		end
		return th_flag & alb_flag & ph_flag
		
	end
	def userCanEditMsg?(msg)
		if isEntityOwner?(msg) 
			if !msg.tread_has_another_user_message?
				if msg.theme_id != nil
					return true if msg.theme.status == 'open'
				end
			end
		end 
		#return true if is_super_admin?
		return false
	end
	def userCanSeeMessage?(msg)
		if msg != nil
			return userCanSeeTheme?(msg.theme) if msg.theme_id != nil
		end
		return false
	end
	def userCanDeleteMessage?(msg)
		return true if isEntityOwner?(msg)
		return false
	end
	#messages_part end
	
	
   #ограничения end
end