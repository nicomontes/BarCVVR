class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @kegs = Keg.where(endDate: nil)
    @users = User.all.order(lastName: :asc)
    @totalAmount = 0
    @operationLastMouth = Hash.new {}
    @operationTotal = Hash.new {}
    @users.each do |user|
      @operationTotal[user.id] = 0
      Operation.where(user_id: user.id).find_each do |operation|
        @operationTotal[user.id] = @operationTotal[user.id] + operation.sum
      end
      @operationTotal[user.id] = @operationTotal[user.id] + user.initAmount
      @totalAmount = @totalAmount + @operationTotal[user.id]
      totalOperationLastMouth = 0
      Operation.where(user_id: user.id).where.not('numberDrink' => nil).where("created_at > ?", Date.today.last_month()).find_each do |operation|
        if operation.sum < 0
          totalOperationLastMouth = totalOperationLastMouth + operation.sum
        end
      end
      @operationLastMouth[user.id] = totalOperationLastMouth
    end
    @userSorted = {}
    @operationLastMouth = @operationLastMouth.sort_by {|_key, value| value}.to_h
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @operations = Operation.where(user_id: @user.id).order("date DESC")
    Operation.where(user_id: @user.id).find_each do |operation|
      @user.amount = @user.amount + operation.sum
    end
  end
  
  # GET /users/1/lost
  def lost
    #user = User.find(params["id"])
    #UserNotifierMailer.send_lost_email(user).deliver
    #respond_to do |format|
    #  format.html { redirect_to User, notice: "Mot de passe de l'utilisateur " + @user.firstName + " " + @user.lastName + " à été envoyé sur son adresse email." }
    #end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create    
    amount = user_params[:initAmount].to_f
    @user = User.new(user_params.merge(amount: amount))

    respond_to do |format|
      if @user.save
        UserNotifierMailer.send_signup_email(@user).deliver
        format.html { redirect_to User, notice: "L'utilisateur " + @user.firstName + " " + @user.lastName + " à été ajouté." }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    if params[:admin_password] == ENV["ADMIN_PASSWORD"]
      if params[:usr][:delete] == "yes"
        @user.destroy
        Operation.where(user_id: @user.id).find_each do |operation|
          operation.destroy
        end
        respond_to do |format|
          format.html { redirect_to User, notice: "L'utilisateur " + @user.firstName + " " + @user.lastName + " à été supprimé" }
        end
      else
        respond_to do |format|
          if @user.update(user_params)
            format.html { redirect_to User, notice: "L'utilisateur " + @user.firstName + " " + @user.lastName + " à été mis à jour." }
            format.json { render :show, status: :ok, location: @user }
          else
            format.html { render :edit }
            format.json { render json: @user.errors, status: :unprocessable_entity }
          end
        end
      end
    else
      redirect_back fallback_location:  ""
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    if params[:admin_password] == ENV["ADMIN_PASSWORD"]
      @user.destroy
      Operation.where(user_id: user.id).find_each do |operation|
        operation.destroy
      end
      respond_to do |format|
        format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:firstName, :lastName, :alias, :password_digest, :initAmount, :amount, :email)
    end
end
