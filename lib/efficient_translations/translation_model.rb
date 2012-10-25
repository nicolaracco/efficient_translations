module EfficientTranslations
  module TranslationModel
    extend ActiveSupport::Concern

    included do
      extend ClassMethods

      cattr_accessor :translatable_model, :translatable_relation_field

      attr_accessible :locale

      before_save :stringify_locale!

      scope :for_locale, lambda { |locale| where('locale = ? OR locale = ?', locale.to_s, I18n.locale.to_s) }
    end

    module ClassMethods
      def build_for base_model
        if translatable_model
          raise 'This translation model is already built'
        else
          self.translatable_model = base_model
          self.translatable_relation_field = base_model.table_name.singularize.to_sym

          belongs_to translatable_relation_field, :class_name => self.translatable_model.name

          attr_accessible translatable_relation_field
        end
      end
    end

    private

    def stringify_locale!
      self.locale = locale.to_s
    end
  end
end