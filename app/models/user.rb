class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :ldap_authenticatable, :rememberable, :trackable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :login, :first_name, :last_name, :email, :remember_me
  
  validates_presence_of :login, :first_name, :last_name, :email
  validates_uniqueness_of :login, :case_sensitive => false
  validates_uniqueness_of :email, :case_sensitive => false
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true,
            format: { with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}

  before_save :get_ldap_params

  def get_ldap_params
    logger.debug("get ldap params says self is #{self.inspect}")
    fn = Devise::LdapAdapter.get_ldap_param(self.login,'givenName')
    logger.debug("fn is #{fn.inspect}")
    if fn.nil? then
      self.errors.add(:first_name, "is nil")
    else
      self.first_name = fn
    end
    ln = Devise::LdapAdapter.get_ldap_param(self.login,'sn')
    if ln.nil? then
      self.errors.add(:last_name, "is nil")
    else 
      self.last_name = ln
    end

    email = Devise::LdapAdapter.get_ldap_param(self.login,'mail')
    if email.nil? then
      self.errors.add(:email, "is nil")
    else
      self.email = email
    end
    logger.debug("self at the end is #{self.inspect}")
  end

end
