class OldMessagesController < ApplicationController
include OldMessagesHelper
  # GET /old_messages
  # GET /old_messages.json
  def index
    @old_messages = OldMessage.paginate(:page => params[:page], :per_page => 25).find(:all, :order => 'created_when DESC')
	@title = 'Архив сообщений с para.saminfo.ru'
	@path_array = [
					{:name => 'Клубная жизнь', :link => '/visota_life'},
					{:name => @title, :link => '/'}
				  ]
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @old_messages }
    end
  end

  # GET /old_messages/1
  # GET /old_messages/1.json
  def show
    @old_message = OldMessage.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @old_message }
    end
  end

  # GET /old_messages/new
  # GET /old_messages/new.json
  def new
	if user_type == 'super_admin'
		@old_message = OldMessage.new

		respond_to do |format|
		  format.html # new.html.erb
		  format.json { render :json => @old_message }
		end
	else
		redirect_to '/404'
	end
  end

  # GET /old_messages/1/edit
  def edit
	if user_type == 'super_admin'
		@title = 'Изменение сообщения'
		@old_message = OldMessage.find(params[:id])
		@users = User.all
	else
		redirect_to '/404'
	end
  end

  # POST /old_messages
  # POST /old_messages.json
  def create
    @old_message = OldMessage.new(params[:old_message])

    respond_to do |format|
      if @old_message.save
        format.html { redirect_to @old_message, :notice => 'Old message was successfully created.' }
        format.json { render :json => @old_message, :status => :created, :location => @old_message }
      else
        format.html { render :action => "new" }
        format.json { render :json => @old_message.errors, :status => :unprocessable_entity }
      end
    end
  end

  def get_old_messages
	if user_type == 'super_admin'
		put_old_messages
	end
	redirect_to old_messages_path
  end
  
  def old_msg_users
	if user_type == 'super_admin'
		old_messages = OldMessage.find_all_by_user_id([nil, 0])
		@users = User.find(:all, :order => 'name ASC')
		name_array = []
		old_messages.each do |message|
		   name_array[name_array.length] = message.user_name
		end
		@names = name_array.uniq
	else
		redirect_to '/404'
	end
  end
  
  def assign_users_to_old_msgs
    i = -1
    names = params[:names]
    begin
	i += 1
	name = params[:names][i.to_s][:name]
	id = params[:names][i.to_s][:id]
	if id != 0 and id != nil
	  messages = OldMessage.find_all_by_user_name(name)
	  messages.each do |msg|
		msg.update_attributes(:user_id => id.to_i)
	  end
	end
    end until(i == names.length - 1)
  end
  # PUT /old_messages/1
  # PUT /old_messages/1.json
  def update
	if user_type == 'super_admin'
		@old_message = OldMessage.find(params[:id])
		respond_to do |format|
		  if @old_message.update_attributes(params[:old_message])
			format.html { redirect_to old_messages_path, :notice => 'Old message was successfully updated.' }
			format.json { head :no_content }
		  else
			format.html { render :action => "edit" }
			format.json { render :json => @old_message.errors, :status => :unprocessable_entity }
		  end
		end
	else
		redirect_to '/404'
	end
  end

  # DELETE /old_messages/1
  # DELETE /old_messages/1.json
  def destroy
	if user_type == 'super_admin'
		@old_message = OldMessage.find(params[:id])
		@old_message.destroy

		respond_to do |format|
		  format.html { redirect_to old_messages_url }
		  format.json { head :no_content }
		end
	else
		redirect_to '/404'
	end
  end
end
