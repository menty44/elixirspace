defmodule Elixirator.FuelCalculator do
  @moduledoc """
  Space missions FuelCalculator
  """

  @param_land_a 0.033
  @param_land_b 42
  @param_launch_a 0.042
  @param_launch_b 33

  @spec sum_fuel(any, any) :: any
  @doc """
  Adds more fuel value to the given total fuel.
  If value of fuel to add is negative, it doesn't add it. In that case it just returns the total fuel
  """
  def sum_fuel(total_fuel, fuel) when fuel >= 0 do
    total_fuel + fuel
  end

  def sum_fuel(total_fuel, _) do
    total_fuel
  end

  @spec calculate_total_fuel(number, [{atom, float}]) :: non_neg_integer
  @doc """
  Caller method which takes mass and route as input, This method is recursive and it has a base case in which it
  checks if the route has only one item, it simply calculate the fuel for that step. In other cases it first calculates
  the fuel required for next steps and then calculates the fuel for current steps, which is then added in the total fuel
  ## Examples

      iex> Elixirator.FuelCalculator.calculate_total_fuel(28801, [{:land, 9.807}])
      13447
      iex> Elixirator.FuelCalculator.calculate_total_fuel(28801, [[{:launch, 9.807}, {:land, 1.62}, {:launch, 1.62}, {:land, 9.807}]])
      51898
  """
  def calculate_total_fuel(mass, route) when length(route) == 1 do
    calculate_fuel_for_step(0, mass, hd(route))
  end

  #If the route has more than one items, it calculates the fuel required for the sub route. It uses that value to add
  #in to the the total mass and then calculates fuel required for current step. In short, the value of mass for current
  #step depends on the fuel calculated for all the next steps
  def calculate_total_fuel( mass, [step | sub_route] = route) when length(route) > 1 do
    calculate_total_fuel(mass, sub_route)
    |> case do
      {:error, message} -> {:error, message}
      fuel_for_sub_route ->
        new_mass = mass + fuel_for_sub_route
        fuel_for_sub_route + calculate_fuel_for_step(0, new_mass, step)
    end
  end

  def calculate_total_fuel( _mass, []) do
    {:error, :invalid_route_params}
  end

  @spec calculate_fuel_for_step(number, number, {atom, float}) :: non_neg_integer
  @doc """
  Calculates fuel required for single step
  ## Examples

      iex> Elixirator.FuelCalculator.calculate_fuel_for_step(28801, {:land, 9.807})
      13447
  """
  def calculate_fuel_for_step(calculated_fuel, mass, _ ) when mass <= 0 do
    calculated_fuel
  end

  def calculate_fuel_for_step(calculated_fuel, mass, {:land, gravity}) do
    fuel = (mass * gravity * @param_land_a) - @param_land_b |> floor()
    sum_fuel(calculated_fuel, fuel)
    |> calculate_fuel_for_step(fuel, {:land, gravity})
  end

  def calculate_fuel_for_step(calculated_fuel, mass, {:launch, gravity}) do
    fuel = (mass * gravity * @param_launch_a) - @param_launch_b |> floor
    sum_fuel(calculated_fuel, fuel)
    |> calculate_fuel_for_step(fuel, {:launch, gravity})
  end

  def calculate_fuel_for_step(_, _, _) do
    {:error,:invalid_route_params}
  end
end
