ActiveAdmin.register DisplayOrder do
  menu parent: 'Application', if: proc{ can?(:index, DisplayOrder) }

  scope :leaderboard

  index do
    id_column
    column :label
    column :priority
    column '' do |resource|
      output = []
      output << link_to('Up'  , order_up_admin_display_order_path(resource), method: :put, class: "member_link edit_link") unless resource.first?
      output << link_to('Down', order_down_admin_display_order_path(resource), method: :put, class: "member_link edit_link") unless resource.last?
      output << link_to(I18n.t('active_admin.delete'), resource_path(resource), method: :delete, class: "member_link delete_link")
      output.join.html_safe
    end
  end

  form do |f|
    f.inputs do
      f.input :scope, as: :select, collection: %w(leaderboard)
      f.input :target_id, as: :select
      f.input :priority
      f.input :target_type, as: :hidden
    end
    f.buttons
  end

  member_action :order_up, :method => :put do
    order = DisplayOrder.find(params[:id])
    order.move_higher
    redirect_to action: :index, notice: "Moved up: #{order.label}"
  end

  member_action :order_down, :method => :put do
    order = DisplayOrder.find(params[:id])
    order.move_lower
    redirect_to action: :index, notice: "Moved down: #{order.label}"
  end
end
