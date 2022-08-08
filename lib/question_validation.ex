defmodule QuestionValidation do
  @moduledoc """
  Documentation for `QuestionValidation`.
  """

  @spec validate(map(), map()) :: map()
  @doc """
  This function takes a map of questions, and a map of answers.
  It returns a map of questions and errors.
  If there are no errors, it returns an empty map.
  """
  def validate(question_map, answer_map) do
    answers = map_keys_to_strings(answer_map)

    {_completion_chosen, errors} =
      question_map
      |> Enum.with_index()
      |> Enum.reduce({false, %{}}, fn {question, index}, {acc_completion_chosen, acc_error_map} ->
        {option_count, completion_option} = get_option_info({question, index})
        {key, answer} = get_answer(answers, index)
        error_map = Map.merge(acc_error_map, get_any_errors(key, answer, option_count, acc_completion_chosen))
        completion_chosen = acc_completion_chosen or completion_chosen(completion_option, answer)
        {completion_chosen, error_map}
      end)

    errors
  end

  defp get_answer(answers, question_index) do
    # lookup question by question number, i.e. "q0"
    key = "q#{question_index}"
    answer = Map.get(answers, key)
    {key, answer}
  end

  defp completion_chosen(completion_option, answer) when is_number(completion_option) and is_number(answer) do
    # if there is a completion_option that matches the given answer, the completion option was chosen
    answer == completion_option
  end

  defp completion_chosen(_completion_option, _answer) do
    # missing completion option and/or answer
    false
  end

  defp get_any_errors(key, answer, option_count, _completion_chosen = false) do
    # No completion answer has been chosen yet.
    # If the answer is missing or invalid, return the error in a map, otherwise an empty map
    cond do
      answer == nil ->
        %{key => "was not answered"}

      answer > option_count - 1 ->
        %{key => "has an answer that is not on the list of valid answers"}

      true ->
        %{}
    end
  end

  defp get_any_errors(key, answer, _option_count, _completion_chosen = true) do
    # completion answer was already chosen, any more answers are invalid
    if answer == nil, do: %{}, else: %{key => "was answered even though a previous response indicated that the questions were complete"}
  end

  defp get_option_info(question_tuple) do
    # get the number of options and which option, if any, signals completion
    options =
      question_tuple
      |> elem(0)
      |> Map.get(:options)

    {length(options), get_completion_option(options)}
  end

  defp get_completion_option(options) do
    # Finds a single completion option in the list, if one exists
    completion_option =
      options
      |> Enum.with_index()
      |> Enum.filter(fn {option, _index} ->
        Map.has_key?(option, :complete_if_selected) && Map.get(option, :complete_if_selected) == true
      end)
      |> List.first()

    unless completion_option == nil do
      {_option, option_num} = completion_option
      option_num
    else
      nil
    end
  end

  # These are used to turn the Ruby style hash data to dictionaries
  # The tests could be changed to pass Elixir style maps instead
  defp map_keys_to_strings(nil), do: %{}
  defp map_keys_to_strings({}), do: %{}

  defp map_keys_to_strings(answers) do
    for {key, val} <- answers, into: %{} do
      {to_string(key), val}
    end
  end
end
