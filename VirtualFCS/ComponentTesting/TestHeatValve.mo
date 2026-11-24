within VirtualFCS.ComponentTesting;

model TestHeatValve "Test of the house-coolant valve characteristic"
  extends Modelica.Icons.Example;
  parameter Modelica.Thermal.FluidHeatFlow.Media.Medium medium = Modelica.Thermal.FluidHeatFlow.Media.Water() annotation(
    Placement(visible = false, transformation(extent = {{0, 0}, {0, 0}})));
  Modelica.Thermal.FluidHeatFlow.Sources.Ambient WaterSink(constantAmbientPressure = system.p_ambient, constantAmbientTemperature = system.T_ambient, medium = medium, usePressureInput = true, useTemperatureInput = false) annotation(
    Placement(visible = true, transformation(origin = {18, 0}, extent = {{60, -10}, {80, 10}}, rotation = 0)));
  Modelica.Thermal.FluidHeatFlow.Sources.Ambient WaterSource(constantAmbientPressure = 5.2e5, constantAmbientTemperature(displayUnit = "K") = system.T_ambient, medium = medium, usePressureInput = true, useTemperatureInput = true) annotation(
    Placement(visible = true, transformation(origin = {-10, 0}, extent = {{-60, -10}, {-80, 10}}, rotation = 0)));
  parameter Modelica.Units.SI.Time delay_time = 20;
  parameter Modelica.Units.SI.Mass m_coolant_int = 33 "Total coolant fluid mass internal circuit";
  parameter Modelica.Units.SI.Mass m_coolant_ext = 33 "Total coolant fluid mass external circuit";
  parameter Modelica.Units.SI.Mass m_coolant_air = 3.18 "Total coolant fluid mass cathode circuit";
  parameter Modelica.Units.SI.ThermalConductance G = 6200;
  parameter Modelica.Units.SI.Temperature T_TST_coolant_set = Modelica.Units.Conversions.from_degC(18) "External coolant temperature set";
  parameter Modelica.Units.SI.Time tau = 3 "Time constant valve opening house coolant";
  parameter Modelica.Units.SI.Pressure p_TST_coolant_in = 360000 "Pressure inlet house coolant";
  parameter Modelica.Units.SI.VolumeFlowRate K_vs_Hex_valve = 6.639/3600 "House coolant heat exchanger valve K_vs at dp0 = 1 bar";
  parameter Modelica.Units.SI.VolumeFlowRate K_v0_Hex_valve = 0.01/3600 "House coolant heat exchanger valve leakage K_v at dp0 = 1 bar";
  parameter Boolean p_Cl_constant = true "Pressure inlet house coolant constant (otherwise varied by systemControl)";
  parameter Boolean T_Cl_constant = true "Temperature inlet house coolant constant (otherwise varied by systemControl)";
  Real opening = 1-systemControl.x_Cl;
  Modelica.Blocks.Sources.RealExpression realT(y = systemControl.T_Cl)  annotation(
    Placement(transformation(origin = {-122, -6}, extent = {{-10, -10}, {10, 10}})));

  Modelica.Thermal.FluidHeatFlow.Sensors.VolumeFlowSensor volumeFlowSensor(medium = medium)  annotation(
    Placement(transformation(origin = {50, 0}, extent = {{-10, 10}, {10, -10}}, rotation = -0)));
  Modelica.Thermal.FluidHeatFlow.Components.Valve valve(Kv1 = K_vs_Hex_valve, LinearCharacteristic = true, T0 = system.T_ambient, V_flow(start = 3e-5), dp0(displayUnit = "Pa") = 1e5, frictionLoss = 0, kv0 = K_v0_Hex_valve/K_vs_Hex_valve, m = 0.1, medium = medium, rho0(displayUnit = "kg/m3") = 998, y1 = 1) annotation(
    Placement(transformation(extent = {{-10, -10}, {10, 10}})));
  inner Modelica.Fluid.System system(T_ambient = 298.15, dp_small(displayUnit = "Pa") = 10, m_flow_small = 1e-6, m_flow_start = system.m_flow_small, p_ambient(displayUnit = "bar") = 95000) annotation(
    Placement(transformation(origin = {-90, -90}, extent = {{-10, -10}, {10, 10}})));
  inner VirtualFCS.Utilities.SystemControl systemControl( table = [1, 100, 130000, 3000, 0.95, 1, 1e5, 0.1, 0.1; 10, 100, 130000, 3000, 0.95, 1, 1e5, 0.5, 0.5; 100, 100, 130000, 3000, 0.8, 1, 1e5, 0.5, 1; 200, 240, 130000, 3000, 0.8, 1, 1e5, 0.5, 1], tableOnFile = true, tau = 0.1, fileName = Modelica.Utilities.Files.loadResource("modelica://VirtualFCS.Resources.LuT/OpCons_data_TestHeatValve.txt")) annotation(
    Placement(transformation(origin = {-90, 90}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.RealExpression realpOut(y = systemControl.p_Cl) annotation(
    Placement(transformation(origin = {130, 6}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Blocks.Sources.RealExpression setValveCharacteristic(y = Fluid.ValveCharacteristics.coolantMixValveTST(delay(1 - systemControl.x_Cl, 21))) annotation(
    Placement(transformation(origin = {-60, 30}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.RealExpression realpIn(y = systemControl.opCons[12].y) annotation(
    Placement(transformation(origin = {-122, 10}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Nonlinear.SlewRateLimiter slewRateLimiter(Rising = 1/70, Td = 0.1)  annotation(
    Placement(transformation(origin = {-20, 30}, extent = {{-10, -10}, {10, 10}})));
equation
  connect(realT.y, WaterSource.ambientTemperature) annotation(
    Line(points = {{-110, -6}, {-90, -6}}, color = {0, 0, 127}));
  connect(volumeFlowSensor.flowPort_b, WaterSink.flowPort) annotation(
    Line(points = {{60, 0}, {78, 0}}, color = {255, 0, 0}));
  connect(WaterSource.flowPort, valve.flowPort_a) annotation(
    Line(points = {{-70, 0}, {-10, 0}}, color = {255, 0, 0}));
  connect(valve.flowPort_b, volumeFlowSensor.flowPort_a) annotation(
    Line(points = {{10, 0}, {40, 0}}, color = {255, 0, 0}));
  connect(realpOut.y, WaterSink.ambientPressure) annotation(
    Line(points = {{120, 6}, {98, 6}}, color = {0, 0, 127}));
  connect(realpIn.y, WaterSource.ambientPressure) annotation(
    Line(points = {{-110, 10}, {-100, 10}, {-100, 6}, {-90, 6}}, color = {0, 0, 127}));
  connect(setValveCharacteristic.y, slewRateLimiter.u) annotation(
    Line(points = {{-48, 30}, {-32, 30}}, color = {0, 0, 127}));
  connect(slewRateLimiter.y, valve.y) annotation(
    Line(points = {{-8, 30}, {0, 30}, {0, 10}}, color = {0, 0, 127}));
  annotation(
    Documentation(info = "<html><head></head><body>
<p>Test of the house-coolant valve: an MSL FluidHeatFlow valve with the measured characteristic <a href=\"modelica://VirtualFCS.Fluid.ValveCharacteristics.coolantMixValveTST\">coolantMixValveTST</a> applied to <code>1 - x_Cl</code>, a dead time of 21 s and a rate limit of 1/70 1/s, as in <a href=\"modelica://VirtualFCS.SubSystems.Cooling.SubSystemCoolingTST\">SubSystemCoolingTST</a>. Inlet pressure, outlet pressure and water temperature are taken from <code>systemControl</code>, which reads <code>OpCons_data_TestHeatValve.txt</code> (SystemControl layout; column 9 = outlet pressure <code>p_Cl</code> [Pa], column 10 = water temperature <code>T_Cl</code> [&deg;C], column 12 = inlet pressure [Pa]).</p>
</body></html>"),
    experiment(StopTime = 10000, Interval = 0.5, Tolerance = 1e-06, StartTime = 0));
end TestHeatValve;