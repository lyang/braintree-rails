## Unreleased (master)
### Enhancements
  * Added image_url to credit card readonly attributes. (Thanks, @maxkaplan)

### Bug Fixes
  * Fix propagation of braintree reported errors to associations in merchant accounts. (Thanks, @twalpole)
  * Do not raise exception on gateway rejected transactions. (Thanks, @murtyk)

## v1.4.0 (0830c14), Dec 12 2014
### Enhancements
  * Added `service_fee_amount` to `BraintreeRails::Transaction`. (Thanks, @KELiON)
  * Enhanced validation error parsing so that they can be customized/i18n-ed

### Bug Fixes
  * Fixed deprecation warnings about validator setup. (Thanks, @JWesorick)

## v1.3.0 (74bd8df), Apr 18 2014
### Enhancements
  * Added Braintree Marketplace related models
  * Allow device_data to be passed through for Fraud tools integration

### Bug Fixes
  * Fixed a bug where it failed to load some models under some circumstances. (Thanks, @mbhnyc and @tmak)
  
## v1.2.3 (a9f5bf4), Jan 21 2014
### Enhancements
  * Customer create/update now accepts an optional :credit_card params.

### Bug Fixes
  * Fixed a bug where it failed to update credit card expiry date when only expiration year changed. (Thanks, @vedanova)
  
## v1.2.2 (dc21ba6), Oct 14 2013
### Bug Fixes
  * Fixed gemspec to only package necessary files to reduce the gem file size. (Thanks, @ivankocienski)

## v1.2.1 (370fab4), Jul 01 2013
### Enhancements
  * Make all tests run in Rails 4.0

## v1.2.0 (e993a65), May 31 2013
### Enhancements
  * Make all tests run in ruby 1.9.2
  * Adding `reload` method for all models

### Bug Fixes
  * Fixed a bug where updating a vaulted card with `:options => {:verify_card => true}` is not working.

## v1.1.0 (13033d9), Apr 12 2013
### Enhancements
  * `BraintreeRails` and its submodules are now eager loadable.
  * `BraintreeRails::CreditCard`'s `number` and `cvv` are now updatable.
  * `country_name`, `country_code_alpha2`, `country_code_alpha3` and `country_code_numeric` are now auto synced.
  * `country_name` validation error message is now more user friendly.
  * `Model#attributes` now always returns "pure" Hash, which only has symbol keys and simple values
  * `BraintreeRails::Address` now has two subclasses, `BraintreeRails::BillingAddress` and `BraintreeRails::ShippingAddress`, which you can have different validation logic added.
  * `BraintreeRails::Configuration.client_side_encryption_key` accessor is added for convenience.
  * `expiration_date`, `expiration_month` and `expiration_year` are no longer cleared after create/update API calls. You get back plain values from the API call anyway. To me, there's even no need to encrypt those.
  * Only changed values will be submitted when trying to update a model object.
  * Adding custom validations has a better and simpler way now.

### Bug Fixes
  * Fixed a bug where updating `expiration_date` on a vaulted card is ignored.

## v1.0.0 (daf2b80), Mar 18 2013
