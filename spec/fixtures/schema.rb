ActiveRecord::Schema.define do
  create_table 'working_models', :force => true do |t|
  end

  create_table 'working_model_translations', :force => true do |t|
    t.integer :working_model_id, :null => false
    t.string  :locale, :null => false
    t.string  :name
    t.string  :content
  end
end