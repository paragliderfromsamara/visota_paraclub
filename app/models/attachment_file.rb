class AttachmentFile < ActiveRecord::Base
   attr_accessor :directory
   attr_accessible :name, :article_id, :message_id, :event_id, :user_id, :link, :theme_id, :size, :directory
   belongs_to :user
   belongs_to :article
   belongs_to :event
   belongs_to :message
   belongs_to :theme

   before_create :add_file
   before_destroy :delete_file_in_folder
   
   def add_file
			save_dir = "public/uploads/#{directory}"
			FileUtils.mkdir_p(save_dir) unless File.exists?(save_dir)
			uploaded_io = link
				File.open(Rails.root.join(save_dir, uploaded_io.original_filename), 'w') do |file|
					file.write(uploaded_io.read)
				end
			dir_link = "/uploads/#{directory}/" +  uploaded_io.original_filename
			self.size = uploaded_io.size
			self.name = uploaded_io.original_filename
			self.link = dir_link
   end
   
   def delete_file_in_folder
		File.delete("#{Rails.root}/public#{self.link}")
   end
   
   def get_file_size
	file_size = File.size("#{Rails.root}/public#{self.link}")
	self.update_attributes(:size => file_size)
   end
   
   def alter_size
	if size == nil
		get_file_size
	end
	if size != nil
		alt_size = size
		measure = 'Байт'
		if size < 1000
			alt_size = size
			measure = 'Байт'
		elsif size >= 1000 && size < 1000000
			alt_size = size/1000
			measure = 'КБайт'
		elsif size >= 1000000 && size < 1000000000
			alt_size = size/1000000
			measure = 'MБайт'
		elsif size >= 1000000000 
			alt_size = size/1000000000
			measure = 'ГБайт'
		end
		return "<b>#{alt_size.to_s}</b> #{measure}"
	else
		return ''
	end
   end
end
