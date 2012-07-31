module EfficientTranslations
  module TranslationFactory
    def self.translation_model_for model
      if model.const_defined? :Translation
        model.const_get :Translation
      else
        translation = model.const_set :Translation, Class.new(ActiveRecord::Base)
        translation.send :include, TranslationModel
        translation
      end
    end

    def self.build_translation_model base_model
      klass = translation_model_for base_model
      klass.build_for base_model
      klass
    end
  end
end