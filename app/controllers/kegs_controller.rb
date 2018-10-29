class KegsController < ApplicationController
  before_action :set_keg, only: [:show, :edit, :update, :destroy]

  # GET /kegs
  # GET /kegs.json
  def index
    @kegs = Keg.all.order("created_at DESC").paginate(page: params[:page], :per_page => 10)
    @profit = []
    @kegs.each do |keg|
      @profit[keg.id] = 0 - keg.price
      if keg.endDate
        operations = Operation.where("drink_id = ?", keg.drink_id).where("date > ?", keg.startDate).where("date < ?", keg.endDate)
        operations.each do |op|
          @profit[keg.id] = @profit[keg.id] - op.sum
        end
      else
        operations = Operation.where("drink_id = ?", keg.drink_id).where("date > ?", keg.startDate)
        operations.each do |op|
          @profit[keg.id] = @profit[keg.id] - op.sum
        end
      end
    end
  end

  # GET /kegs/1
  # GET /kegs/1.json
  def show
    @opNum = 0
    @profit = 0 - @keg.price
    if @keg.endDate
      operations = Operation.where("drink_id = ?", @keg.drink_id).where("date > ?", @keg.startDate).where("date < ?", @keg.endDate)
      operations.each do |op|
        @opNum = @opNum + op.numberDrink.to_s.to_d
        @profit = @profit - op.sum
      end
    else
      operations = Operation.where("drink_id = ?", @keg.drink_id).where("date > ?", @keg.startDate)
      operations.each do |op|
        @opNum = @opNum + op.numberDrink.to_s.to_d
        @profit = @profit - op.sum
      end
    end
  end

  # GET /kegs/new
  def new
    @keg = Keg.new
  end

  # GET /kegs/1/renew
  def renew
    keg = Keg.find(params[:id])
    Keg.update(params[:id], :endDate => DateTime.now.getutc().to_s)
    Keg.create(name: keg.name, drink_id: keg.drink_id, startDate: DateTime.now.getutc(), capacity: keg.capacity, price: keg.price)
    redirect_to User, notice: "Le fût a été changé."
  end

  # GET /kegs/1/edit
  def edit
  end

  # POST /kegs
  # POST /kegs.json
  def create
    if params[:admin_password] == ENV["ADMIN_PASSWORD"]
      drink_id = params[:post][:drink]
      @keg = Keg.new(keg_params.merge(drink_id: drink_id))
      respond_to do |format|
        if @keg.save
          format.html { redirect_to Keg, notice: "Le fût a été créé."}
          format.json { render :show, status: :created, location: @keg }
        else
          format.html { render :new }
          format.json { render json: @keg.errors, status: :unprocessable_entity }
        end
      end
    else
      redirect_back fallback_location:  ""
    end
  end

  # PATCH/PUT /kegs/1
  # PATCH/PUT /kegs/1.json
  def update
    if params[:admin_password] == ENV["ADMIN_PASSWORD"]
      if params[:kg][:delete] == "yes"
        @keg.destroy
        respond_to do |format|
          format.html { redirect_to Keg, notice: "Le fût a été supprimé." }
        end
      else
        respond_to do |format|
          if @keg.update(keg_params)
            format.html { redirect_to Keg, notice: "Le fût a été modifié."}
            format.json { render :show, status: :ok, location: @keg }
          else
            format.html { render :edit }
            format.json { render json: @keg.errors, status: :unprocessable_entity }
          end
        end
      end
    else
      redirect_back fallback_location:  ""
    end
  end

  # DELETE /kegs/1
  # DELETE /kegs/1.json
  def destroy
    if params[:admin_password] == ENV["ADMIN_PASSWORD"]
      @keg.destroy
      respond_to do |format|
        format.html { redirect_to Keg, notice: "Le fût a été supprimé."}
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_keg
      @keg = Keg.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def keg_params
      params.require(:keg).permit(:name, :drink_id, :startDate, :endDate, :capacity, :price)
    end
end
