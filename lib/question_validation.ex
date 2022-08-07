defmodule QuestionValidation do
  @moduledoc """
  Documentation for `QuestionValidation`.
  """

  def validate(question_map, answer_map) do
    answers = map_keys_to_strings(answer_map)
    IO.puts("\nquestions: #{inspect(question_map)}\nanswers: #{inspect(answers)}")
    IO.puts("question count: #{length(question_map)}")

    question_map
    |> Enum.with_index()
    |> Enum.reduce({false, %{}}, fn {question, index}, {acc_terminal_chosen, error_map} ->
      {option_count, terminal_option} = get_option_info({question, index})

      {new_error_map, terminal_chosen} =
        has_valid_answer({question, index}, answers, option_count, terminal_option, acc_terminal_chosen)

      terminal_chosen = acc_terminal_chosen || terminal_chosen
      new_error_map = Map.merge(new_error_map, error_map)
      {terminal_chosen, new_error_map}
    end)
  end

  defp has_valid_answer(question_tuple, answers, option_count, terminal_option, terminal_chosen) do
    key = "q" <> (question_tuple |> elem(1) |> to_string())
    answer = Map.get(answers, key)
    IO.puts("answer: #{inspect(answer)}")
    # IO.puts("valid answer for item #{key} options #{option_count}? answer: #{answer}")
    result =
      cond do
        answer == nil ->
          %{key => "was not answered"}

        answer > option_count - 1 ->
          %{key => "has an answer that is not on the list of valid answers"}

        answer != nil && terminal_chosen ->
          %{
            key => "was answered even though a previous response indicated that the questions were complete"
          }

        true ->
          %{}
      end

    terminal_chosen = answer == terminal_option

    IO.puts("terminal chosen: #{inspect(terminal_chosen)}")

    IO.inspect(result)
    IO.puts("answer was: #{answer}")
    IO.puts("result was: #{inspect(result)}")
    {result, terminal_chosen}
  end

  defp get_option_info(question_tuple) do
    options =
      question_tuple
      |> elem(0)
      |> Map.get(:options)

    {length(options), get_terminal_option(options)}
  end

  defp get_terminal_option(options) do
    terminal_option =
      options
      |> Enum.with_index()
      |> Enum.filter(fn {option, _index} ->
        Map.has_key?(option, :complete_if_selected) && Map.get(option, :complete_if_selected) == true
      end)
      |> List.first()

    if terminal_option != nil do
      {_option, option_num} = terminal_option
      option_num
    else
      nil
    end
  end

  defp map_keys_to_strings(nil), do: %{}
  defp map_keys_to_strings({}), do: %{}

  defp map_keys_to_strings(answers) do
    for {key, val} <- answers, into: %{} do
      {to_string(key), val}
    end
  end
end
