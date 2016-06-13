class Sites::Facebook::LeaderboardsController < Sites::Facebook::BaseController

  layout 'site'

  skip_before_filter :verify_authenticity_token

end
