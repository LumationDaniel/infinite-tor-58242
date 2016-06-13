ActiveAdmin.register Notification do
  actions :index, :edit, :update, :show

  menu parent: 'Application', if: proc{ can?(:index, Notification) }

  filter :name

  index do
    id_column
    column :name
    column :subject
    default_actions
  end

  show title: :name

  form do |f|
    f.inputs do
      f.input :subject
      f.input :description
    end
    f.buttons
  end
end
