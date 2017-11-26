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


  @doc """
  All postcodes in the Netherlands

  ## Examples
  ```
  iex> PostcodeApi.get_postcodes(%{"postcodeArea" => "1234"})
  {:ok, %Embedded{}}
  iex> PostcodeApi.get_postcodes("1234")
  {:ok, %Embedded{}}
  ```
  """
  def get_postcodes(postcode) when is_map(postcode) do
    query = URI.encode_query(postcode)
    PostcodeApi.Base.request("postcodes/?" <> query, build_postcodes())
  end
  def get_postcodes(postcode) do
    get_postcodes(%{"postcodeArea" => postcode})
  end

  @doc """
  Return information on single postcode in P6 format


  ## Examples
  ```
  iex> PostcodeApi.get_postcode("1234AA")
  {:ok, %Postcode{}}
  ```
  """
  def get_postcode(postcode) do
    PostcodeApi.Base.request("postcodes/" <> postcode, build_postcode())
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
