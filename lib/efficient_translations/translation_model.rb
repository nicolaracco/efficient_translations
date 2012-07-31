module EfficientTranslations
  module TranslationModel
    extend ActiveSupport::Concern

    module ClassMethods
      def build_for base_model
        if translatable_model
          raise 'This translation model is already built'
        else
          self.translatable_model = base_model
          self.translatable_relation_field = base_model.table_name.singularize.to_sym

          belongs_to translatable_relation_field, :class_name => self.translatable_model.name
        end
      end
    end

    included do
      extend ClassMethods

      cattr_accessor :translatable_model, :translatable_relation_field

      before_save :stringify_locale!

      named_scope :for_locale, lambda { |locale|
        { :conditions => ['locale = ? OR locale = ?', locale.to_s, I18n.locale.to_s] }
      }
    end

    private

    def stringify_locale!
      self.locale = locale.to_s
    end
  end
end