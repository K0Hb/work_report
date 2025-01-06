defmodule WorkReport.Presenter do
  @spec call(%WorkReport.Models.Day{}, %WorkReport.Models.Month{}) :: String.t()
  def call(day, month) do
    day_info(day) <> "\n" <> month_info(month)
  end

  @spec day_info(%WorkReport.Models.Day{}) :: String.t()
  defp day_info(day) do
    """
    Day: #{day.number} #{day.weekday}
    #{present_tasks(day.tasks)}   Total: #{sum_time(day.tasks)}
    """
  end

  @spec month_info(%WorkReport.Models.Month{}) :: String.t()
  defp month_info(month) do
    """
    Month: #{month.name}
    #{present_by_type_tasks(month.days)}   Total: #{total_for_tasks(month)}
    """
  end

  @spec present_tasks([%WorkReport.Models.Task{}]) :: [String.t()] | []
  defp present_tasks(tasks) do
    Enum.map(tasks, fn task -> " - #{task.type}: #{task.name} - #{task.time}\n" end)
    |> Enum.reverse()
  end

  @spec present_tasks([%WorkReport.Models.Day{}]) :: [String.t()] | []
  defp present_by_type_tasks(days) do
    task_types = ["COMM", "DEV", "OPS", "DOC", "WS", "EDU"]
    Enum.map(task_types, fn task_type -> str_time_for_task_type(task_type, days) end)
  end

  @spec total_for_tasks(%WorkReport.Models.Month{}) :: String.t()
  defp total_for_tasks(month) do
    days = Enum.count(month.days)

    total_time =
      Enum.reduce(month.days, 0, fn day, acc -> acc + sum_time(day.tasks, minutes: true) end)

    avg = total_time / days

    formated_total_time = WorkReport.Formatter.format_time(total_time)
    formated_avg = WorkReport.Formatter.format_time(avg)

    "#{formated_total_time}, Days: #{days}, Avg: #{formated_avg}"
  end

  @spec str_time_for_task_type(String.t(), [%WorkReport.Models.Day{}]) :: String.t()
  defp str_time_for_task_type(task_type, days) do
    " - #{task_type}: #{time_by_task_type(days, task_type)}\n"
  end

  @spec time_by_task_type([%WorkReport.Models.Day{}], String.t()) :: integer
  defp time_by_task_type(days, task_type) do
    tasks =
      Enum.map(days, fn day -> find_tasks_by_type(day, task_type) end)
      |> List.flatten()

    sum_time(tasks)
  end

  @spec find_tasks_by_type(%WorkReport.Models.Day{}, String.t()) :: [%WorkReport.Models.Task{}] | []
  defp find_tasks_by_type(day, task_type) do
    Enum.filter(day.tasks, fn task -> task.type == task_type end)
  end

  @spec sum_time([%WorkReport.Models.Task{}]) :: String.t()
  defp sum_time(collection) do
    minuetes =
      Enum.reduce(collection, 0, fn elem, acc ->
        acc + WorkReport.Parser.parse_time(Map.get(elem, :time))
      end)

    WorkReport.Formatter.format_time(minuetes)
  end

  @spec sum_time([%WorkReport.Models.Task{}], minutes: true) :: integer
  defp sum_time(collection, minutes: true) do
    Enum.reduce(collection, 0, fn elem, acc ->
      acc + WorkReport.Parser.parse_time(Map.get(elem, :time))
    end)
  end
end
