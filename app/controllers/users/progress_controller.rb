module Users
  class ProgressController < ApplicationController
    before_action :authenticate_user!

    def destroy
      user_id = params[:id]
      ResetProgressJob.perform_async(user_id)
      redirect_to edit_user_registration_path, notice: 'Your lesson completions have been deleted.'
    end
  end
end
