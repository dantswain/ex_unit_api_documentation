defmodule ExUnitApiDocumentation do
  defmodule State do
    defstruct path: nil, name: nil, docs: []
  end

  # List.keyfind(headers, "x-request-id", 0, {nil, nil}) |> elem(1)
  def start do
    Agent.start(fn -> %State{} end, name: __MODULE__)
  end

  def clear do
    Agent.update(__MODULE__, fn(_) -> %State{} end)
  end

  def start_doc(name) do
    Agent.update(__MODULE__, fn(state) -> %{state | name: name} end)
  end

  def document(method,
               url,
               request_headers,
               request_body,
               resp) do
    Agent.update(__MODULE__, fn(state) ->
      doc = {method, url, request_headers, request_body, resp}
      %{state | docs: [doc | state.docs]}
    end)
  end

  def docs do
    Agent.get(__MODULE__, fn(state) -> state.docs end)
  end

  def name do
    Agent.get(__MODULE__, fn(state) -> state.name end)
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
