module AttachmentFilesHelper
  def add_file(directory, type)
	if user_type != "guest" and user_type != "bunned" 
			@directory = "public/uploads/#{directory}"
			FileUtils.mkdir_p(@directory) unless File.exists?(@directory)
			uploaded_io = params[:attachment_file][:link]
				File.open(Rails.root.join(@directory, uploaded_io.original_filename), 'w') do |file|
					file.write(uploaded_io.read)
				end
			@link = "/uploads/#{directory}/" +  uploaded_io.original_filename
			@attachment = AttachmentFile.new(:name => uploaded_io.original_filename, :user_id => current_user.id, :article_id => @article_id, :message_id => @message_id, :event_id => @event_id, :link => @link)
			@attachment.save
			redirect_to(@article) if @article_id != nil
			redirect_to(@target) if @message_id != nil
			redirect_to(@event) if @event_id != nil
	end
  end
  
  def remove_file(remove_type, file)
	if user_type != "guest" and user_type != "bunned" 
		if remove_type == 'remove_from_article' or remove_type == 'remove_from_article_with_article'
			if current_user == file.article.user or user_type == "admin" or user_type == "manager"
				if file.event_id != nil or file.message_id != nil
					file.update_attributes(:article_id => nil)
				else 
					if File.delete("#{Rails.root}/public/#{file.link}")
						file.destroy
					end
				end
				redirect_to(file.article) if remove_type == 'remove_from_article' 
			end 	
		elsif remove_type == 'remove_from_message'
		elsif remove_type == 'remove_from_event'
			if user_type == "admin" or user_type == "manager"
				if file.article_id != nil or file.message_id != nil
					file.update_attributes(:event_id => nil)
				else 
					if File.delete("#{Rails.root}/public/#{file.link}")
						file.destroy
					end
				end
				redirect_to(file.event)
			end
		end
	end
  end
end
