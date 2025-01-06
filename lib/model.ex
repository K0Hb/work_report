defmodule WorkReport.Models do
  defmodule Month do
    defstruct [:name, days: []]
  end

  defmodule Day do
    defstruct [:number, :weekday, tasks: []]
  end

  defmodule Task do
    defstruct [:type, :name, :time]
  end
end
