within VirtualFCS.ComponentTesting;

model CoolantMixValveTSTTest
  "FluidHeatFlow valve with measured TST mix-valve Kv characteristic"
  extends Modelica.Icons.Example;
  inner Modelica.Fluid.System system annotation(
    Placement(transformation(origin = {90, 90}, extent = {{-10, -10}, {10, 10}})));
  parameter Modelica.Thermal.FluidHeatFlow.Media.Medium medium = Modelica.Thermal.FluidHeatFlow.Media.Water();
  parameter Real Kv_full(unit = "m3/h") = 6.627 "Fully open measured Kv";
  Real rc = Fluid.ValveCharacteristics.coolantMixValveTST(rampOpening.y) "Relative flow coefficient from measured table";
  Real Kv_pos(unit = "m3/h") = rc*Kv_full "Interpolated Kv at current opening";
  Modelica.Thermal.FluidHeatFlow.Sources.Ambient coolantSupply(constantAmbientPressure = system.p_ambient + 1e5, constantAmbientTemperature = system.T_ambient, medium = medium) annotation(
    Placement(transformation(origin = {-70, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
  Modelica.Thermal.FluidHeatFlow.Sources.Ambient coolantSink(constantAmbientPressure = system.p_ambient, constantAmbientTemperature = system.T_ambient, medium = medium) annotation(
    Placement(transformation(origin = {70, 0}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Thermal.FluidHeatFlow.Components.Valve valve(m = 0.1, medium = medium, T0 = system.T_ambient, LinearCharacteristic = true, y1 = 1, Kv1(displayUnit = "m3/h") = Kv_full/3600, kv0 = 1e-6, dp0(displayUnit = "Pa") = 1e5, rho0(displayUnit = "kg/m3") = 998, frictionLoss = 0) annotation(
    Placement(transformation(origin = {0, 0}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.Ramp rampOpening(height = 1, duration = 10, offset = 0, startTime = 0) annotation(
    Placement(transformation(origin = {-40, 50}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.RealExpression setValveCharacteristic(y = Fluid.ValveCharacteristics.coolantMixValveTST(rampOpening.y)) annotation(
    Placement(transformation(origin = {0, 52}, extent = {{-10, -10}, {10, 10}})));
equation
  connect(coolantSupply.flowPort, valve.flowPort_a) annotation(
    Line(points = {{-60, 0}, {-10, 0}}, color = {255, 0, 0}));
  connect(valve.flowPort_b, coolantSink.flowPort) annotation(
    Line(points = {{10, 0}, {60, 0}}, color = {255, 0, 0}));
  connect(setValveCharacteristic.y, valve.y) annotation(
    Line(points = {{11, 52}, {11, 10}, {0, 10}}, color = {0, 0, 127}));
  annotation(
    experiment(StopTime = 10, Interval = 0.05, Tolerance = 1e-6),
    Documentation(info = "<html>
<p>Ramps stem opening from 0 to 1 on the measured TST mix-valve characteristic
(11 segments, 1.25 turns). Plot <code>rc</code> or <code>Kv_pos</code> versus
<code>rampOpening.y</code>.</p>
</html>"));
end CoolantMixValveTSTTest;