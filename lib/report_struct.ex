defmodule WorkReport.ReportStruct do
  @spec build(String.t()) :: {:ok, [%WorkReport.Models.Month{}]} | {:error, String.t()}
  def build(raw_string) do
    try do
      report_struct =
        raw_string
        |> String.split("\n", trim: true)
        |> Enum.reduce([], fn text, acc -> build_struct(text, acc) end)
      {:ok, report_struct}
    rescue
      e -> {:error, "file parse error: #{e}"}
    end
  end

  defp build_struct(text, acc) do
    cond do
      Regex.match?(~r/^#\s/, text) -> build_month(text, acc)
      Regex.match?(~r/^##\s/, text) -> build_day(text, acc)
      Regex.match?(~r/^\[\S*\]/, text) -> build_task(text, acc)
      true -> acc
    end
  end

  defp build_month(text, acc) do
    month = String.split(text) |> Enum.at(1)
    [%WorkReport.Models.Month{name: month} | acc]
  end

  defp build_day(text, acc) do
    num_day = String.split(text) |> Enum.at(1) |> String.to_integer()
    weekday = String.split(text) |> Enum.at(2)

    day = %WorkReport.Models.Day{number: num_day, weekday: weekday}

    add_day_in_last_month(acc, day)
  end

  defp build_task(text, acc) do
    type =
      Regex.run(~r/\[\w*\]/, text)
      |> List.last()
      |> String.replace(["[", "]"], "")

    name =
      Regex.run(~r/].*-/, text)
      |> List.first()
      |> String.slice(1..-2//1)
      |> String.trim()

    time =
      Regex.run(~r/(\d{1,2}h\s\d{1,2}m|\d{1,2}[hm])/, text)
      |> List.last()
      |> WorkReport.Parser.parse_time()
      |> WorkReport.Formatter.format_time()

    task = %WorkReport.Models.Task{type: type, name: name, time: time}

    add_task_in_last_day(acc, task)
  end

  defp add_day_in_last_month(acc, day) do
    actual_month = List.first(acc)
    updated_month = %{actual_month | days: [day | actual_month.days]}

    List.replace_at(acc, 0, updated_month)
  end

  defp add_task_in_last_day(acc, task) do
    actual_month = List.first(acc)
    actual_day = List.first(actual_month.days)
    day_with_tasks = %{actual_day | tasks: [task | actual_day.tasks]}

    days = List.replace_at(actual_month.days, 0, day_with_tasks)
    actual_month = %{actual_month | days: days}

    List.replace_at(acc, 0, actual_month)
  end
end
