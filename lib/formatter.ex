defmodule WorkReport.Formatter do
  @spec format_time(integer | float) :: String.t()
  def format_time(time) do
    hours =
      (time / 60)
      |> trunc

    minutes =
      (time - hours * 60)
      |> trunc

    if hours + minutes == 0 do
      "0"
    else
      str_min = if minutes > 0, do: "#{minutes}m", else: ""
      hour_min = if hours > 0, do: "#{hours}h", else: ""

      "#{hour_min} #{str_min}" |> String.trim()
    end
  end
end
