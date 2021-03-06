#*********************************************
# For the ConsiderIt project.
# Copyright (C) 2010 - 2012 by Travis Kriplean.
# Licensed under the AGPL for non-commercial use.
# See https://github.com/tkriplean/ConsiderIt/ for details.
#*********************************************

require 'open-uri'
require 'role_model'

class User < ActiveRecord::Base
  include RoleModel

  has_many :points, :dependent => :destroy
  has_many :positions, :dependent => :destroy
  has_many :inclusions, :dependent => :destroy
  has_many :point_listings, :dependent => :destroy
  has_many :point_similarities, :dependent => :destroy
  has_many :comments, :dependent => :destroy, :class_name => 'Commentable::Comment'
  has_many :proposals
  has_many :follows, :dependent => :destroy, :class_name => 'Followable::Follow'

  acts_as_tenant(:account)
  #attr_taggable :tags
  is_trackable
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :omniauthable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable

  validates :email, :uniqueness => {:scope => :account_id}, :format => Devise.email_regexp, :allow_blank => true

  attr_accessible :name, :bio, :email, :password, :password_confirmation, :remember_me, :avatar, :registration_complete, :roles_mask

  attr_accessor :avatar_url, :downloaded

  before_validation :download_remote_image, :if => :avatar_url_provided?
  #validates_presence_of :avatar_remote_url, :if => :avatar_url_provided?, :message => 'is invalid or inaccessible'
  after_create :add_token

  roles :superadmin, :admin, :analyst, :moderator, :manager, :evaluator, :developer

  has_attached_file :avatar, 
      :styles => { 
        :medium => "70x70#", 
        #:medium_dark => "70x70#",
        :small => "50x50#"
      }

  def unsubscribe!
    self.follows.update_all( {:explicit => true, :follow => false} )
  end

  def send_on_create_confirmation_instructions
    #don't deliver confirmation instructions. We will wait for them to submit a position. 
    #self.devise_mailer.confirmation_instructions(self).deliver
  end

  def is_admin?
    has_any_role? :admin, :superadmin
  end

  def role_list
    if roles_mask == 0
      return '-'
    else
      lst = []
      roles.each do |role|
        lst.push(role.to_s)
      end
      lst.join(', ').gsub(':', '')
    end
  end

  def third_party_authenticated?
    if !self.facebook_uid.nil?
      'facebook' 
    elsif !self.google_uid.nil?
      'google'
    elsif !self.twitter_uid.nil?
      'twitter'
    end
  end

  def avatar_url_provided?
    !self.avatar_url.blank?
  end

  def download_remote_image
    if self.downloaded.nil?
      self.downloaded = true
      self.avatar_url = self.avatar_remote_url if avatar_url.nil?
      io = open(URI.parse(self.avatar_url))
      def io.original_filename; base_uri.path.split('/').last; end
      self.avatar = io if !(io.original_filename.blank?)
      self.avatar_remote_url = avatar_url
      self.avatar_url = nil
    end
  end

  def self.find_for_third_party_auth(access_token, signed_in_resource=nil)
    case access_token.provider
      when 'twitter'
        user = User.find_by_twitter_uid(access_token.uid)
        if user
          user.twitter_uid = access_token.uid
        end

      when 'facebook'
        user = User.find_by_facebook_uid(access_token.uid) || User.find_by_email(access_token.info.email)
        if user
          user.facebook_uid = access_token.uid
        end

      when 'google'
        user = User.find_by_google_uid(access_token.uid) || User.find_by_email(access_token.info.email)
        if user
          user.google_uid = access_token.uid
        end
      else  
        user = User.find_by_email(access_token.info.email)
    end

    if not user
      user = User.new do |u|
        u.password = Devise.friendly_token[0,20]
                
        case access_token.provider
          when 'google'
            u.name = access_token.info.name
            u.google_uid = access_token.uid
            u.email = access_token.info.email
          when 'twitter'
            u.name = access_token.info.name
            u.twitter_uid = access_token.uid
            u.bio = access_token.info.description
            u.url = access_token.info.urls.Website ? access_token.info.urls.Website : access_token.info.urls.Twitter
            u.twitter_handle = access_token.info.nickname
            u.avatar_url = access_token.info.image

          when 'facebook'
            u.name = access_token.info.name
            u.email = access_token.info.email
            u.facebook_uid = access_token.uid
            u.url = access_token.info.urls.Website ? access_token.info.urls.Website : access_token.info.urls.Twitter
            u.avatar_url = 'http://graph.facebook.com/' + access_token.uid + '/picture?type=large'
          else
            raise 'Unsupported provider'
        end
      end

      pp user
      user.skip_confirmation!
      user.save
      user.track!
    else
      user.save
    end

    user
  end

  def email_required? 
    twitter_uid.nil?
  end   

  def username
    name ? 
      name
      : email ? 
        email.split('@')[0]
        : "#{account.app_title} participant"
  end
  
  def first_name
    username.split(' ')[0]
  end

  def last_name
    username.split(' ').last
  end

  def short_name
    split = username.split(' ')
    if split.length > 1
      return "#{split[0][0]}. #{split[-1]}"
    end
    return split[0]  
  end

  def add_token
    self.unique_token = SecureRandom.hex(10)
    self.save
  end

  def self.add_token
    User.where(:unique_token => nil).each do |u|
      u.unique_token
    end
  end     
      
end
