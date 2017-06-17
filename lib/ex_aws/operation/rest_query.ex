defmodule ExAws.Operation.RestQuery do
  defstruct [
    http_method: nil,
    path: "/",
    params: %{},
    body: "",
    service: nil,
    action: nil,
    parser: &ExAws.Utils.identity/2,
  ]

  @type t :: %__MODULE__{}
end

defimpl ExAws.Operation, for: ExAws.Operation.RestQuery do
  def perform(operation, config) do
    headers = []
    url = ExAws.Request.Url.build(operation, config)
    result = ExAws.Request.request(operation.http_method, url, operation.body, headers, config, operation.service)
    parser = operation.parser
    cond do
      is_function(parser, 2) ->
        parser.(result, operation.action)
      is_function(parser, 3) ->
        parser.(result, operation.action, config)
      true ->
        result
    end
  end

  def stream!(%{stream_builder: fun}, config) do
    fun.(config)
  end
end
