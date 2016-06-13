ActiveAdmin.register FacebookUser do
  actions :index, :show

  scope :all, :default => true
  scope :registered_today
  scope :registered_yesterday

  filter :first_name
  filter :last_name
  filter :email
  filter :created_at
  filter :global_user, as: :select, collection: [['Yes', true], ['No', false]]
  filter :site, as: :select, collection: Site.order(:name)

  index do
    id_column
    column 'Name' do |user|
      link_to user.full_name, [:admin, user]
    end
    column 'Type' do |user|
      statuses = []
      statuses << 'global' if user.global_user?
      user.sites.each { |site| statuses << site.name }
      statuses.map { |s| status_tag(s, :ok) }.join.html_safe
    end
    column 'Registered', sortable: :created_at do |user|
      "#{time_ago_in_words(user.created_at)} ago"
    end
    column 'Last Accessed', sortable: :last_access_at do |user|
      "#{time_ago_in_words(user.last_access_at)} ago"
    end
    column :email
  end

  show title: :full_name do |user|
    attributes_table do
      row :id
      row :facebook_id
      row :full_name
      row :email
      row :link
      row :username
      row :cash do
        number_to_currency(user.cash, precision: 0)
      end
      row :local_rank
      row :global_rank
      row :wins
      row :loses
      row :last_access_at
      row :last_facebook_sync_at
      row :likes_app_page
      row :created_at
      row :updated_at
    end
    panel 'Give Pickoff Cash' do
      active_admin_form_for(Admin::BonusPrize.new, as: 'bonus_prize', url: prize_admin_facebook_user_path, html: { class: 'inline_form' }) do |form|
        form.inputs do
          form.input :amount, as: :number
          form.input :reason, as: :string
        end
        form.actions do
          form.action :submit, :label => 'Give Pickoff Cash', :button_html => { :value => 'Give Pickoff Cash' }
        end
      end
    end
    active_admin_comments
  end

  member_action :prize, method: :post do
    resource.update_cash!(params[:bonus_prize][:amount].to_i, 'bonus_prize', current_admin_user, description: params[:bonus_prize][:reason])
    flash[:notice] = "Bonus prize given to #{resource.full_name}"
    redirect_to [:admin, resource]
  end

  config.csv_builder = ActiveAdmin::CSVBuilder.new.tap do |csv|
    csv.column :id
    csv.column :first_name
    csv.column :last_name
    csv.column :email
    csv.column :created_at
    csv.column :updated_at
    csv.column :cash
    csv.column :global_rank
    csv.column :wins
    csv.column :loses
    csv.column :correct_answers
    csv.column :incorrect_answers
    csv.column :global_user
    csv.column(:sites) { |u| u.sites.map(&:name).join(', ') }
  end
end
