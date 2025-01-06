defmodule WorkReport.Parser do
  @spec parse_time(String.t()) :: integer()
  def parse_time(time_str) do
    parse_hours(time_str) * 60 + parse_minutes(time_str)
  end

  defp parse_hours(time_str) do
    hours_str =
      Regex.scan(~r/\d*h/, time_str)
      |> List.first()

    try do
      case hours_str do
        [hours_str] ->
          hours_str
          |> String.replace("h", "")
          |> String.to_integer()

        _ ->
          0
      end
    rescue
      ArgumentError -> 0
    end
  end

  defp parse_minutes(time_str) do
    minutes_str =
      Regex.scan(~r/\d*m/, time_str)
      |> List.first()

    try do
      case minutes_str do
        [minutes_str] ->
          minutes_str
          |> String.replace("m", "")
          |> String.to_integer()

        _ ->
          0
      end
    rescue
      ArgumentError -> 0
    end
  end
end
