defmodule WorkReport.Reporter do
  @spec build({integer(), integer()}, String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def build({month_number, day_number}, file_path) do
    with {:ok, raw_string} <- File.read(file_path),
         {:ok, report_stuct} <- WorkReport.ReportStruct.build(raw_string),
         {:ok, month} <- find_month(report_stuct, month_number),
         {:ok, day} <- find_day(month.days, day_number) do
      WorkReport.Presenter.call(day, month)
    else
      {:error, error} -> error
    end
  end

  @spec month_name(integer()) :: String.t()
  defp month_name(month_number) do
    months = %{
      1 => "January",
      2 => "February",
      3 => "March",
      4 => "April",
      5 => "May",
      6 => "June",
      7 => "July",
      8 => "August",
      9 => "September",
      10 => "October",
      11 => "November",
      12 => "December"
    }

    months[month_number]
  end

  @spec find_month([%WorkReport.Models.Month{}], integer()) ::
          {:ok, %WorkReport.Models.Month{}} | {:error, String.t()}
  defp find_month(report_stuct, month_number) do
    case Enum.find(report_stuct, fn month -> month.name == month_name(month_number) end) do
      month = %WorkReport.Models.Month{} -> {:ok, month}
      _ -> {:error, "month #{month_number} not found"}
    end
  end

  @spec find_month([%WorkReport.Models.Day{}], integer()) ::
          {:ok, %WorkReport.Models.Day{}} | {:error, String.t()}
  defp find_day(month_days, day_number) do
    case Enum.find(month_days, fn day -> day.number == day_number end) do
      day = %WorkReport.Models.Day{} -> {:ok, day}
      _ -> {:error, "day #{day_number} not found"}
    end
  end
end
