module CashActivityAggregation
  def sort_order(chain)
    if action_name == 'aggregate' and request.format == 'text/csv'
      chain.order('amount DESC')
    else
      super
    end
  end
end

ActiveAdmin.register CashActivity do
  actions :index

  filter :codes, as: :string
  filter :game_id, as: :numeric
  filter :question_id, as: :numeric
  filter :created_at
  filter :for_group, as: :select, collection: lambda { |t| GameGroup.order('created_at DESC') }
  filter :user_first_name, as: :string
  filter :user_last_name, as: :string
  filter :user_id, as: :numeric

  config.sort_order = 'created_at_desc'

  index do
    column :id
    column :created_at
    column 'Name' do |activity|
      link_to(activity.user.full_name, [:admin, activity.user]) if activity.user
    end
    column :amount
    column :code
    column '' do |activity|
      if activity.game
        link_to(activity.game.title, [:admin, activity.game])
      elsif activity.question
        link_to(activity.question.text, [:admin, activity.question])
      else
        activity.description
      end
    end
  end

  sidebar :actions, only: :index do
    if request.query_string.blank?
      p 'Filter the activities result to get a aggregate data report.'
    else
      link_to 'Aggregate CSV', "#{aggregate_admin_cash_activities_path(format: :csv)}?#{request.query_string}"
    end
  end

  collection_action :aggregate do
    respond_with do |format|
      format.csv do
        csv_filename = "#{resource_collection_name.to_s.gsub('_', '-')}-aggregate-#{Time.now.strftime("%Y-%m-%d")}.csv"
        headers['Content-Type'] = 'text/csv; charset=utf-8'
        headers['Content-Disposition'] = %{attachment; filename="#{csv_filename}"}

        @aggregate = collection.select("user_id AS id, first_name, last_name, email, SUM(amount) AS amount").
                                joins(:user).group('user_id, first_name, last_name, email')
      end
    end
  end

  config.csv_builder = ActiveAdmin::CSVBuilder.new.tap do |csv|
    csv.column :id
    csv.column :created_at
    csv.column(:first_name) { |a| a.user.first_name }
    csv.column(:last_name) { |a| a.user.last_name }
    csv.column(:email) { |a| a.user.email }
    csv.column :amount
    csv.column :code
    csv.column(:game) { |a| a.game.try(:title) }
  end

  controller do
    include CashActivityAggregation
  end
end
