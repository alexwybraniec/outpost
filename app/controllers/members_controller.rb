# This controller allowed community users to manage their organisation's members.
# They could invite new members and remove members from the organisation.
#
# This functionality was removed in Dec 2020 (commit 6bc2ea7a) but the code
# has been left in, presumably in case we want to add it back in.
class MembersController < ApplicationController
    before_action :no_admins
    skip_before_action :no_admins, only: [:destroy]
    
    def new
        @user = User.new
    end

    def create
        @user = current_user.organisation.users.build(user_params)
        @user.password = SecureRandom.urlsafe_base64
        if @user.save
            UserMailer.with(user: @user).invite_from_community_email.deliver_later
            redirect_to organisations_path, notice: "User invited successfully. They'll get an email telling them what to do next."
        else
            render 'new'
        end
    end

    def destroy
        @user = User.find(params[:id])
        @user.discard
        redirect_to organisations_path, notice: "That user has been removed and won't be able to sign in any more."
    end

    private

    def user_params
        params.require(:user).permit(
            :email,
            :phone,
            :first_name,
            :last_name
        )
    end

end
