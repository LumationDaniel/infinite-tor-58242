class LeagueAssociation < ActiveRecord::Base
  has_many :leagues
  attr_accessible :name, as: :admin
end
