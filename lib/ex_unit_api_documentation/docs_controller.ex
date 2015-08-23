defmodule ExUnitApiDocumentation.DocsController do
  use Phoenix.Controller

  def index(conn, params) do
    render conn, "index.html"
  end
end
