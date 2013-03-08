class DiagnosesController < ApplicationController
  # GET /diagnoses
  # GET /diagnoses.json
  def index
    @diagnoses = Diagnosis.has_pedigree(params[:pedigree_filter]).find(:all, :include => {:person => :pedigree}, :order => ['pedigrees.name'])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @diagnoses }
      format.js
    end
  end

  # GET /diagnoses/1
  # GET /diagnoses/1.json
  def show
    @diagnosis = Diagnosis.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @diagnosis }
    end
  end

  # GET /diagnoses/new
  # GET /diagnoses/new.json
  def new
    @diagnosis = Diagnosis.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @diagnosis }
    end
  end

  # GET /diagnoses/1/edit
  def edit
    @diagnosis = Diagnosis.find(params[:id])
  end

  # POST /diagnoses
  # POST /diagnoses.json
  def create
    @diagnosis = Diagnosis.new(diagnosis_params)

    respond_to do |format|
      if @diagnosis.save
        format.html { redirect_to @diagnosis, notice: 'Person disease was successfully created.' }
        format.json { render json: @diagnosis, status: :created, location: @diagnosis }
      else
        format.html { render action: "new" }
        format.json { render json: @diagnosis.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /diagnoses/1
  # PUT /diagnoses/1.json
  def update
    @diagnosis = Diagnosis.find(params[:id])

    respond_to do |format|
      if @diagnosis.update_attributes(diagnosis_params)
        format.html { redirect_to @diagnosis, notice: 'Person disease was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @diagnosis.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /diagnoses/1
  # DELETE /diagnoses/1.json
  def destroy
    @diagnosis = Diagnosis.find(params[:id])
    person = @diagnosis.person
    @diagnosis.destroy

    respond_to do |format|
      format.html { redirect_to person_url(person) }
      format.json { head :ok }
    end
  end

  private
  def diagnosis_params
    params.require(:diagnosis).permit(:person_id, :disease_id, :age_of_onset, :disease_information, :output_order)
  end
end
