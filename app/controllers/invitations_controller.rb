class InvitationsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_invitation, only: [:edit, :update, :delete, :destroy]
    before_action :set_rooms, only: [:new, :create]
  
    def index
      @invitations = current_establishment.invitations
                                          .in_period(current_establishment_period)
                                          .search(params[:search])
                                          .page(params[:page])
    end
  
    def new
      @invitation = current_establishment.invitations.new(
        user: current_user
      )
    end
  
    def create
      @invitation = current_establishment.invitations.new(invitation_params)
      @invitation.user = current_user
      @invitation.establishment_period = current_establishment_period
  
      if @invitation.save
        respond_to do |format|
          format.text { render "invitations/new", locals: { invitation: @invitation }, formats: [:html] }
        end
      else
        render :new, status: :unprocessable_entity
      end
    end
  
    def edit; end
  
    def update
      if @invitation.update(invitation_params)
        redirect_to invitations_path, notice: t('invitations.notice.update')
      else
        redirect_to invitations_path, alert: t('invitations.alert.update')
      end
    end
  
    def delete; end
  
    def destroy
      if @invitation.destroy
        redirect_to invitations_path, notice: t('invitations.notice.destroy')
      else
        redirect_to invitations_path, alert: t('invitations.alert.destroy')
      end
    end
  
    def join
      return render "join" if request.get?
  
      process_invitation_join
    end
  
    private
  
    def invitation_params
      params.require(:invitation).permit(:name, :role, :expires_at, :max_use, :room_id)
    end
  
    def set_invitation
      @invitation = current_establishment.invitations.find(params[:id])
    end
  
    def set_rooms
      @rooms = current_establishment.rooms.in_period(current_establishment_period)
    end
  
    def process_invitation_join
      return redirect_invalid_code unless valid_invitation_code?
  
      add_user_to_establishment
      update_invitation
      create_notification
  
      redirect_to dashboard_path, notice: t('invitations.notice.join')
    end
  
    def valid_invitation_code?
      return false unless params[:code].present?
      @invitation = Invitation.find_by(token: params[:code])
      return false if @invitation.nil? || @invitation.cant_use?
  
      @establishment = @invitation.establishment
      !@establishment.users.include?(current_user)
    end
  
    def redirect_invalid_code
      redirect_to dashboard_path, alert: t('invitations.alert.code_invalid')
    end
  
    def create_notification
      Notification.create(
        sender: current_user,
        receiver: @invitation.user,
        url: dashboard_path,
        content: notification_content
      )
    end
  
    def notification_content
      "L'utilisateur *#{current_user.name}* a rejoint votre établissement *#{@establishment.name}*"
    end
  
    def add_user_to_establishment
      InvitationProcessor.new(@invitation, current_user).process
    end
  
    def update_invitation
      @invitation.update(taken: @invitation.taken + 1)
      session[:establishment_id] = @establishment.id
    end
  end
  