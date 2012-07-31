require 'spec_helper'

module EfficientTranslations
  describe TranslationModel do
    it 'is included in WorkingModel' do
      WorkingModel::Translation.included_modules.should include TranslationModel
    end

    it 'defines a stringify_locale! method' do
      instance = WorkingModel::Translation.new :locale => :us
      expect {
        instance.send :stringify_locale!
      }.to change(instance, :locale).to 'us'
    end

    it 'defines a translatable_model reader' do
      WorkingModel::Translation.translatable_model.should == WorkingModel
    end

    it 'defines a translatable_relation_field reader' do
      WorkingModel::Translation.translatable_relation_field.should == :working_model
    end

    it 'defines a for_locale named_scope' do
      WorkingModel::Translation.should respond_to :for_locale
    end

    it 'defines a before_save filter to force the locale in string' do
      WorkingModel::Translation.before_save_callback_chain.map(&:method).should include :stringify_locale!
    end
  end
end