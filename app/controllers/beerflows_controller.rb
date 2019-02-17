class BeerflowsController < ApplicationController
  before_action :set_beerflow, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token

  # GET /beerflows
  # GET /beerflows.json
  def index
    @beerflows = Beerflow.all
  end

  # GET /beerflows/1
  # GET /beerflows/1.json
  def show
  end

  # GET /beerflows/new
  def new
    @beerflow = Beerflow.new
  end

  # GET /beerflows/1/edit
  def edit
  end

  # POST /beerflows
  # POST /beerflows.json
  def create
    @beerflow = Beerflow.new(beerflow_params)

    respond_to do |format|
      if @beerflow.save
        format.html { redirect_to @beerflow, notice: 'Beerflow was successfully created.' }
        format.json { render :show, status: :created, location: @beerflow }
      else
        format.html { render :new }
        format.json { render json: @beerflow.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /beerflows/1
  # PATCH/PUT /beerflows/1.json
  def update
    respond_to do |format|
      beerflow = beerflow_params
      if beerflow[:quantity] != 0
        total = Beerflow.where(:id => params[:id]).first[:quantity].to_f + beerflow_params[:quantity].to_f
        beerflow[:quantity] = total
        puts beerflow[:quantity]
      else
        beerflow[:quantity] = 0
      end

      if @beerflow.update(beerflow)
        #format.html { redirect_to @beerflow, notice: 'Beerflow was successfully updated.' }
        #format.json { render :show, status: :ok, location: @beerflow }
      else
        #format.html { render :edit }
        #format.json { render json: @beerflow.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /beerflows/1
  # DELETE /beerflows/1.json
  def destroy
    @beerflow.destroy
    respond_to do |format|
      format.html { redirect_to beerflows_url, notice: 'Beerflow was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_beerflow
      @beerflow = Beerflow.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def beerflow_params
      params.require(:beerflow).permit(:quantity, :drink_id)
    end
end
