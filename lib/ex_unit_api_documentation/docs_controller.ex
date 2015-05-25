defmodule ExUnitApiDocumentation.DocsController do
  use Phoenix.Controller

  plug :action

  def index(conn, params) do
    render conn, "index.html"
  end
end
