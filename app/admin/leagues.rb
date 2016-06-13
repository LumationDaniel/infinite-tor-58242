ActiveAdmin.register League do
  menu parent: 'Organizations', priority: 2, if: proc{ can?(:index, League) }
  show title: :label

  index do
    id_column
    column :label, sortable: false
    default_actions
  end
end
