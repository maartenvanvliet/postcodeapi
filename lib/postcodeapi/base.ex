defmodule PostcodeApi.Base do
  use HTTPoison.Base

  @host "https://api.postcodeapi.nu/v2/"

  defp get_api_key do
    Application.get_env(:postcode_api, :api_key) || System.get_env("POSTCODE_API_KEY")
  end

  defp process_url(path), do: @host <> path

  defp headers do
    ["Content-type": "application/json", "X-Api-Key": get_api_key()]
  end

  def request(url, resource) do
    case get(url, headers()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, decode_body!(body, resource)}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, decode_body!(body, status_code)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, decode_body!(reason)}
    end
  end

  defp decode_body!(message) do
    %PostcodeApi.Error{message: message}
  end

  defp decode_body!(body, status_code) when is_integer(status_code) do
    %PostcodeApi.Error{status_code: status_code, message: Poison.decode!(body)["message"]}
  end

  defp decode_body!(body, resource) do
    Poison.decode!(body, as: struct(resource))
  end
end