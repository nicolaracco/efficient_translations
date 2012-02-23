module EfficientTranslations
  module TranslationFactory
    def self.build base_model
      if base_model.const_defined? :Translation
        base_model.const_get :Translation
      else
        klass = base_model.const_set :Translation, Class.new(ActiveRecord::Base)
        klass.class_eval do
          table_name = "#{base_model.table_name.singularize}_translations"
          cattr_accessor :translatable_model, :translatable_relation_field
          self.translatable_model = base_model
          self.translatable_relation_field = base_model.model_name.underscore.gsub '/', '_'

          belongs_to translatable_relation_field, :class_name => self.translatable_model.name
          before_save :stringify_locale!

          named_scope :for_locale, lambda { |locale|
            { :conditions => ['locale = ? OR locale = ?', locale.to_s, I18n.locale.to_s] }
          }

          define_method :stringify_locale! do
            self.locale = locale.to_s
          end
        end
        klass
      end
    end
  end
end