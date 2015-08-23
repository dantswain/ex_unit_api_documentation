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

  def write_json do
    path = Path.join([".", "docs", name <> ".json"])
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, to_json, [:write])
  end

  def to_json do
    docs
    |> Enum.map(fn(doc) -> to_pre_json(doc) end)
    |> Poison.encode!
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
