class UserNotifierMailer < ApplicationMailer
  
  default :from => ENV["SENDGRID_EMAIL"]

  # send a signup email to the user, pass in the user object that contains the user's email address
  def send_signup_email(user)
    @user = user
    mail( :to => @user.email,
    :subject => 'Merci pour ton inscription' )
  end
  
  # send a lost email to the user, pass in the user object that contains the user's email address and password
  def send_lost_email(user)
    @user = user
    mail( :to => @user.email,
    :subject => 'Mot de passe perdu' )
  end
  
  # send a negative email to the user, pass in the user object that contains the user's email address and password
  def send_negative_email(user)
    @user = user
    @lastSpending = Operation.where(user_id: @user.id).order(date: :desc).limit(10)
    @operations = Operation.where(user_id: @user.id).order("date DESC")
    #Operation.where(user_id: @user.id).find_each do |operation|
    #  @user.amount = @user.amount + operation.sum
    #end
    mail( :to => @user.email,
    :subject => 'Compte bar en négatif !' )
  end
  
  # send an award email
  def send_award_email(user)
    @user = user
    if (Date.today.mday == 1 && @user.email != "")
      @users = User.all.order(lastName: :asc)
      @totalAmount = 0
      @operationLastMouth = Hash.new {}
      @operationTotal = Hash.new {}
      @users.each do |user|
        @operationTotal[user.id] = 0
        Operation.where(user_id: user.id).find_each do |operation|
          @operationTotal[user.id] = @operationTotal[user.id] + operation.sum
        end
        @operationTotal[user.id] = @operationTotal[user.id] + user.amount
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
    
      i = 0
      @userAward = []
      userAwardId = []
      @monthAmount = []
      @operationLastMouth.each do |key, value|
        @userAward[i] = @users.find(key).firstName + " " + @users.find(key).lastName
        userAwardId[i] = @users.find(key).id
        @monthAmount[i] = value
        i = i + 1
      end
      j = 0
      while (j < 15)
        if userAwardId[j] == @user.id
          puts "Send to : " + @user.email
          mail( :to => @user.email,
          :subject => 'Bar CVVR Awards !' )
        end
        j = j + 1
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
