ActiveAdmin.register Question do

  scope_to do
    current_admin_user.site
  end

  scope(:all, default: true) { |q| q.order('locked_on DESC') }
  scope("Today's Questions") { |q| q.where(locked_on: [Time.zone.now.beginning_of_day..Time.zone.now.end_of_day]) }
  scope("Open") { |q| q.pending.where('locked_on <= ?', Time.zone.now) }
  scope(:live) { |games| games.live.pending.order(:locked_on) }
  scope(:completed)

  filter :text
  filter :completed_on
  filter :live_on
  filter :locked_on

  index do
    id_column
    column(:type, sortable: :question_type) { |r| r.question_type.titleize }
    column :text, sortable: true
    column :live_on, sortable: true
    column :locked_on, sortable: true
    default_actions
  end

  show title: lambda { |q| truncate(q.text, length: 70) }

  form do |f|
    unless current_admin_user.site
      f.inputs do
        f.input :site
      end
    end
    if f.object.new_record?
      f.inputs 'Type of Question' do
        f.input :question_type,
            as: :select,
            collection: %w(predictive trivia).map {|v| [v.titleize, v]},
            include_blank: false,
            hint: "Trivia questions are questions where the answers are known (<b>Who was the head coach in 2010?</b>), while predictive questions await for a specific outcome (<b>Who will be MVP in tomorrow night's game?</b>)".html_safe
      end
    end
    f.inputs do
      f.input :text
      f.input :live_on
      f.input :locked_on
      f.input :cash_prize
      f.input :completed, as: :boolean
    end
    if f.object.answers.any?
      f.object.answers.build
    else
      4.times { |i| f.object.answers.build }
    end
    f.inputs :for => :answers do |answer, i|
      answer.input :text,
        input_html: { class: 'limited', maxlength: 35 },
        label: "Answer ##{i}",
        hint: "chars left: ".html_safe + content_tag(:span, "10", class: 'chars-left')
      answer.input :right_answer
    end
    f.buttons
  end

  before_create do |question|
    question.creator = current_admin_user
    question.site  ||= current_admin_user.site
  end

  controller do
    def build_resource
      super.tap do |question|
        question.locked_on ||= 1.week.from_now.beginning_of_day
      end
    end
  end
end
