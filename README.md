# Welcome to braintree-rails [![Build Status](https://secure.travis-ci.org/lyang/braintree-rails.png)](http://travis-ci.org/lyang/braintree-rails) [![Code Climate](https://codeclimate.com/github/lyang/braintree-rails.png)](https://codeclimate.com/github/lyang/braintree-rails)
braintree-rails is a framework that wraps the official [braintree_ruby](https://github.com/braintree/braintree_ruby) client library and provides ActiveModel compatible models that can be easily fit into an rails app.

BraintreeRails models have the same CRUD interface, can be used in Rails form helpers and url helpers. In addition, it has built in validations and callbacks. Even more, you can customize those quite easily.

## Why braintree-rails
While the official [braintree_ruby](https://github.com/braintree/braintree_ruby) gem is already quite easy to use, it is designed as a general ruby gem with very few dependencies, which is great.

However this generality does translate to a bit of boiler plate code to make it feel like "the rails way" in a rails app. For example, rendering a payment form with api error messages, or custom validations before sending outbound api calls. So, here goes the boiler plate code for your convenience.

In addition to the "railsy" interface, there are also some feature enhancements. For example, you can add custom validations or callbacks to each model.

Last, all braintree-rails uses behind the scenes are only the public APIs the official [braintree_ruby](https://github.com/braintree/braintree_ruby) provides. It does not touch any of the actual http request.

## See It In Action
Before you head back here for detailed documents, I guess most likely you want to see it in actual code.

So here you go: [braintree-rails-example](https://github.com/lyang/braintree-rails-example)

Live demo on Heroku: [http://braintree-rails-example.herokuapp.com/](http://braintree-rails-example.herokuapp.com/)

## Documents
BraintreeRails should not give you any surprises if you have used `ActiveRecord`.

However, I hope you can find some helpful descriptions and explanations at [Documents](https://github.com/lyang/braintree-rails/wiki).

## Questions
If encountered bugs or undesired behaviors, feel free to open an issue with descriptions and reproducible steps.

Better yet, it will be great if you can open an pull requests with descriptions and tests.

Twitter: [@LinYang](https://twitter.com/LinYang)

## Todos
Write better documents.

## Official Braintree ruby client library
Source code: [braintree_ruby](https://github.com/braintree/braintree_ruby)

Guides: [Ruby Client Library](https://www.braintreepayments.com/docs/ruby)
