defmodule WorkReport.Presenter do
  def call(day, month) do
    day_info(day) <> "\n" <> month_info(month)
  end

  defp day_info(day) do
    """
    Day: #{day.number} #{day.weekday}
    #{present_tasks(day.tasks)}   Total: #{sum_time(day.tasks)}
    """
  end

  defp month_info(month) do
    """
    Month: #{month.name}
    #{present_by_type_tasks(month.days)}   Total: #{total_for_tasks(month)}
    """
  end

  defp present_tasks(tasks) do
    Enum.map(tasks, fn task -> " - #{task.type}: #{task.name} - #{task.time}\n" end)
    |> Enum.reverse()
  end

  defp present_by_type_tasks(days) do
    task_types = ["COMM", "DEV", "OPS", "DOC", "WS", "EDU"]
    Enum.map(task_types, fn task_type -> str_time_for_task_type(task_type, days) end)
  end

  defp total_for_tasks(month) do
    days = Enum.count(month.days)

    total_time =
      Enum.reduce(month.days, 0, fn day, acc -> acc + sum_time(day.tasks, minutes: true) end)

    avg = total_time / days

    formated_total_time = WorkReport.Formatter.format_time(total_time)
    formated_avg = WorkReport.Formatter.format_time(avg)

    "#{formated_total_time}, Days: #{days}, Avg: #{formated_avg}"
  end

  defp str_time_for_task_type(task_type, days) do
    " - #{task_type}: #{time_by_task_type(days, task_type)}\n"
  end

  defp time_by_task_type(days, task_type) do
    tasks =
      Enum.map(days, fn day -> find_tasks_by_type(day, task_type) end)
      |> List.flatten()

    sum_time(tasks)
  end

  defp find_tasks_by_type(day, task_type) do
    Enum.filter(day.tasks, fn task -> task.type == task_type end)
  end

  defp sum_time(collection) do
    minuetes =
      Enum.reduce(collection, 0, fn elem, acc ->
        acc + WorkReport.Parser.parse_time(Map.get(elem, :time))
      end)

    WorkReport.Formatter.format_time(minuetes)
  end

  defp sum_time(collection, minutes: true) do
    Enum.reduce(collection, 0, fn elem, acc ->
      acc + WorkReport.Parser.parse_time(Map.get(elem, :time))
    end)
  end
end
