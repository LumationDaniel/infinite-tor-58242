ActiveAdmin.register Settings do
  actions :index, :edit, :update

  menu parent: 'Application', if: proc{ can?(:index, Settings) }

  index do
    id_column
    column(:name, sortable: :var) { |setting| setting.var }
    column :value, sortable: true
    column '' do |resource|
      link_to I18n.t('active_admin.edit'), edit_resource_path(resource), class: "member_link edit_link"
    end
  end

  form do |f|
    f.inputs do
      f.input :value, label: f.object.var
    end
    f.buttons
  end

end
