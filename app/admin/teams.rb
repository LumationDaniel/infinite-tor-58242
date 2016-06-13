ActiveAdmin.register Team do
  menu parent: 'Organizations', priority: 1, if: proc{ can?(:index, Team) }

  index do
    id_column
    column :name
    column :league_association
    default_actions
  end

  show title: :name
end
