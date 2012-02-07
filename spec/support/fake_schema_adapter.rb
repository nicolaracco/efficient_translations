module EfficientTranslations
  class FakeSchemaAdapter
    include Schema

    #stubs methods

    def create_table table
    end

    def add_column table, column_name, type
    end

    def add_index table, columns, args = {}
    end
  end
end