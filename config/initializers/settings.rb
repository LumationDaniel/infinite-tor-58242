if Settings.table_exists?
  Settings[:cash_per_win] ||= 10
  Settings[:starting_cash] ||= 2000
  Settings[:reward_invite_cash] ||= 1000
  Settings[:daily_bonus_like_bonus_percentage] ||= 0.5

  Settings[:company_name] ||= 'Pickoff Sports'
  Settings[:address] ||= 'PO Box 8262'
  Settings[:city] ||= 'Atlanta'
  Settings[:state] ||= 'GA'
  Settings[:postal_code] ||= '31106'
end
