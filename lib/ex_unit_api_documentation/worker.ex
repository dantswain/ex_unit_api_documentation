defmodule ExUnitApiDocumentation.Worker do
  defmodule State do
    defstruct path: nil, name: nil, docs: []
  end

  def start do
    Agent.start(fn -> %State{} end, name: __MODULE__)
  end

  def stop do
    Agent.stop(__MODULE__)
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

  def state do
    Agent.get(__MODULE__, fn(state) -> state end)
  end
end
