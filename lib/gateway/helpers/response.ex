defmodule Gateway.HTTPHelpers.Response do
  @moduledoc """
  Gateway HTTP Helpers Response
  """
  def render_delete_response({:ok, _resource}, conn), do: render_response(%{}, conn, 200)
  def render_delete_response(_, conn), do: render_response(nil, conn)

  def render_response(resp, conn, status \\ 200), do: _render_response(resp, conn, status)
  defp _render_response({:ok, resource}, conn, status), do: _render_response(resource, conn, status)
  defp _render_response({:error, changeset}, conn, _) do
    conn
    |> Plug.Conn.send_resp(422, Poison.encode!(EView.ValidationErrorView.render("422.json", changeset)))
  end
  defp _render_response(nil, conn, _), do: Plug.Conn.send_resp(conn, 404, Poison.encode!(%{}))
  defp _render_response(resource, conn, status) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(status, get_resp_body(resource))
  end

  def get_resp_body(resource) when is_list(resource), do: Poison.encode!(resource)
  def get_resp_body(resource) when is_map(resource), do: resource |> set_type() |> Poison.encode!()

  def set_type(resource) when resource != %{} do
    type = resource
    |> Map.get(:__struct__)
    |> EView.DataRender.extract_object_name

    resource
    |> Map.put(:type, type)
  end

  def set_type(resource), do: resource
end
