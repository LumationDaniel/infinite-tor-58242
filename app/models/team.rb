class Team < ActiveRecord::Base
  belongs_to :league_association
  attr_accessible :league_association_id, :name, as: :admin
end
