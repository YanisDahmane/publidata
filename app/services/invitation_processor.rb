class InvitationProcessor
    def initialize(invitation, user)
      @invitation = invitation
      @user = user
      @establishment = invitation.establishment
      @room = invitation.room
    end
  
    def process
      add_user_to_establishment
      add_user_to_room if @room
    end
  
    private
  
    def add_user_to_establishment
      case @invitation.role
      when EstablishmentUser::ROLE[:teacher]
        @establishment.teachers << @user
      when EstablishmentUser::ROLE[:student]
        @establishment.students << @user
      when EstablishmentUser::ROLE[:owner]
        @establishment.owners << @user
      end
    end
  
    def add_user_to_room
      case @invitation.role
      when EstablishmentUser::ROLE[:teacher]
        @room.teachers << @user
      when EstablishmentUser::ROLE[:student]
        @room.students << @user
      end
    end
  end