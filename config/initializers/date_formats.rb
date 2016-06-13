Time::DATE_FORMATS[:short_ordinal] = lambda { |time| time.strftime("%b #{time.day.ordinalize}, %l:%M %p ET") }
