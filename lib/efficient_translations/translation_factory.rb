module EfficientTranslations
  module TranslationFactory
    def self.new_model base_model
      if base_model.const_defined?(:Translation)
        base_model.const_get(:Translation)
      else
        klass = base_model.const_set(:Translation, Class.new(::ActiveRecord::Base))
        klass.instance_eval do
          cattr_accessor :translatable_model, :translatable_relation_field
          self.translatable_model = base_model
          self.translatable_relation_field = base_model.name.underscore.gsub '/', '_'

          table_name = "#{base_model.table_name.singularize}_translations"
          belongs_to translatable_relation_field

          named_scope :for_locale, lambda { |locale|
            { :conditions => ['locale = ? OR locale = ?', locale.to_s, I18n.locale.to_s] }
          }

          before_save :stringify_locale!
        end
        klass.class_eval do
          def stringify_locale!
            self.locale = locale.to_s
          end
        end
        klass
      end
    end
  end
end