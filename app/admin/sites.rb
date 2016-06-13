ActiveAdmin.register Site do
  menu parent: 'Application', if: proc{ can?(:index, Site) }

  show title: :name do |site|
    attributes_table do
      row :id
      row :name
      row :permalink
      row :facebook_app_id
      row :facebook_app_secret
      row :facebook_app_url
      row :facebook_app_access_token
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :permalink, hint: (f.object.new_record? ? 'Optional.  Will be generated from the name' : nil)
      f.input :facebook_app_id
      f.input :facebook_app_secret
      f.input :facebook_app_url
      f.input :facebook_app_access_token
    end
    f.buttons
  end

  controller do
    defaults :finder => :find_by_permalink
  end
end
