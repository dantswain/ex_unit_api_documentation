# ExUnitApiDocumentation

ExUnit API Documentation generator, inspired by
[rspec_api_documentation](https://github.com/zipmark/rspec_api_documentation).

This is still very much in the early stages of work.

The basic idea is to integrate with
[HttPoison](https://github.com/edgurgel/httpoison) so that each HTTP
request and its response gets stored.  Then, at the end of your test
suite, you call `ExUnitApiDocumentation.write_json`, which dumps all
of the request/response data to a json file.  In conjunction with
this, `ExUnitApiDocumentation.DocsController` serves up the data in a
nice format in the browser.

The basic approach to integration testing that this assumes is the one
I documented here:
[Integration Testing a JSON API in Phoenix](http://www.dantswain.com/blog/2015/04/19/integration-testing-a-json-api-in-phoenix/).

See
[ex_unit_api_documentation_test_app](http://github.com/dantswain/ex_unit_api_documentation_test_app)
for an example of usage and setup.

## Status

The documentation engine is mostly working in a basic sense.  The HTTP
requests are collected and dumped to a json file.  There is currently
no support for explanation or other annotations.

Serving of the documentation is currently only working in a
proof-of-concept sense.  The '/docs' page has no styling and the
documentation json is displayed raw.

I'm sure that the way I've accomplished some things, especially around
the setup needed for documentation serving, is suboptimal.  If you
know Phoenix well and have suggestions, I would be most appreciative!

## Usage

First, add `ex_unit_api_documentation` to your mix.exs file both as a
dependendency and as an application to start:

    # in mix.exs

    def application do
      [
        ...
        applications: [..., :ex_unit_api_documentation]
      ]
    end

    defp deps do
      [
       ...
       {:ex_unit_api_documentation, github: "dantswain/ex_unit_api_documentation"},
       ...
      ]
    end

Next, add an API endpoint helper for your test suite.  This is a
module that should include `use HTTPoison.Base`, a function to launch
your API, and a call to `ExUnitApiDocumentation.document/5` within the
`execute_request` function.  See
[api.ex](https://github.com/dantswain/ex_unit_api_documentation_test_app/blob/master/test/support/api.ex)
in
[ex_unit_api_documentation_test_app](http://github.com/dantswain/ex_unit_api_documentation_test_app)
for an example.

**Note** ExUnitApiDocumentation uses a fork of HTTPoison that allows
  an override of the `execute_request` function.  I have a
  [pull request](https://github.com/edgurgel/httpoison/pull/51) open
  for this.

Next, write your tests.  Here is an example.

    defmodule ExUnitApiDocumentationTestApp.ApiTest do
      use ExUnit.Case
      
      alias ExUnitApiDocumentationTestApp.Support.API
      
      setup_all do
        API.launch
        
        ExUnitApiDocumentation.start
        ExUnitApiDocumentation.start_doc("api")
        
        on_exit fn ->
          # actually write out the docs
          ExUnitApiDocumentation.write_json
        end
      end
      
      test "GET /" do
        got = API.get!("/")
        assert got.status_code == 200
      end
    end

The important points of the example are

* Call `API.launch` in `setup_all` - This enables the web serving
  aspect of your API during tests.
* `ExUnitApiDocumentation.start` and
  `ExUnitApiDocumentation.start_doc("api")` in `setup_all` - This
  starts the documentation engine listening and gives it a heading
  name ("api") for this test file.
* `ExUnitApiDocumentation.write_json` in the `on_exit` callback - This
  causes the documentation to be written out at the end of the tests.
* Use your API endpoint helper for all HTTP calls during tests.  This
  is how ExUnitApiDocumentation collects the documentation data.

## Serving test documentation

Add `ex_unit_api_documentation` to your 'brunch-config.js' file.  This
makes the documentation driver ('docs.js') available to your
application.

    // in brunch-config.js
    
    // Phoenix paths configuration
    paths: {
      // Dependencies and current project directories to watch
      watched: ["deps/phoenix/web/static",
        "deps/phoenix_html/web/static",
        "web/static", "test/static",
        "deps/ex_unit_api_documentation/web/static"], // <- add this
    
      // Where to compile files to
      public: "priv/static"
    },

Add 'docs' to the static plug in your 'endpoint.ex'.  This makes the
documentation output available to your application's static asset
server. 

    # in endpoint.ex

    plug Plug.Static,
    at: "/", from: :ex_unit_api_documentation_test_app, gzip: false,
        only: ~w(css fonts images js favicon.ico robots.txt docs)

Import the documentation driver in your 'web/static/js/app.js'.  This
makes the documentation driver execute when the docs page loads.

    // in web/static/js/app.js
    import "deps/ex_unit_api_documentation/web/static/js/docs"

Add the '/docs' namespace to your router.ex.  This makes it so that
when someone navigates to '/docs', it loads the necessary code from
ExUnitApiDocumentation.

    # in router.ex
    scope "/docs", ExUnitApiDocumentation do
      pipe_through :browser
      
      get "/", DocsController, :index
    end

## Help Needed

I have a pretty good idea where I want this to go, but I'm fairly
busy.  I especially need help with the front-end aspect (showing the
documentation).  I'd also appreciate feedback on the basic idea.
