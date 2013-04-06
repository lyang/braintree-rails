## Unreleased (master)
### Enhancements
  * `BraintreeRails` and its submodules are now eager loadable.
  * `BraintreeRails::CreditCard`'s `number` and `cvv` are now updatable.
  * `country_name`, `country_code_alpha2`, `country_code_alpha3` and `country_code_numeric` are now auto synced.
  * `country_name` validation error message is now more user friendly.
  * Only changed values will be submitted when trying to update a model object.
  * `Model#attributes` now always returns "pure" Hash, which only has symbol keys and string values
  * `BraintreeRails::Address` now has two subclasses, `BraintreeRails::BillingAddress` and `BraintreeRails::ShippingAddress`, which you can have different validation logic added.
  * `BraintreeRails::Configuration.client_side_encryption_key` accessor is added for convenience.
  * `expiration_date`, `expiration_month` and `expiration_year` are no longer cleared after create/update API calls. You get back plain values from the API call anyway. To me, there's even no need to encrypt those.
  * Adding customer validations has a better and simpler way now.

### Bug Fixes
  * Fixed a bug where updating `expiration_date` on a vaulted card is not ignored.

## v1.0.0 (daf2b80), Mon Mar 18 09:17:27 2013 -0700
