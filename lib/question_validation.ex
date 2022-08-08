defmodule QuestionValidation do
  @moduledoc """
  Documentation for `QuestionValidation`.
  """

  def validate(question_map, answer_map) do
    answers = map_keys_to_strings(answer_map)

    {_terminal_chosen, errors} =
      question_map
      |> Enum.with_index()
      |> Enum.reduce({false, %{}}, fn {question, index}, {acc_terminal_chosen, acc_error_map} ->
        {option_count, terminal_option} = get_option_info({question, index})
        {key, answer} = get_answer(answers, index)
        error_map = Map.merge(acc_error_map, get_any_errors(key, answer, option_count, acc_terminal_chosen))
        terminal_chosen = acc_terminal_chosen or terminal_chosen(terminal_option, answer)
        {terminal_chosen, error_map}
      end)

    errors
  end

  defp get_answer(answers, question_index) do
    key = "q#{question_index}"
    answer = Map.get(answers, key)
    {key, answer}
  end

  defp terminal_chosen(terminal_option, answer) when is_number(terminal_option) and is_number(answer) do
    answer == terminal_option
  end

  defp terminal_chosen(_terminal_option, _answer) do
    false
  end

  defp get_any_errors(key, answer, option_count, _terminal_chosen = false) do
    cond do
      answer == nil ->
        %{key => "was not answered"}

      answer > option_count - 1 ->
        %{key => "has an answer that is not on the list of valid answers"}

      true ->
        %{}
    end
  end

  defp get_any_errors(key, answer, _option_count, _terminal_chosen = true) do
    cond do
      answer != nil ->
        %{key => "was answered even though a previous response indicated that the questions were complete"}
      true ->
        %{}
    end
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

    unless terminal_option == nil do
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
