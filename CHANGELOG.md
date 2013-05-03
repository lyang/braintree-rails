## Unreleased (master)
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
