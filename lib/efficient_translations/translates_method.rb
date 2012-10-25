module EfficientTranslations
  module TranslatesMethod
    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods
      def translates *field_names
        include TranslatableModel unless included_modules.include? TranslatableModel
        self.translated_fields = field_names
        translation_model.attr_accessible *field_names
        field_names.each do |field|
          define_translation_accessors field
        end
      end

      def validates_presence_of_default_locale
        validate :default_locale_presence_validation
      end

      private

      def define_translation_accessors field
        field = field.to_sym
        class_eval do
          define_method "#{field}_translation!" do |locale|
            locale = locale.to_sym
            # search in cache
            if efficient_translations_attributes[locale][field]
              efficient_translations_attributes[locale][field]
            else
              # search in relationship
              translation = translations.detect { |t| t.locale.to_sym == locale }
              translation && translation[field] || nil
            end
          end

          define_method "#{field}_translation" do |locale|
            translation_field = send "#{field}_translation!", locale
            if translation_field
              translation_field
            elsif locale.to_sym != I18n.default_locale
              send "#{field}_translation!", I18n.default_locale
            end
          end

          define_method "set_#{field}_translation" do |locale, value|
            efficient_translations_attributes[locale.to_sym][field] = value
          end

          define_method field do
            self.send "#{field}_translation", I18n.locale
          end

          define_method "#{field}!" do
            self.send "#{field}_translation!", I18n.locale
          end

          define_method "#{field}=" do |value|
            self.send "set_#{field}_translation", I18n.locale, value
          end

          define_method "#{field}_translations" do
            found = {}
            efficient_translations_attributes.each do |locale, translation|
              found[locale] = translation[field]
            end
            translations.inject(found) do |memo, translation|
              memo[translation.locale.to_sym] ||= translation[field]
              memo
            end
          end
        end
      end
    end
  end
end