require 'spec_helper'

module EfficientTranslations
  describe TranslatableModel do
    it 'is included in WorkingModel' do
      WorkingModel.included_modules.should include TranslatableModel
    end

    it 'defines a translation model accessor' do
      WorkingModel.translation_model.should == WorkingModel::Translation
    end

    it 'defines a translated_fields accessor' do
      WorkingModel.should respond_to :translated_fields
    end

    it 'defines an has_many relationship with its translation child' do
      WorkingModel.new.should respond_to :translations
    end

    it 'defines an after_save callback to update translations' do
      WorkingModel.after_save_callback_chain.map(&:method).should include :update_translations!
    end

    it 'defines some named scopes' do
      %w(with_translations with_current_translation with_translation_for).each do |m|
        WorkingModel.should respond_to m
      end
    end

    context '#default_locale_presence_validation' do
      context 'when default locale does not exist' do
        it 'adds an error' do
          model = WorkingModel.new
          model.send :default_locale_presence_validation
          model.errors.should_not be_empty
        end
      end

      context 'when default locale exist' do
        it 'does not add an error' do
          model = WorkingModel.new
          model.set_name_translation I18n.default_locale, 'w'
          model.set_content_translation I18n.default_locale, 'w'
          model.send :default_locale_presence_validation
          model.errors.should be_empty
        end
      end
    end
  end
end