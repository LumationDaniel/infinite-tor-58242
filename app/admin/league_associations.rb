ActiveAdmin.register LeagueAssociation do
  menu parent: 'Organizations', priority: 0, if: proc { can?(:index, LeagueAssociation) }
  show title: :name
end
