defmodule FuelCalculatorTest do
  use ExUnit.Case

  doctest Elixirator
  @valid_route [{:launch, 9.807}, {:land, 3.711}, {:launch, 3.711}, {:land, 9.807}]
  @invalid_route [{:xyz, 9.807}]
  @valid_mass 14606

  test "Calculate total fuel with valid route data" do
    assert Elixirator.FuelCalculator.calculate_total_fuel(@valid_mass, @valid_route) == 33388
  end

  test "Calculate total fuel with invalid route data" do
    assert Elixirator.FuelCalculator.calculate_total_fuel(@valid_mass, @invalid_route) == {:error,:invalid_route_params}
  end
end
