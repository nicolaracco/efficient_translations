require 'spec_helper'
require 'active_record'

describe EfficientTranslations do
  def my_model_class
    Kernel.silence_warnings do
      Object.const_set :MyModel, Class.new(ActiveRecord::Base)
    end
  end

  describe '::translates' do
    it 'should be defined in ActiveRecord::Base' do
      ActiveRecord::Base.should respond_to :translates
    end

    it 'could be invoked specifing multiple attributes' do
      model = my_model_class
      lambda { model.translates :name, :content }.should_not raise_error
    end

    it 'could be invoked multiple times' do
      model = my_model_class
      lambda { model.translates :name }.should_not raise_error
      lambda { model.translates :content }.should_not raise_error
    end

    it 'fills a translated_fields list' do
      model = my_model_class
      model.translates :name
      model.translated_fields.should =~ [:name]
    end
  end

  describe '::validates_presence_of_default_locale' do
    it 'should be defined in ActiveRecord::Base' do
      ActiveRecord::Base.should respond_to :validates_presence_of_default_locale
    end

    it 'should prevent saving a model without default locale' do
      model = my_model_class
      model.translates :name
      model.validates_presence_of_default_locale
      inst = model.new
      lambda { inst.save! }.should raise_error ActiveRecord::RecordInvalid
      inst.set_name_translation I18n.default_locale, nil
      lambda { inst.save! }.should raise_error ActiveRecord::RecordInvalid
      inst.set_name_translation I18n.default_locale, 'pippo'
      lambda { inst.save! }.should_not raise_error
    end
  end

  describe '::WorkingModel' do
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

    describe '::with_current_translation' do
      it 'should return only items with translations for I18n.locale or I18n.default_locale' do
        I18n.locale, I18n.default_locale = :en, :it
        WorkingModel.delete_all
        WorkingModel.create! :translations_attributes => [{:locale => :en, :name => 'pippo'}]
        WorkingModel.create! :translations_attributes => [{:locale => :it, :name => 'pippo'}]
        WorkingModel.create! :translations_attributes => [{:locale => :fr, :name => 'pippo'}]
        WorkingModel.with_current_translation.size.should == 2
      end
    end

    it 'should accept nested attributes' do
      WorkingModel.delete_all
      WorkingModel.create! :translations_attributes => [{ :locale => :en, :name => 'pippo' }]
      WorkingModel.first.name.should == 'pippo'
    end

    shared_examples 'translation finder' do
      context 'when cache contains the translated value' do
        before do
          @model.set_name_translation :en, 'foo'
        end

        it 'should fetch the value from cache' do
          invoke(:en).should == 'foo'
        end
      end

      context 'when cache is empty' do
        it 'should search in the relationship' do
          @model = WorkingModel.find @model.id
          @model.translation_model.create! :working_model => @model, :locale => 'fr', :name => 'frfr'
          invoke(:fr).should == 'frfr'
        end
      end
    end

    describe 'field_translation!' do
      before do
        @model = WorkingModel.new
        @model.set_name_translation :en, 'pippo'
        @model.save!
      end

      def invoke *args
        @model.name_translation! *args
      end

      it_should_behave_like 'translation finder'

      context 'when cache is empty and no value is found' do
        it 'should return nil' do
          invoke(:de).should be_nil
        end
      end
    end

    describe 'field_translation' do
      before do
        @model = WorkingModel.new
        @model.set_name_translation :en, 'pippo'
        @model.save!
      end

      def invoke *args
        @model.name_translation *args
      end

      it_should_behave_like 'translation finder'

      context 'when cache is empty and no value is found' do
        it 'should search for I18n.default_locale if locale != I18n.default_locale' do
          I18n.default_locale = :en
          invoke(:de).should == @model.name_translation(:en)
        end

        it 'should return nil if locale == I18n.default_locale' do
          I18n.default_locale = :de
          invoke(:de).should be_nil
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

    pending 'It uses attr_accessible'
  end
end