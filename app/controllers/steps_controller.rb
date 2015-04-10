class StepsController < ApplicationController
  # GET /steps
  # GET /steps.json
  def index
	if is_super_admin?
		@steps = Step.all
		respond_to do |format|
		  format.html # index.html.erb
		  format.json { render :json => @steps }
		end
	else
		redirect_to '/404'
	end
  end

  # GET /steps/1
  # GET /steps/1.json
  def show
	if is_super_admin?
		@step = Step.find(params[:id])
		respond_to do |format|
		  format.html # show.html.erb
		  format.json { render :json => @step }
		end
	else
		redirect_to '/404'
	end
  end

  # GET /steps/new
  # GET /steps/new.json
  def new
	if is_super_admin?
		@step = Step.new
		respond_to do |format|
		  format.html # new.html.erb
		  format.json { render :json => @step }
		end
	else
		redirect_to '/404'
	end
  end

  # GET /steps/1/edit
  def edit
    if is_super_admin?
		@step = Step.find(params[:id])
	else
		redirect_to '/404'
	end
  end

  # POST /steps
  # POST /steps.json
  def create
   if is_super_admin?
		@step = Step.new(params[:step])
		respond_to do |format|
		  if @step.save
			format.html { redirect_to @step, :notice => 'Step was successfully created.' }
			format.json { render :json => @step, :status => :created, :location => @step }
		  else
			format.html { render :action => "new" }
			format.json { render :json => @step.errors, :status => :unprocessable_entity }
		  end
		end
	else
		redirect_to '/404'
	end
  end

  # PUT /steps/1
  # PUT /steps/1.json
  def update
	 if is_super_admin?
		@step = Step.find(params[:id])

		respond_to do |format|
		  if @step.update_attributes(params[:step])
			format.html { redirect_to @step, :notice => 'Step was successfully updated.' }
			format.json { head :no_content }
		  else
			format.html { render :action => "edit" }
			format.json { render :json => @step.errors, :status => :unprocessable_entity }
		  end
		end
	else
		redirect_to '/404'
	end
  end

  # DELETE /steps/1
  # DELETE /steps/1.json
  def destroy
	if is_super_admin?
		@step = Step.find(params[:id])
		@step.destroy

		respond_to do |format|
		  format.html { redirect_to steps_url }
		  format.json { head :no_content }
		end
	else
		redirect_to '/404'
	end
  end
end
