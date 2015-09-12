defmodule ExUnitApiDocumentation.Formatter do
  def format_json(state = %ExUnitApiDocumentation.Worker.State{}) do
    state.docs
    |> Enum.map(fn(doc) -> to_pre_json(doc) end)
    |> add_metadata(state)
    |> Poison.encode!
  end

  defp add_metadata(data, state) do
    %{metadata(state) | docs: data}
  end

  defp metadata(state) do
    %{docs: [], name: state.name}
  end

  defp to_pre_json({method, url, request_headers, request_body, resp}) do
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
