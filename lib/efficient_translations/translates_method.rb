module EfficientTranslations
  module TranslatesMethod
    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods
      def translates *field_names
        make_efficient_translatable! unless defined?(translation_model)
        field_names.each do |field|
          define_translation_accessors field
        end
      end

      def validates_presence_of_default_locale
        validate :default_locale_required
      end

      private

      def make_efficient_translatable!
        cattr_accessor :translation_model
        self.translation_model = TranslationFactory.build self
        has_many :translations, :class_name => translation_model.name, :dependent => :destroy
        accepts_nested_attributes_for :translations
        after_save :update_translations!

        named_scope :with_translations, :include => :translations
        named_scope :with_current_translation, lambda {
          {
            :include => :translations,
            :conditions => [scope_conditions, I18n.locale.to_s, I18n.default_locale.to_s]
          }
        }
        named_scope :with_translation_for, lambda { |locale|
          {
            :inlude => :translations,
            :conditions => [scope_conditions, locale.to_s, I18n.default_locale.to_s]
          }
        }
      end

      def self.scope_conditions
        "#{translation_model.table_name}.locale = ? OR #{translation_model.table_name}.locale = ?"
      end

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
            translation_field = self.send "#{field}_translation!", locale
            if translation_field
              translation_field
            elsif locale.to_sym != I18n.default_locale
              self.send "#{field}_translation!", I18n.default_locale
            end
          end

          define_method "set_#{field}_translation" do |locale, value|
            locale = locale.to_sym
            efficient_translations_attributes[locale][field] = value
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

          define_method("#{field}_translations") do
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

    # instance methods - no need to put them a module
    private

    # attributes are stored in @efficient_attributes instance variable via setter
    def efficient_translations_attributes
      @efficient_translations_attributes ||= Hash.new { |hash, key| hash[key] = {} }
    end

    def update_translations!
      if efficient_translations_attributes.present?
        translations true # force reload all translations
        efficient_translations_attributes.each do |locale, attributes|
          translation = translations.detect { |t| t.locale.to_sym == locale } || begin
            args = { :locale => locale }
            args[self.class.translation_model.translatable_relation_field] = self
            self.class.translation_model.new args
          end
          translation.update_attributes! attributes
        end
      end
    end

    def default_locale_required
      if efficient_translations_attributes[I18n.default_locale.to_sym].blank? && translations.detect { |t| t.locale.to_sym == I18n.default_locale.to_sym }.nil?
        # people may expect this message to be localized too ;-)
        errors.add :translations, "for #{I18n.default_locale} is missing"
      end
    end
  end
end