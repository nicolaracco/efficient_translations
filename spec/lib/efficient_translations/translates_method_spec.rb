require 'spec_helper'
require 'active_record'

describe EfficientTranslations do
  describe '::translates' do
    def model_class
      Kernel.silence_warnings do
        model = Kernel.const_set :MyModel, Class.new(ActiveRecord::Base)
      end
    end

    it 'should be defined in ActiveRecord::Base' do
      ActiveRecord::Base.should respond_to :translates
    end

    it 'could be invoked specifing multiple attributes' do
      model = model_class
      lambda { model.translates :name, :content }.should_not raise_error
    end

    it 'could be invoked multiple times' do
      model = model_class
      lambda { model.translates :name }.should_not raise_error
      lambda { model.translates :content }.should_not raise_error
    end

    it 'should generate the translation model the first time it\'s invoked' do
      model = model_class
      model.should_receive :make_efficient_translatable!
      model.translates :name
    end

    it 'should not regenerate the translation model when called multiple times' do
      model = model_class
      model.translates :name
      model.should_not_receive :make_efficient_translatable!
      model.translates :content
    end
  end

  context '::WorkingModel' do
    it 'should include the translation model' do
      WorkingModel.translation_model.should be_kind_of(Class)
    end

    it 'should include the translations relationship' do
      WorkingModel.new.should respond_to :translations
    end

    it 'should have some utility named scopes' do
      WorkingModel.should respond_to :with_translations
      WorkingModel.should respond_to :with_current_translation
      WorkingModel.should respond_to :with_translation_for
    end

    it 'should accept nested attributes' do
      WorkingModel.delete_all
      WorkingModel.create! :translations_attributes => [{ :locale => :en, :name => 'pippo' }]
      WorkingModel.first.name.should == 'pippo'
    end

    describe 'field_translation' do
      before do
        @model = WorkingModel.new
        @model.set_name_translation :en, 'pippo'
        @model.save!
      end

      context 'when cache contains the translated value' do
        before do
          @model.set_name_translation :en, 'foo'
        end

        it 'should fetch the value from cache' do
          @model.name_translation(:en).should == 'foo'
        end
      end

      context 'when cache is empty' do
        it 'should search in the relationship' do
          @model = WorkingModel.find @model.id
          @model.translation_model.create! :working_model_id => @model.id, :locale => 'fr', :name => 'frfr'
          @model.name_translation(:fr).should == 'frfr'
        end
      end

      context 'when cache is empty and no value is found' do
        it 'should search for I18n.default_locale if locale != I18n.default_locale' do
          I18n.default_locale = :en
          @model.name_translation(:de).should == @model.name_translation(:en)
        end

        it 'should return nil if locale == I18n.default_locale' do
          I18n.default_locale = :de
          @model.name_translation(:de).should be_nil
        end
      end
    end

    describe 'set_field_translation' do
      it 'should only set values in a cache, until save' do
        model = WorkingModel.create!
        model.set_name_translation :en, 'pippo'
        model.translation_model.find_all_by_working_model_id(model.id).should be_empty
        model.save!
        model.translation_model.find_all_by_working_model_id(model.id).should_not be_empty
      end
    end

    describe 'field accessor' do
      it '<field> should be a wrapper for <field>_translation' do
        model = WorkingModel.new
        model.should_receive(:name_translation).with(:en)
        I18n.locale = :en
        model.name
      end

      it '<field>= should be a wrapper for set_<field>_translation' do
        model = WorkingModel.new
        model.should_receive(:set_name_translation).with(:en, 'pippo')
        I18n.locale = :en
        model.name = 'pippo'
      end
    end
  end
end