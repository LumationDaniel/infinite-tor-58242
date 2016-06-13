module Admin
  class BonusPrize
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_accessor :amount, :reason

    def persisted?; false; end
  end
end
