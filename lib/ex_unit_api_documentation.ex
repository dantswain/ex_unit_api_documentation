defmodule ExUnitApiDocumentation do
  alias ExUnitApiDocumentation.Worker

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

  def docs do
    Worker.docs()
  end

  def name do
    Worker.name()
  end

  def docs_root do
    Path.join([".", "priv", "static"])
  end

  def write_json do
    path = Path.join([docs_root(), "docs", name <> ".json"])
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, to_json, [:write])
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

  def to_json do
    docs
    |> Enum.map(fn(doc) -> to_pre_json(doc) end)
    |> add_metadata
    |> Poison.encode!
  end

  def add_metadata(data) do
    %{metadata() | docs: data}
  end

  def metadata() do
    %{docs: [], name: name()}
  end

  def to_pre_json({method, url, request_headers, request_body, resp}) do
    %{http_method: method,
      route: url,
      requests: [
        %{request_method: method,
          request_path: url,
          request_headers: request_headers |> Enum.into(Map.new),
          request_body: request_body,
          status_code: resp.status_code,
          response_body: resp.body,
          response_headers: resp.headers |> Enum.into(Map.new)}
      ]
     }
  end
end
