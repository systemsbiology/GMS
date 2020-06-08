require 'will_paginate/array'

class ApplicationController < ActionController::Base
  include ActionController::MimeResponds
  #rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
  #  render :text => exception, :status => 500
  #end
  #protect_from_forgery

  #rescue_from CanCan::AccessDenied do |exception|
  #  flash[:error] = "Access Denied"
  #  redirect_to root_url
  #end
end
