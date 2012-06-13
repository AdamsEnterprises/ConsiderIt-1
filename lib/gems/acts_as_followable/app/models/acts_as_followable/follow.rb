class ActsAsFollowable::Follow < ActiveRecord::Base

  belongs_to :followable, :polymorphic=>true
  belongs_to :user

  def notify?
    follow
  end

  def self.build_from(obj, user_id, follow = false)
    c = self.new
    c.followable_id = obj.id 
    c.followable_type = obj.class.name 
    c.follow = follow
    c.user_id = user_id
    c
  end

  def root_object
    followable_type.constantize.find(followable_id)
  end
end