defmodule QuestionValidation do
  @moduledoc """
  Documentation for `QuestionValidation`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> QuestionValidation.hello()
      :world

  """
  def hello do
    :world
  end

  def validate(_questions, _answers) do
    {:error, ["if it's broke, fix it"]}
  end
end
