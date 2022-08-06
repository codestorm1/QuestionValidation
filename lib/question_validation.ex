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

  def validate(question_map, answer_map) do
    answers = map_keys_to_strings(answer_map)
    IO.puts("\nquestions: #{inspect(question_map)}\n answers: #{inspect(answers)}")
    question_map
    |> Enum.with_index()
    |> Enum.map(&has_valid_answer(&1, answers))
  end

  defp has_valid_answer(question_tuple, answers) do
    key = "q" <> (question_tuple |> elem(1) |> to_string())
    answer = Map.get(answers, key)
    option_count =
      question_tuple
      |> elem(0)
      |> Map.get(:options)
      |> length

    IO.puts("option count: #{inspect(option_count)}")
    # IO.puts("valid answer for item #{key} options #{option_count}? answer: #{answer}")
    result = cond do
      answer == nil -> %{key => "was not answered"}
      answer > option_count - 1 -> %{key => "has an answer that is not on the list of valid answers"}
      answer == -1 -> %{key => "was answered even though a previous response indicated that the questions were complete"}
      true -> %{key => "GOOD!"}
    end

    IO.inspect(result)
    IO.puts("answer was: #{answer}")
  end

  defp map_keys_to_strings(nil), do: %{}
  defp map_keys_to_strings({}), do: %{}

  defp map_keys_to_strings(answers) do
    for {key, val} <- answers, into: %{} do
      {to_string(key), val}
    end
  end
end
