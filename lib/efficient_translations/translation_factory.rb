module EfficientTranslations
  module TranslationFactory
    def self.translation_model_for model
      if model.const_defined? :Translation
        model.const_get :Translation
      else
        model.const_set :Translation, Class.new(ActiveRecord::Base) {include TranslationModel}
      end
    end

    def self.build_translation_model base_model
      translation_model_for(base_model).tap do |klass|
        klass.build_for base_model
      end
    end
  end
end
