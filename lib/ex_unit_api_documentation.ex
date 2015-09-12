defmodule ExUnitApiDocumentation do
  alias ExUnitApiDocumentation.Worker
  alias ExUnitApiDocumentation.Formatter
  alias ExUnitApiDocumentation.Index

  def start do
    Worker.start()
  end

  def stop do
    Worker.stop()
  end

  def clear do
    Worker.clear()
  end

  def start_doc(name) do
    Worker.start_doc(name)
  end

  def document(method,
               url,
               request_headers,
               request_body,
               resp) do
    Worker.document(method, url, request_headers, request_body, resp)
  end

  def docs_root do
    Path.join([".", "priv", "static"])
  end

  def url_path(path) do
    String.replace(path, docs_root(), "")
  end

  def write_json do
    state = Worker.state()
    write_json(state)
  end
    
  defp write_json(state) do
    path = Path.join([docs_root(), "docs", state.name <> ".json"])
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, Formatter.format_json(state), [:write])
    Index.update(url_path(path), docs_root())
  end
end
