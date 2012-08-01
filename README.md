# EfficientTranslations

EfficientTranslations is a translation library for ActiveRecord models in Rails 2

I wrote EfficientTranslations because I'm working on several legacy rails apps with
 performance problems and I cannot migrate to Rails 3.

EfficientTranslations is inspired to both [Globalize2](https://github.com/joshmh/globalize2) (for models architecture: translations are stored in a separated table) and [Puret](https://github.com/jo/puret) (for cache mechanics).


## Requirements

- ActiveSupport 2.3.x
- ActiveRecord  2.3.x


## Architecture

The idea is always the same. One table for model records, another table for model translation records.
This architecture works well if app languages could change in the future and you don't want to add a
column each time a new language is added, or if you have a large number of translations to manage.

EfficientTranslations is designed to reduce the number of queries done to get model+translations and
the amount of data retrieved.

I don't think it's the perfect solution, indeed *I think it's far to be the perfect solution*, but it's a
step forward.


## Translate a Model

To explain the gem usage we'll use the following use case:

    We need a Product model with two localizable fields:
    - name (string)
    - another_field (integer)

### Migrations

You can create the translation table using the helper *create_translation_table*. The following:

    create_table :products do |t|
      t.timestamps
    end
    create_translation_table :products, :name => :string, :another_field => :integer

is equivalent to:

    create_table :products do |t|
      t.timestamps
    end
    create_table :product_translations do |t|
      t.references :products, :null => false
      t.string     :locale  , :null => false
      t.string     :name
      t.integer    :another_field
    end


#### Models

Now we have to modify our Product model as the following:

    class Prouct < ActiveRecord::Base
      translates :name, :another_field
    end

Done! You have the EfficientTranslations power in your hands :-)


## Usage

### Manage Translations
```ruby
    I18n.default_locale = :en
    I18n.locale = :en
    product = Product.new

    # Read translations:

    # use #name_translation to get the translation for requested locale:
    product.name_translation :en # => nil

    # #name is a wrapper to #name_translation for the current locale (I18n.locale):
    product.name # => nil

    # Write translation

    # use #set_name_translation to set the translation for requested locale:
    product.set_name_translation :en, 'Efficient Translations'

    # #name= is a wrapper to  #set_name_translation for the current locale (I18n.locale):
    product.name = 'Efficient Translations'

    # Cached translations

    # Whenever you access a freshly set or retrieved from database translation the
    # cached value is used:
    product.name # => 'Efficient Translations'

    # Retrieve default locale translation, when the current locale translation is missing:
    I18n.locale = :it
    product.name # => 'Efficient Translations'
    product.name_translation # => 'Efficient Translations'

    # Don't retrieve default  locale translation, when the current locale translation is missing:
    product.name! # => nil
    product.name_translation! :it # => nil

    # List all available translations for requested attribute:
    product.name_translations # => { :en => 'Efficient Translations', :it => 'Traduzioni Efficienti' }

    # Save translations to database:
    product.save!

    # Create a product using nested attributes
    Product.create! :translations_attributes => [{:locale => I18n.locale.to_s, :name => 'Another'}]
    Product.last.name # => 'Another'
```
### Validators

The validator *validates_presence_of_default_locale* is provided to prevent a model to be saved without a translation for the default locale. Eg:
```ruby
    class Product < ActiveRecord::Base
      translates :name, :another_field

      validates_presence_of_default_locale
    end
```

### Named Scopes and Performances Overview

Three named scopes are defined:

#### with_translations:
```ruby
    # Fetch products with all translations
    Product.with_translations
```
This will include all the translations record. So in the case you have a product with translations for :en and :it.
```ruby
    p = Product.with_translations.first
    p.name # No sql is executed
    p.name_translation :it # No sql is executed
    p.name_translation :fr # No sql is executed
```
#### with_current_translations:
```ruby
    # Fetch products with translations for I18n.locale or I18n.default_locale
    Product.with_current_translation
```
This scope will fetch only the translations you usually need when you fetch your models.
It's not perfect. Observe the following code to understand why:
```ruby
    Product.create! :translation_attributes => [
      { :locale => :en, :name => 'Product1'  },
      { :locale => :it, :name => 'Prodotto1' }
    ]

    Product.create! :translation_attributes => [
      { :locale => :it, :name => 'Prodotto2' }
    ]

    I18n.locale = :en

    # The second product is not included in the result because it doesn't have the I18n.locale
    # or I18n.default_locale translation
    # To prevent this you can use validates_presence_of_default_locale
    Product.with_current_translation.size # => 1

    p = Product.with_current_translation.first
    p.name # => 'Product1'; No qury is executed because we used the named scope
    # translations collection doesn't contain the 'it' value, so all calls to 'it'
    # translations will return the I18n.default_locale value
    p.name_translation :it # => 'Product2'

    # To fetch the 'it' value you have to do the following:
    p.translations true # reload all translations
    p.name_translation :it # => 'Prodotto1'
```
#### with_translation_for

This scope behaves like *with_current_translation* but it will use, in order, a locale of your choice or I18n.default_locale to fetch the translations
