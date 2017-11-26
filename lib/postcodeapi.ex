defmodule PostcodeApi do
  defmodule Postcode do
    defstruct [:city, :streets, :postcode, :municipality, :province, :nen5825, :geo]
  end

  defmodule City do
    defstruct [:id, :label]
  end

  defmodule Municipality do
    defstruct [:id, :label]
  end

  defmodule Province do
    defstruct [:id, :label]
  end

  defmodule Nen5825 do
    defstruct [:streets, :postcode]
  end

  defmodule Error do
    defstruct [:status_code, :message]
  end

  defmodule Embedded do
    defstruct [:_embedded]
  end

  defmodule Postcodes do
    defstruct [:postcodes]
  end

  @moduledoc """
  Documentation for PostcodeApi.
  """
  use HTTPoison.Base

  @host "https://api.postcodeapi.nu/v2/"

  defp get_api_key do
    Application.get_env(:postcode_api, :api_key) || System.get_env("POSTCODE_API_KEY")
  end

  defp process_url(path), do: @host <> path

  defp headers do
    ["Content-type": "application/json", "X-Api-Key": get_api_key()]
  end

  def get_postcodes(postcode) when is_map(postcode) do
    query = URI.encode_query(postcode)
    request("postcodes/?" <> query, build_postcodes())
  end

  def get_postcodes(postcode) do
    get_postcodes(%{"postcodeArea" => postcode})
  end

  def get_postcode(postcode) do
    request("postcodes/" <> postcode, build_postcode())
  end

  defp request(url, resource) do
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
    %Error{message: message}
  end

  defp decode_body!(body, status_code) when is_integer(status_code) do
    %Error{status_code: status_code, message: Poison.decode!(body)["message"]}
  end

  defp decode_body!(body, resource) do
    Poison.decode!(body, as: struct(resource))
  end

  defp build_postcodes do
    %Embedded{_embedded: %Postcodes{postcodes: [build_postcode()]}}
  end

  defp build_postcode do
    %Postcode{
      city: %City{},
      province: %Province{},
      municipality: %Municipality{},
      nen5825: %Nen5825{}
    }
  end
end
