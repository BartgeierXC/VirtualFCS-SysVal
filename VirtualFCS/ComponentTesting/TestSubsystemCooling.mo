within VirtualFCS.ComponentTesting;

model TestSubsystemCooling
  extends Modelica.Icons.Example;
  import ModelicaServices.Machine.eps;
  import ModelicaServices.Machine.inf;

  inner Modelica.Fluid.System system(allowFlowReversal = false, m_flow_start = system.m_flow_small, dp_small(displayUnit = "Pa") = 10, m_flow_small = 1e-3, p_ambient = 94500) annotation(
    Placement(visible = true, transformation(origin = {-90, -90}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  inner Utilities.SystemControl systemControl annotation(
    Placement(transformation(origin = {90, 90}, extent = {{-10, -10}, {10, 10}})));

  parameter Modelica.Thermal.FluidHeatFlow.Media.Medium medium = Modelica.Thermal.FluidHeatFlow.Media.Water();
  Real T_Si = subSystemCooling.tempFCIn.y - 273.15;
  Modelica.Units.SI.Current I = OpCons[1].y annotation(
    Placement(visible = false, transformation(extent = {{0, 0}, {0, 0}})));
  Modelica.Electrical.Analog.Sources.ConstantVoltage constantVoltage(V = 336) annotation(
    Placement(transformation(origin = {0, -60}, extent = {{10, -10}, {-10, 10}}, rotation = -0)));
  Modelica.Electrical.Analog.Basic.Ground ground annotation(
    Placement(transformation(origin = {-20, -70}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.RealExpression real_p_Si(y = max(Modelica.Units.Conversions.from_bar(OpCons[9].y), system.p_ambient)) annotation(
    Placement(transformation(origin = {-90, 36}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.RealExpression real_T_So(y = max(system.T_ambient, Modelica.Units.Conversions.from_degC(OpCons[11].y))) annotation(
    Placement(transformation(origin = {90, 20}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Blocks.Sources.RealExpression real_p_So(y = max(Modelica.Units.Conversions.from_bar(OpCons[10].y), system.p_ambient)) annotation(
    Placement(transformation(origin = {90, 40}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Blocks.Sources.CombiTimeTable opCons(extrapolation = Modelica.Blocks.Types.Extrapolation.HoldLastPoint, fileName = Modelica.Utilities.Files.loadResource("modelica://VirtualFCS.Resources.LuT/OpCons_data.txt"), smoothness = Modelica.Blocks.Types.Smoothness.ConstantSegments, table = [0, 0, 180000, 150000, 1.5, 1.8, 0, 0, 180000, 150000, 1, 0], tableName = "op_cons", tableOnFile = true, verboseRead = false) annotation(
    Placement(transformation(origin = {-90, 90}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Continuous.FirstOrder OpCons[11](each T = 10, each y_start = eps) annotation(
    Placement(transformation(origin = {-60, 90}, extent = {{-6, -6}, {6, 6}})));
  SubSystems.Cooling.SubSystemCoolingTST subSystemCooling(medium = medium)  annotation(
    Placement(transformation(extent = {{-10, -10}, {10, 10}})));
  Modelica.Thermal.FluidHeatFlow.Sources.Ambient FC_out(usePressureInput = true, useTemperatureInput = true, medium = medium) annotation(
    Placement(transformation(origin = {50, 30}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Thermal.FluidHeatFlow.Sources.Ambient FC_in(usePressureInput = true, useTemperatureInput = false, constantAmbientTemperature = system.T_ambient, medium = medium) annotation(
    Placement(transformation(origin = {-50, 30}, extent = {{10, -10}, {-10, 10}})));
equation
  connect(constantVoltage.n, ground.p) annotation(
    Line(points = {{-10, -60}, {-20, -60}}, color = {0, 0, 255}));
  connect(opCons.y, OpCons.u) annotation(
    Line(points = {{-79, 90}, {-68, 90}}, color = {0, 0, 127}, thickness = 0.5));
  connect(subSystemCooling.pin_n, constantVoltage.n) annotation(
    Line(points = {{-4, -8}, {-6, -8}, {-6, -60}, {-10, -60}}, color = {0, 0, 255}));
  connect(subSystemCooling.pin_p, constantVoltage.p) annotation(
    Line(points = {{6, -8}, {8, -8}, {8, -60}, {10, -60}}, color = {0, 0, 255}));
  connect(real_p_So.y, FC_out.ambientPressure) annotation(
    Line(points = {{80, 40}, {70, 40}, {70, 36}, {60, 36}}, color = {0, 0, 127}));
  connect(real_T_So.y, FC_out.ambientTemperature) annotation(
    Line(points = {{80, 20}, {70, 20}, {70, 24}, {60, 24}}, color = {0, 0, 127}));
  connect(real_p_Si.y, FC_in.ambientPressure) annotation(
    Line(points = {{-79, 36}, {-60, 36}}, color = {0, 0, 127}));
  connect(FC_in.flowPort, subSystemCooling.flowPort_b) annotation(
    Line(points = {{-40, 30}, {-4, 30}, {-4, 10}}, color = {255, 0, 0}));
  connect(FC_out.flowPort, subSystemCooling.flowPort_a) annotation(
    Line(points = {{40, 30}, {6, 30}, {6, 10}}, color = {255, 0, 0}));
  annotation(
    Diagram,
    Icon,
    Documentation(info = "<html><head></head><body>
<p>Open-loop test of <a href=\"modelica://VirtualFCS.SubSystems.Cooling.SubSystemCoolingTST\">SubSystemCoolingTST</a> between pressure and temperature boundaries that represent the stack coolant inlet and outlet. The subsystem reads its set points from the inner <code>systemControl</code>, which needs a table in the SystemControl layout.</p>
<h4>Operating-point input</h4>
<p>Operating points are read from the text table <code>op_cons</code> in <code>OpCons_data.txt</code>, which is a variable interface file (see <a href=\"modelica://VirtualFCS.Utilities.SystemControl\">SystemControl</a>, &quot;Operating-point input&quot;). Its column layout must match this model; a dedicated file can be set via <code>fileName</code>. Expected data columns (after the time column):</p>
<table>
<tr><td>1</td><td>Stack current [A] (not used by the boundaries)</td></tr>
<tr><td>2&ndash;8</td><td>Not used</td></tr>
<tr><td>9</td><td>Coolant pressure at stack inlet [bar]</td></tr>
<tr><td>10</td><td>Coolant pressure at stack outlet [bar]</td></tr>
<tr><td>11</td><td>Coolant temperature at stack outlet [&deg;C]</td></tr>
</table>
</body></html>"),
    experiment(StartTime = 0, StopTime = 3600, Tolerance = 0.0001, Interval = 1),
    __OpenModelica_commandLineOptions = "--matchingAlgorithm=PFPlusExt --indexReductionMethod=dynamicStateSelection -d=initialization,NLSanalyticJacobian -d=backenddaeinfo,bltdump",
    __OpenModelica_simulationFlags(cpu = "()", lv = "LOG_STDOUT,LOG_ASSERT,LOG_STATS", s = "dassl", variableFilter = ".*"));
end TestSubsystemCooling;
