ActiveAdmin.register AdminUser do
  index do
    id_column
    column :email
    column(:site) { |u| u.site.try(:name) }
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    default_actions
  end

  show title: :email

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :site
      f.input :role, as: :select, collection: Ability::ROLES
    end
    f.buttons
  end

  member_action :reset_password, method: :post do
    admin_user = AdminUser.find(params[:id])
    admin_user.send_reset_password_instructions
    redirect_to [:admin, admin_user]
  end

  sidebar :actions, only: :show do
    ul do
      li link_to('Reset Password', reset_password_admin_admin_user_path(resource), method: :post)
    end
  end
end
