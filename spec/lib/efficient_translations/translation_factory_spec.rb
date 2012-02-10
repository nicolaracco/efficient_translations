require 'spec_helper'

describe EfficientTranslations::TranslationFactory do
  before :each do
    Kernel.silence_warnings do
      @model_class = Kernel.const_set :MyModel, Class.new(ActiveRecord::Base)
    end
  end

  describe '::build' do
    context 'when no translation model is found' do
      before do
        @klass = Class.new(ActiveRecord::Base)
        @model_class.stub :const_set => @klass
      end

      it 'should create a new ::Translation class' do
        @model_class.should_receive(:const_set).with(:Translation, kind_of(Class)) { |name, klass| klass }
        EfficientTranslations::TranslationFactory::build @model_class
      end

      it 'should define a belongs_to association to the main model' do
        @klass.should_receive(:belongs_to)
        EfficientTranslations::TranslationFactory::build @model_class
      end

      it 'should assign the translatable model in an accessor' do
        translation = EfficientTranslations::TranslationFactory::build @model_class
        translation.translatable_model.should == @model_class
      end

      it 'should assign the translatable model field in an accessor' do
        translation = EfficientTranslations::TranslationFactory::build @model_class
        translation.translatable_relation_field.should == @model_class.name.underscore.gsub('/','_')
      end

      it 'should return the created translation class' do
        klass = Class.new(ActiveRecord::Base)
        @model_class.stub :const_set => klass
        EfficientTranslations::TranslationFactory::build(@model_class).should == klass
      end
    end

    context 'when a translation model is found' do
      it 'should not create a ::Translation class' do
        EfficientTranslations::TranslationFactory::build @model_class
        @model_class.should_not_receive(:const_set)
        EfficientTranslations::TranslationFactory::build @model_class
      end

      it 'should return the already defined translation class' do
        klass = Class.new(ActiveRecord::Base)
        @model_class.stub :const_set => klass
        EfficientTranslations::TranslationFactory::build @model_class
        EfficientTranslations::TranslationFactory::build(@model_class).should == klass
      end
    end
  end
end