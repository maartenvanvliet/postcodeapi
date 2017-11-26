defmodule PostcodeApiTest do
  use ExUnit.Case
  doctest PostcodeApi

  test "greets the world" do
    assert PostcodeApi.hello() == :world
  end
end
