module EfficientTranslations
  module TranslatableModel
    extend ActiveSupport::Concern

    included do
      def self.translation_model_table
        translation_model.table_name
      end

      # Translation Model
      cattr_accessor :translation_model, :translated_fields
      self.translation_model = TranslationFactory.build_translation_model self

      # Relationships
      has_many :translations, :class_name => translation_model.name, :dependent => :delete_all
      accepts_nested_attributes_for :translations

      # Callbacks
      after_save :update_translations!

      # Scopes
      named_scope :with_translations, :include => :translations
      named_scope :with_current_translation, lambda {
        {
          :include => :translations,
          :conditions => [
            "#{translation_model_table}.locale = ? OR #{translation_model_table}.locale = ?",
            I18n.locale.to_s, I18n.default_locale.to_s
          ]
        }
      }
      named_scope :with_translation_for, lambda { |locale|
        {
          :inlude => :translations,
          :conditions => [
            "#{translation_model_table}.locale = ? OR #{translation_model_table}.locale = ?",
            locale.to_s, I18n.default_locale.to_s
          ]
        }
      }
    end

    private

    def default_locale_presence_validation
      locale = I18n.default_locale.to_sym
      translation = efficient_translations_attributes[locale] || translations.detect { |t| t.locale.to_sym == locale }
      self.class.translated_fields.each do |field|
        # people may expect this message to be localized too ;-)
        errors.add field, "for #{I18n.default_locale} is missing" if translation[field].blank?
      end
    end

    # attributes are stored in @efficient_attributes instance variable via setter
    def efficient_translations_attributes
      @efficient_translations_attributes ||= Hash.new { |hash, key| hash[key] = {} }
    end

    def update_translations!
      if efficient_translations_attributes.present?
        translations true # force reload all translations
        efficient_translations_attributes.each do |locale, attributes|
          translation = translations.detect { |t| t.locale.to_sym == locale }
          translation ||= begin
            self.class.translation_model.new({
              :locale => locale,
              translation_model.translatable_relation_field => self
            })
          end
          translation.update_attributes! attributes
        end
      end
    end
  end
end
