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
I documented on my blog:
[Integration Testing a JSON API in Phoenix](http://www.dantswain.com/blog/2015/04/19/integration-testing-a-json-api-in-phoenix/).

```elixir
defmodule MyIntegrationTest do
  use ExUnit.Case

  setup_all do
    ExUnitApiDocumentation.start_doc("sessions")

    on_exit fn ->
      ExUnitApiDocumentation.write_json
    end
  end

  test "invalid login" do
    got = Test.Endpoint.post!("/sessions",
                              Helpers.login_body("test@test.com", "h4xx0r"))
    assert got.status_code == 401
  end
end
```

```elixir
defmodule My.Router do
  use Phoenix.Router

  scope "/docs", ExUnitApiDocumentation do
    pipe_through :browser

    get "/", DocsController, :index
  end
end
```

## Help Needed

I have a pretty good idea where I want this to go, but I'm fairly
busy.  I especially need help with the front-end aspect (showing the
documentation).  I'd also appreciate feedback on the basic idea.
