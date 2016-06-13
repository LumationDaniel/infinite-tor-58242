ActiveAdmin.register Announcement do
  menu parent: 'Application', if: proc{ can?(:index, Announcement) }

  scope(:active, default: true) { |announcements| announcements.active.prioritized }
  scope(:retired) { |announcements| announcements.retired.order('retired_at DESC') }

  index do
    id_column
    column :priority
    column :message
    column :created_at
    column :retired_at
    column '' do |resource|
      [
        link_to(I18n.t('active_admin.view'), resource_path(resource), class: "member_link view_link"),
        link_to(I18n.t('active_admin.edit'), edit_resource_path(resource), class: "member_link edit_link"),
        link_to('Retire', retire_admin_announcement_path(resource), class: "member_link delete_link", method: :put, confirm: 'Are you sure?')
      ].join.html_safe
    end
  end

  member_action :retire, :method => :put do
    ann = Announcement.find(params[:id])
    ann.touch(:retired_at)
    redirect_to action: :index, notice: "Retired announcement: ##{params[:id]}"
  end

end
