module Fb::LeaderboardsHelper
  def sort_link(title, sort_by, tip = nil)
    opts = {
      :class => 'sort',
      'data-sort-by' => sort_by,
      'data-sort-direction' => (@sort == sort_by && @sort_direction == 'd' ? 'a' : 'd')
    }

    opts.merge!(
      :title => title,
      'data-content' => tip,
      'data-placement' => 'left'
    ) if tip

    link_to title, '#', opts
  end
end
