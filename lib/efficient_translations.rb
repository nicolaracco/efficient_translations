require 'active_support'
require 'active_record'

dir = File.join File.expand_path(File.dirname __FILE__), 'efficient_translations'
require File.join dir, 'version'
require File.join dir, 'schema'
require File.join dir, 'translation_factory'
require File.join dir, 'translates_method'

::ActiveRecord::ConnectionAdapters::AbstractAdapter.send :include, EfficientTranslations::Schema
::ActiveRecord::Base.send :include, EfficientTranslations::TranslatesMethod