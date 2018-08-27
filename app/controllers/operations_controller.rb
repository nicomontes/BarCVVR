class OperationsController < ApplicationController
  before_action :set_operation, only: [:show, :edit, :update, :destroy]

  # GET /operations
  # GET /operations.json
  def index
    #Operation.paginate(page: params[:page])
    @operations = Operation.all.order("date DESC").paginate(page: params[:page], :per_page => 10)
  end

  # GET /operations/1
  # GET /operations/1.json
  def show
  end

  # GET /operations/new
  def new
    @operation = Operation.new
    @operation.user_id=params[:userid]
  end

  # GET /operations/add
  def add
    @operation = Operation.new
    @operation.user_id=params[:userid]
  end
  
  # GET /operations/exchange
  def exchange
    @operation = Operation.new
    @operation.user_id=params[:userid]
    @users = User.all.order(lastName: :asc)
  end

  # GET /operations/1/edit
  def edit
    @userid = params[:userid]
    amount = User.find(@userid).initAmount
    Operation.where(user_id: @userid).find_each do |operation|
      amount = amount + operation.sum
    end
    User.find(@userid).update_attribute(:amount, amount)
  end

  # POST /operations
  # POST /operations.json
  def create
    if params[:post_exchange_user]
      sum = 0 - operation_params[:sum].to_f
      @operation1 = Operation.new(operation_params.merge(sum: sum))
      @operation2 = Operation.new(operation_params.merge(sum: operation_params[:sum].to_f, user_id: params[:post_exchange_user]))
      respond_to do |format|
        if @operation1.save && @operation2.save
          amount = User.find(@operation1.user_id).initAmount
          Operation.where(user_id: @operation1.user_id).find_each do |operation|
            amount = amount + operation.sum
          end
          User.find(@operation1.user_id).update_attribute(:amount, amount)
          amount = User.find(@operation2.user_id).initAmount
          Operation.where(user_id: @operation2.user_id).find_each do |operation|
            amount = amount + operation.sum
          end
          User.find(@operation2.user_id).update_attribute(:amount, amount)
          format.html { redirect_to User, notice: "Opération prise en compte !"}
          format.json { render :show, status: :created, location: @operation }
        else
          format.html { render :exchange }
          format.json { render json: @operation.errors, status: :unprocessable_entity }
        end
      end
    else  
      if params[:post]
        drink_id = params[:post][:drink]
        drink_price = Drink.find(drink_id).price.to_f
        sum = 0 - operation_params[:numberDrink].to_f * drink_price
      else
        sum = operation_params[:sum].to_f
      end
      @operation = Operation.new(operation_params.merge(sum: sum, drink_id: drink_id))
      respond_to do |format|
        if @operation.save
          amount = User.find(operation_params[:user_id]).initAmount
          Operation.where(user_id: operation_params[:user_id]).find_each do |operation|
            amount = amount + operation.sum
          end
          User.find(operation_params[:user_id]).update_attribute(:amount, amount)
          if amount < 0
            UserNotifierMailer.send_negative_email(User.find(operation_params[:user_id])).deliver
          end
          format.html { redirect_to User, notice: "Opération prise en compte !"}
          format.json { render :show, status: :created, location: @operation }
        else
          format.html { render :new }
          format.json { render json: @operation.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /operations/1
  # PATCH/PUT /operations/1.json
  def update
    if params[:admin_password] == ENV["ADMIN_PASSWORD"]
      if params[:op][:delete] == "yes"
        @operation.destroy
        amount = User.find(operation_params[:user_id]).initAmount
        Operation.where(user_id: operation_params[:user_id]).find_each do |operation|
          amount = amount + operation.sum
        end
        User.find(operation_params[:user_id]).update_attribute(:amount, amount)
        respond_to do |format|
          format.html { redirect_to Operation, notice: "L'opération a bien été supprimée." }
        end
      else
        respond_to do |format|
          if @operation.update(operation_params)
            amount = User.find(operation_params[:user_id]).initAmount
            Operation.where(user_id: operation_params[:user_id]).find_each do |operation|
              amount = amount + operation.sum
            end
            User.find(operation_params[:user_id]).update_attribute(:amount, amount)
            format.html { redirect_to Operation, notice: "L'opération a bien été mise à jour." }
            format.json { render :show, status: :ok, location: @operation }
          else
            format.html { render :edit }
            format.json { render json: @operation.errors, status: :unprocessable_entity }
          end
        end
      end
    else
      redirect_back fallback_location:  ""
    end
  end

  # DELETE /operations/1
  # DELETE /operations/1.json
  def destroy
    if params[:admin_password] == ENV["ADMIN_PASSWORD"]
      @operation.destroy
      amount = User.find(operation_params[:user_id]).initAmount
      Operation.where(user_id: operation_params[:user_id]).find_each do |operation|
        amount = amount + operation.sum
      end
      User.find(operation_params[:user_id]).update_attribute(:amount, amount)
      respond_to do |format|
        format.html { redirect_to Operation, notice: "L'opération a bien été supprimée." }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_operation
      @operation = Operation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def operation_params
      params.require(:operation).permit(:date, :sum, :user_id, :numberDrink, :comment)
    end
end
