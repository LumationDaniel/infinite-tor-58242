ActiveAdmin.register GameGroup do
  show title: :name

  controller do
    def resource
      if params[:id]
        end_of_association_chain.find_by_permalink!(params[:id])
      else
        GameGroup.new
      end
    end
  end
end
