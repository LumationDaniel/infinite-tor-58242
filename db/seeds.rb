# See https://github.com/rails/rails/blob/59f7780a3454a14054d1d33d9b6e31192ab2e58b/activemodel/lib/active_model/mass_assignment_security/sanitizer.rb
# Allow mass assignment in seeds.rb
module ActiveModel
  module MassAssignmentSecurity
    Sanitizer.class_eval do
      def sanitize(attributes, authorizer)
        attributes
      end
    end
  end
end

# Admin user
AdminUser.create! email: 'test@test.com',
                  password: 'test123',
                  password_confirmation: 'test123'

# Announcement
Announcement.create! message: 'This is a test announcement'

# League Associations
nfl  = LeagueAssociation.create! name: 'NFL'
ncaa = LeagueAssociation.create! name: 'NCAA'

# Leagues
nfl_football    = League.create! league_association: nfl , sport: 'Football'
ncaa_football   = League.create! league_association: ncaa, sport: 'Football'
ncaa_basketball = League.create! league_association: ncaa, sport: 'Basketball'

# Teams
gatech  = Team.create! league_association: ncaa, name: 'Georgia Tech'
vatech  = Team.create! league_association: ncaa, name: 'Virginia Tech'
bc      = Team.create! league_association: ncaa, name: 'Boston College'
wake    = Team.create! league_association: ncaa, name: 'Wake Forest'
miami   = Team.create! league_association: ncaa, name: 'Miami'
unc     = Team.create! league_association: ncaa, name: 'North Carolina'
ncstate = Team.create! league_association: ncaa, name: 'NC State'
fsu     = Team.create! league_association: ncaa, name: 'Florida State'

falcons     = Team.create! league_association: nfl, name: 'Atlanta Falcons'
panthers    = Team.create! league_association: nfl, name: 'Carolina Panthers'
saints      = Team.create! league_association: nfl, name: 'New Orlean Saints'
bunccaneers = Team.create! league_association: nfl, name: 'Tampa Bay Buccaneers'
colts       = Team.create! league_association: nfl, name: 'Indianapolis Colts'
texans      = Team.create! league_association: nfl, name: 'Houston Texans'
titans      = Team.create! league_association: nfl, name: 'Tennessee Titans'
jaguars     = Team.create! league_association: nfl, name: 'Jacksonville Jaguars'

# Game Groups
nfl_pre    = GameGroup.create! league: nfl_football   , name: "#{Date.today.year} Preseason"
nfl_reg    = GameGroup.create! league: nfl_football   , name: "#{Date.today.year} Regular Season"
ncaafb_reg = GameGroup.create! league: ncaa_football  , name: "#{Date.today.year} Regular Season"
ncaabb_reg = GameGroup.create! league: ncaa_basketball, name: "#{Date.today.year} Regular Season"

# Games
Game.create! group: nfl_pre, home_team: falcons, away_team: colts , starts_at: 2.hour.from_now
Game.create! group: nfl_pre, home_team: texans , away_team: saints, starts_at: 2.hour.from_now

Game.create! group: ncaafb_reg, home_team: gatech, away_team: fsu, starts_at: 1.week.from_now, tv_channel: 'ABC', name: 'Homecoming Game'

