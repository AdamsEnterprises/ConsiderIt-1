#*********************************************
# For the ConsiderIt project.
# Copyright (C) 2010 - 2012 by Travis Kriplean.
# Licensed under the AGPL for non-commercial use.
# See https://github.com/tkriplean/ConsiderIt/ for details.
#*********************************************

class Account < ActiveRecord::Base
  has_many :proposals, :dependent => :destroy
  has_many :points, :dependent => :destroy
  has_many :positions, :dependent => :destroy
  has_many :domains, :dependent => :destroy
  has_many :users, :dependent => :destroy
  has_many :comments, :dependent => :destroy, :class_name => 'Commentable::Comment'

  #TODO: replace with activity gem 
  has_many :activities, :class_name => 'Activity', :dependent => :destroy

  has_many :reflect_bullets, :class_name => 'Reflect::ReflectBullet'
  has_many :reflect_responses, :class_name => 'Reflect::ReflectResponse'

  is_followable

  def host_without_subdomain
    host_with_port.split('.')[-2, 2].join('.')
  end

end
