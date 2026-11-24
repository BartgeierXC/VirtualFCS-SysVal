within VirtualFCS.ComponentTesting;

model TestPumpElectricDCFluidHFPoly "Simple model to test the PumpElectricDC model"
  extends Modelica.Icons.Example;
  parameter Modelica.Thermal.FluidHeatFlow.Media.Medium medium = Modelica.Thermal.FluidHeatFlow.Media.Water() annotation(
    Placement(visible = false, transformation(extent = {{0, 0}, {0, 0}})));
  inner Modelica.Fluid.System system annotation(
    Placement(visible = true, transformation(origin = {90, 90}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Fluid.PumpElectricDCFluidHFPoly pumpElectricDC(medium = medium)  annotation(
    Placement(visible = true, transformation(origin = {0, 0}, extent = {{-20, -20}, {20, 20}}, rotation = 0)));
  Modelica.Thermal.FluidHeatFlow.Sources.Ambient WaterSink(constantAmbientPressure = system.p_ambient, constantAmbientTemperature = system.T_ambient, medium = medium, usePressureInput = true, useTemperatureInput = false) annotation(
    Placement(visible = true, transformation(origin = {18, 0}, extent = {{60, -10}, {80, 10}}, rotation = 0)));
  Modelica.Thermal.FluidHeatFlow.Sources.Ambient WaterSource(constantAmbientPressure = system.p_ambient, constantAmbientTemperature(displayUnit = "K") = system.T_ambient, medium = medium, usePressureInput = true, useTemperatureInput = true) annotation(
    Placement(visible = true, transformation(origin = {-10, 0}, extent = {{-60, -10}, {-80, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.CombiTimeTable loadCycle(extrapolation = Modelica.Blocks.Types.Extrapolation.HoldLastPoint, fileName = Modelica.Utilities.Files.loadResource("modelica://VirtualFCS.Resources.LuT/OpCons_data.txt"), smoothness = Modelica.Blocks.Types.Smoothness.ConstantSegments, table = [0, 0, 0, 0, 0; 30, 1500, 30000, 0, 0], tableName = "op_cons", tableOnFile = true, verboseRead = false) annotation(
    Placement(transformation(origin = {-90, 90}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Continuous.CriticalDamping OpCons[4](each f = 1, each n = 4) annotation(
    Placement(transformation(origin = {-50, 90}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.RealExpression realT(y = Modelica.Units.Conversions.from_degC(OpCons[4].y))  annotation(
    Placement(transformation(origin = {-122, -6}, extent = {{-10, -10}, {10, 10}})));
  Real p_inp = OpCons[1].y;
  Modelica.Blocks.Sources.RealExpression realW(y = OpCons[1].y) annotation(
    Placement(transformation(origin = {-50, -56}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Thermal.FluidHeatFlow.Sensors.VolumeFlowSensor volumeFlowSensor(medium = medium)  annotation(
    Placement(transformation(origin = {50, 0}, extent = {{-10, 10}, {10, -10}}, rotation = -0)));
  Modelica.Electrical.Analog.Sources.ConstantVoltage constantVoltage(V = 336) annotation(
    Placement(transformation(origin = {0, 62}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Electrical.Analog.Basic.Ground ground annotation(
    Placement(transformation(origin = {-20, 52}, extent = {{-10, -10}, {10, 10}})));
equation
  connect(WaterSource.flowPort, pumpElectricDC.Input) annotation(
    Line(points = {{-70, 0}, {-18, 0}}, color = {255, 0, 0}));
  connect(loadCycle.y, OpCons.u) annotation(
    Line(points = {{-78, 90}, {-62, 90}}, color = {0, 0, 127}, thickness = 0.5));
  connect(OpCons[2].y, WaterSource.ambientPressure) annotation(
    Line(points = {{-38, 90}, {-30, 90}, {-30, -32}, {-100, -32}, {-100, 6}, {-90, 6}}, color = {0, 0, 127}));
  connect(OpCons[3].y, WaterSink.ambientPressure) annotation(
    Line(points = {{-38, 90}, {-30, 90}, {-30, -32}, {110, -32}, {110, 6}, {98, 6}}, color = {0, 0, 127}));
  connect(realT.y, WaterSource.ambientTemperature) annotation(
    Line(points = {{-110, -6}, {-90, -6}}, color = {0, 0, 127}));
  connect(realW.y, pumpElectricDC.contol_input) annotation(
    Line(points = {{-38, -56}, {-6, -56}, {-6, -16}}, color = {0, 0, 127}));
  connect(pumpElectricDC.Output, volumeFlowSensor.flowPort_a) annotation(
    Line(points = {{18, 0}, {40, 0}}, color = {255, 0, 0}));
  connect(volumeFlowSensor.flowPort_b, WaterSink.flowPort) annotation(
    Line(points = {{60, 0}, {78, 0}}, color = {255, 0, 0}));
  connect(constantVoltage.n, ground.p) annotation(
    Line(points = {{-10, 62}, {-20, 62}}, color = {0, 0, 255}));
  connect(constantVoltage.p, pumpElectricDC.pin_p) annotation(
    Line(points = {{10, 62}, {6, 62}, {6, 16}}, color = {0, 0, 255}));
  connect(constantVoltage.n, pumpElectricDC.pin_n) annotation(
    Line(points = {{-10, 62}, {-6, 62}, {-6, 16}}, color = {0, 0, 255}));
  annotation(
    Documentation(info = "<html><head></head><body>
<p>Test of <a href=\"modelica://VirtualFCS.Fluid.PumpElectricDCFluidHFPoly\">PumpElectricDCFluidHFPoly</a> between two water boundaries with table-driven speed command, boundary pressures and water temperature. The pump is supplied from a 336 V source.</p>
<h4>Operating-point input</h4>
<p>Operating points are read from the text table <code>op_cons</code> in <code>OpCons_data.txt</code>, which is a variable interface file (see <a href=\"modelica://VirtualFCS.Utilities.SystemControl\">SystemControl</a>, &quot;Operating-point input&quot;). Its column layout must match this model; a dedicated file can be set via <code>fileName</code>. Expected data columns (after the time column):</p>
<table>
<tr><td>1</td><td>Normalised speed command [-]</td></tr>
<tr><td>2</td><td>Source (inlet) pressure [Pa]</td></tr>
<tr><td>3</td><td>Sink (outlet) pressure [Pa]</td></tr>
<tr><td>4</td><td>Water temperature [&deg;C]</td></tr>
</table>
</body></html>"),
    experiment(StopTime = 600, Interval = 0.5, Tolerance = 1e-06, StartTime = 0));
end TestPumpElectricDCFluidHFPoly;
