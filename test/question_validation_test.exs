defmodule QuestionValidationTest do
  use ExUnit.Case
  doctest QuestionValidation

  test "greets the world" do
    assert QuestionValidation.hello() == :world
  end

  test "it is invalid with no answers" do
    questions = [%{text: "q1", options: [%{text: "an option"}, %{text: "another option"}]}]
    answers = %{}
    assert_errors(questions, answers, q0: "was not answered")
  end

  test "it is invalid with nil answers" do
    questions = [%{text: "q1", options: [%{text: "an option"}, %{text: "another option"}]}]
    answers = nil
    assert_errors(questions, answers, q0: "was not answered")
  end

  test "errors are added for all questions" do
    questions = [
      %{text: "q1", options: [%{text: "an option"}, %{text: "another option"}]},
      %{text: "q2", options: [%{text: "an option"}, %{text: "another option"}]}
    ]

    answers = nil
    assert_errors(questions, answers, q0: "was not answered", q1: "was not answered")
  end

  test "it is valid when an answer is given" do
    questions = [%{text: "q1", options: [%{text: "yes"}, %{text: "no"}]}]
    answers = %{q0: 0}
    assert_valid(questions, answers)
  end

  test "it is valid when there are multiple options and the last option is chosen" do
    questions = [%{text: "q1", options: [%{text: "yes"}, %{text: "no"}, %{text: "maybe"}]}]
    answers = %{q0: 2}
    assert_valid(questions, answers)
  end

  test "it is invalid when an answer is not one of the valid answers" do
    questions = [%{text: "q1", options: [%{text: "an option"}, %{text: "another option"}]}]
    answers = %{"q0": 2}

    assert_errors(questions, answers, q0: "has an answer that is not on the list of valid answers")
  end

  test "it is invalid when not all the questions are answered" do
    questions = [
      %{text: "q1", options: [%{text: "an option"}, %{text: "another option"}]},
      %{text: "q2", options: [%{text: "an option"}, %{text: "another option"}]}
    ]

    answers = %{"q0": 0}
    assert_errors(questions, answers, q1: "was not answered")
  end

  test "it is valid when all the questions are answered)" do
    questions = [
      %{text: "q1", options: [%{text: "an option"}, %{text: "another option"}]},
      %{text: "q2", options: [%{text: "an option"}, %{text: "another option"}]}
    ]

    answers = %{q0: 0, q1: 0}
    assert_valid(questions, answers)
  end

  test "it is valid when questions after complete_if_selected are not answered" do
    questions = [
      %{text: "q1", options: [%{text: "yes"}, %{text: "no", complete_if_selected: true}]},
      %{text: "q2", options: [%{text: "an option"}, %{text: "another option"}]}
    ]

    answers = %{q0: 1}
    assert_valid(questions, answers)
  end

  test "it is invalid if questions after complete_if are answered" do
    questions = [
      %{text: "q1", options: [%{text: "yes"}, %{text: "no", complete_if_selected: true}]},
      %{text: "q2", options: valid_options()}
    ]

    answers = %{q0: 1, q1: 0}

    assert_errors(questions, answers,
      q1:
        "was answered even though a previous response indicated that the questions were complete"
    )
  end

  test "it is valid if complete_if is not a terminal answer and further questions are answered" do
    questions = [
      %{text: "q1", options: [%{text: "yes"}, %{text: "no", complete_if_selected: true}]},
      %{text: "q2", options: [%{text: "an option"}, %{text: "another option"}]}
    ]

    answers = %{q0: 0, q1: 1}
    assert_valid(questions, answers)
  end

  test "it is invalid if complete_if is not a terminal answer and further questions are not answered" do
    questions = [
      %{text: "q1", options: [%{text: "yes"}, %{text: "no", complete_if_selected: true}]},
      %{text: "q2", options: [%{text: "an option"}, %{text: "another option"}]}
    ]

    answers = %{q0: 0}
    assert_errors(questions, answers, q1: "was not answered")
  end

  # private
  defp answers_valid?(questions, answers) do
    test = case QuestionValidation.validate(questions, answers) do
      :ok -> true
      some -> some
    end
    IO.inspect(test)
    test
  end

  defp assert_valid(questions, answers, message \\ nil) do
    assert answers_valid?(questions, answers), message || "expected to be valid but was not: "
  end

  defp refute_valid(questions, answers, message \\ "expected to be invalid but was valid") do
    refute answers_valid?(questions, answers), message
  end

  defp assert_errors(questions, answers, errors) do
    refute_valid(questions, answers, errors)
    # assert_equal(errors, @validator.errors)
  end

  defp valid_options do
    [%{text: "an option"}, %{text: "another option"}]
  end
end
