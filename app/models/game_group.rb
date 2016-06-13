class GameGroup < ActiveRecord::Base
  belongs_to :league
  has_many :games, foreign_key: 'group_id'

  attr_accessible :league_id, :name, :position, :permalink, as: :admin

  alias_attribute :label, :name
  has_permalink :label

  def as_json(options = nil)
    opts = { methods: :label }
    opts.merge!(options)
    super(opts)
  end
end
