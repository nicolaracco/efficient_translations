module EfficientTranslations
  # Holds schema information. To use it, just include its methods
  # and overwrite the apply_schema method
  module Schema
    # Create the translation table for the given model
    # It creates a table named <model_name>_translations
    # translation_fields should contain an Hash that specify
    # the column name to create and its type.
    # eg. create_translation_table :product, :name => :string, :description => :string
    def create_translation_table model_name, translation_fields
      translation_table_name = "#{model_name}_translations"
      create_table translation_table_name do |t|
        t.references model_name, :null => false
        t.string     :locale,    :null => false
      end
      translation_fields.each do |name, type|
        add_column translation_table_name, name.to_s, type.to_sym
      end
      add_index translation_table_name, "#{model_name}_id"
      add_index translation_table_name, ["#{model_name}_id", 'locale'], :unique => true
    end
  end
end