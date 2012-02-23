require 'spec_helper'

describe EfficientTranslations::Schema do
  let(:schema) { EfficientTranslations::FakeSchemaAdapter.new }

  describe '#create_translation_table' do
    it 'should create a table named <model>_translations' do
      schema.should_receive(:create_table).with('pippo_translations')
      schema.create_translation_table 'pippo', :name => :string
    end

    it 'should use the singular form for model name' do
      schema.should_receive(:create_table).with('product_translations')
      schema.create_translation_table 'products', :name => :string
    end

    it 'should create the given translation columns' do
      schema.should_receive(:add_column).with('pippo_translations', 'name', :string)
      schema.create_translation_table 'pippo', :name => :string
    end

    it 'should create indexes' do
      schema.should_receive(:add_index).twice
      schema.create_translation_table 'pippo', :name => :string
    end
  end
end