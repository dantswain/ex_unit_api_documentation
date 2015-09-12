defmodule ExUnitApiDocumentation do
  alias ExUnitApiDocumentation.Worker
  alias ExUnitApiDocumentation.Formatter

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

  def write_json do
    state = Worker.state()
    write_json(state)
  end
    
  defp write_json(state) do
    path = Path.join([docs_root(), "docs", state.name <> ".json"])
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, Formatter.format_json(state), [:write])
    update_index(path)
  end

  def read_index(path) do
    if File.exists?(path) do
      File.read!(path) |> Poison.decode!
    else
      []
    end
  end

  def url_path(path) do
    String.replace(path, docs_root(), "")
  end

  def update_index(path) do
    index_path = Path.join([docs_root(), "docs", "index.json"])
    index = read_index(index_path)
    index_set = :sets.from_list(index)
    index_set = :sets.add_element(url_path(path), index_set)
    File.write!(index_path, Poison.encode!(:sets.to_list(index_set)), [:write])
  end
end
