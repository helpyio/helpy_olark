Topic.class_eval do

  def create_topic_with_olark_user(params)
    self.user = User.find_by_email(params['visitor']['emailAddress'])
    unless self.user #User not found, lets craete it from olark params
      @token, enc = Devise.token_generator.generate(User, :reset_password_token)

      @user = self.build_user
      @user.reset_password_token = enc
      @user.reset_password_sent_at = Time.now.utc

      @user.name = params['visitor']['fullName']
      @user.login = params['visitor']['emailAddress'].split("@")[0]
      @user.email = params['visitor']['emailAddress']
      # @user.home_phone = params[:topic][:user][:home_phone]
      @user.password = User.create_password
      @user.save
    end
    self.user.persisted? && self.save
  end

end
