class Disease < ActiveRecord::Base
  has_many :phenotypes
end
