class Owner < ActiveRecord::Base
  has_many :pets
end