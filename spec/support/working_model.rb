class WorkingModel < ActiveRecord::Base
  translates :name, :content
end

module Sample
  class NamespacedModel < ActiveRecord::Base
  end
end