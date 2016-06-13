ActiveAdmin.register Game do
  config.sort_order = 'starts_at_desc'

  scope(:all, default: true) { |games| games.order('starts_at DESC') }
  scope("Today's Games") { |games| games.where(starts_at: [Time.zone.now.beginning_of_day..Time.zone.now.end_of_day]) }
  scope("Awaiting Scores") { |games| games.pending.where('starts_at <= ?', Time.zone.now) }
  scope(:live) { |games| games.live.pending.order(:starts_at) }
  scope(:completed)

  filter :group
  filter :starts_at

  index do
    id_column
    column :title do |game|
      link_to game.title, admin_game_path(game)
    end
    column :group do |game|
      game.group.try(:name) || 'None'
    end
    column :starts_at
    column :completed
    default_actions
  end

  show title: :title do |game|
    default_main_content
    panel 'Audit' do
      table_for game.audits do
        column(:version)
        column(:created_at)
        column(:admin) { |a| a.user.try(:email) }
        column(:action)
        column(:audited_changes)
      end
    end
  end

  form do |f|
    f.inputs "General" do
      f.input :group, collection: GameGroup.order('name').collect { |group| [group.label, group.id] }
      f.input :away_team_rank
      f.input :away_team
      f.input :home_team_rank
      f.input :home_team
      f.input :starts_at, as: :datetime, start_year: Date.today.year - 1
      f.input :live_on, as: :datetime, start_year: Date.today.year - 1
      f.input :cash_prize
    end
    f.inputs "Info" do
      f.input :tv_channel
      f.input :name
      f.input :description, as: :text, input_html: { rows: 3 }
    end
    f.inputs "Game Results" do
      f.input :away_score
      f.input :home_score
      f.input :completed
    end unless f.object.new_record?
    f.buttons
  end
end
