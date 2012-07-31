require 'active_support'
require 'active_record'

root = File.expand_path File.dirname __FILE__

require File.join root, 'active_support/concern'

%W(version schema translation_model translation_factory translates_method).each do |file|
  require File.join root, "efficient_translations/#{file}"
end

::ActiveRecord::ConnectionAdapters::AbstractAdapter.send :include, EfficientTranslations::Schema
::ActiveRecord::Base.send :include, EfficientTranslations::TranslatesMethod