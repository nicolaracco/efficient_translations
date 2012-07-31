require 'spec_helper'

module EfficientTranslations
  describe TranslationFactory do
    before :each do
      Kernel.silence_warnings do
        @model_class = Object.const_set :MyModel, Class.new(ActiveRecord::Base)
      end
    end

    describe '::translation_model' do
      context "the first time it's invoked on a model" do
        it 'defines the translation model' do
          expect { @model_class.const_get :Translation }.to raise_error NameError
          TranslationFactory.translation_model_for @model_class
          expect { @model_class.const_get :Translation }.to_not raise_error NameError
        end

        it 'includes the TranslationModel module in the translation model' do
          TranslationFactory.translation_model_for(@model_class).included_modules.should include TranslationModel
        end
      end

      it 'returns the existing translation_model' do
        t = TranslationFactory.translation_model_for @model_class
        TranslationFactory.translation_model_for(@model_class).should == t
      end
    end

    describe '::build_translation_model' do
      before { @translation_model = TranslationFactory.translation_model_for @model_class }

      context 'when translation model is not built' do
        it 'sets translatable model reader' do
          @translation_model.translatable_model.should be_nil
          TranslationFactory.build_translation_model @model_class
          @translation_model.translatable_model.should == @model_class
        end

        it 'sets translatable relation field reader' do
          @translation_model.translatable_relation_field.should be_nil
          TranslationFactory.build_translation_model @model_class
          @translation_model.translatable_relation_field.should == :my_model
        end
      end

      context 'when translation model is already built' do
        it 'raises an error' do
          TranslationFactory.build_translation_model(@model_class)
          TranslationFactory.translation_model_for(@model_class).should_not_receive(:belongs_to)
          expect {
            TranslationFactory.build_translation_model @model_class
          }.to raise_error
        end
      end
    end
  end
end