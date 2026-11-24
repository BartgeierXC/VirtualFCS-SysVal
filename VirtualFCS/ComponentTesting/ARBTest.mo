within VirtualFCS.ComponentTesting;

model ARBTest "Test of the recirculation blower map"
  extends Modelica.Icons.Example;
  inner Modelica.Fluid.System system annotation(
    Placement(visible = true, transformation(origin = {90, 90}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  import Modelica.Constants.F;
  import Modelica.Constants.eps;
  replaceable package Medium = Modelica.Media.IdealGases.SingleGases.H2(Temperature(start = system.T_start), AbsolutePressure(start = system.p_start)) constrainedby Modelica.Media.Interfaces.PartialSimpleIdealGasMedium;
  constant Modelica.Units.SI.MassFraction X_O2 = Modelica.Media.IdealGases.MixtureGases.CombustionAir.X_default[2];
  constant Modelica.Media.IdealGases.Common.DataRecord oxygen = Modelica.Media.IdealGases.Common.SingleGasesData.O2;
  parameter Real N_FC_stack(unit = "1") = 180 "FC stack number of cells";
  parameter Modelica.Units.SI.CurrentDensity j_FC_lim = 2*1e4 "FC Stack limit current density";
  parameter Modelica.Units.SI.Area A_FC_surf = 240*1e-4 "FC stack surface area" annotation(
    Placement(visible = false, transformation(extent = {{0, 0}, {0, 0}})));
  parameter Real stoic_Air_min = 1.6 "Set min air mass flow stoichiometry at max power";
  
  Modelica.Units.SI.Pressure p_out = max(Modelica.Units.Conversions.from_bar(OpCons[1].y), system.dp_small);
  Modelica.Units.SI.Pressure p_in = max(Modelica.Units.Conversions.from_bar(OpCons[3].y), system.dp_small);
  
  Modelica.Fluid.Sensors.Pressure Inlet_pressure(redeclare package Medium = Medium) annotation(
    Placement(transformation(origin = {20, 30}, extent = {{-10, -10}, {10, 10}}, rotation = -0)));
  Modelica.Blocks.Sources.RealExpression setRpm(y = max(OpCons[2].y, 1)) annotation(
    Placement(transformation(origin = {-50, 40}, extent = {{-10, -12}, {10, 12}})));
  Modelica.Blocks.Sources.RealExpression setPressureOut(y = p_out) annotation(
    Placement(transformation(origin = {-110, 8}, extent = {{-10, -12}, {10, 12}})));
  Modelica.Blocks.Sources.CombiTimeTable loadCycle(extrapolation = Modelica.Blocks.Types.Extrapolation.HoldLastPoint, fileName = Modelica.Utilities.Files.loadResource("modelica://VirtualFCS.Resources.LuT/OpCons_data.txt"), smoothness = Modelica.Blocks.Types.Smoothness.ConstantSegments, tableName = "op_cons", verboseRead = false, tableOnFile = true, columns = 2:5) annotation(
    Placement(transformation(origin = {-90, 90}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Continuous.CriticalDamping OpCons[4](each f = 1, each n = 4) annotation(
    Placement(transformation(origin = {-50, 90}, extent = {{-10, -10}, {10, 10}})));
  Fluid.CompressorPoly arb(redeclare package Medium = Medium, c_P = [2.54115e-05, 0.00503922, -3.26675e-07, 3.79697e-12; 0.0273573, 4.05285e-06, 1.7273e-11, 0; -1.37511e-05, -5.58855e-10, 0, 0; 4.00554e-09, 0, 0, 0], c_Mf = [-8.99586e-06, -2.97628e-09, 1.23047e-14; 1.53861e-07, 4.10077e-14, 0; 1.05211e-12, 0, 0], P_max = 3000, pressureRatioMode = false, tau = 0.1, useCompressionEnergy = false) annotation(
    Placement(transformation(extent = {{-16, -16}, {16, 16}})));
  Modelica.Fluid.Sources.Boundary_pT H2Source(use_p_in = true, redeclare package Medium = Medium, nPorts = 1)  annotation(
    Placement(transformation(origin = {-70, 0}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.RealExpression setPressureIn(y = p_in) annotation(
    Placement(transformation(origin = {18, -40}, extent = {{-10, -12}, {10, 12}})));
  Modelica.Electrical.Analog.Sources.ConstantVoltage constantVoltage(V = 336) annotation(
    Placement(transformation(origin = {0, 72}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Electrical.Analog.Basic.Ground ground annotation(
    Placement(transformation(origin = {-20, 62}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Fluid.Sources.Boundary_pT H2Sink(redeclare package Medium = Medium, use_p_in = true, nPorts = 1)  annotation(
    Placement(transformation(origin = {50, 0}, extent = {{10, -10}, {-10, 10}}, rotation = -0)));
equation
  connect(arb.Output, Inlet_pressure.port) annotation(
    Line(points = {{18, 0}, {20, 0}, {20, 20}}, color = {0, 127, 255}));
  connect(setRpm.y, arb.controlInterface) annotation(
    Line(points = {{-38, 40}, {-30, 40}, {-30, 10}, {-18, 10}}, color = {0, 0, 127}));
  connect(H2Source.ports[1], arb.Input) annotation(
    Line(points = {{-60, 0}, {-18, 0}}, color = {0, 127, 255}));
  connect(ground.p, constantVoltage.n) annotation(
    Line(points = {{-20, 72}, {-10, 72}}, color = {0, 0, 255}));
  connect(constantVoltage.n, arb.pin_n) annotation(
    Line(points = {{-10, 72}, {-8, 72}, {-8, 40}, {-2, 40}, {-2, 10}}, color = {0, 0, 255}));
  connect(constantVoltage.p, arb.pin_p) annotation(
    Line(points = {{10, 72}, {10, 48}, {4, 48}, {4, 10}}, color = {0, 0, 255}));
  connect(setPressureOut.y, H2Source.p_in) annotation(
    Line(points = {{-99, 8}, {-82, 8}}, color = {0, 0, 127}));
  connect(arb.Output, H2Sink.ports[1]) annotation(
    Line(points = {{18, 0}, {40, 0}}, color = {0, 127, 255}));
  connect(setPressureIn.y, H2Sink.p_in) annotation(
    Line(points = {{30, -40}, {80, -40}, {80, 8}, {62, 8}}, color = {0, 0, 127}));
  connect(loadCycle.y, OpCons.u) annotation(
    Line(points = {{-78, 90}, {-62, 90}}, color = {0, 0, 127}, thickness = 0.5));
  annotation(
    Documentation(info = "<html><head></head><body>
<p>Test of the anode recirculation blower map: a <a href=\"modelica://VirtualFCS.Fluid.CompressorPoly\">CompressorPoly</a> with <code>useCompressionEnergy = false</code> and the blower maps, operated in hydrogen between two pressure boundaries. Inlet pressure, outlet pressure and speed come from the table, filtered by critically damped filters.</p>
<h4>Operating-point input</h4>
<p>Operating points are read from the text table <code>op_cons</code> in <code>OpCons_data.txt</code>, which is a variable interface file (see <a href=\"modelica://VirtualFCS.Utilities.SystemControl\">SystemControl</a>, &quot;Operating-point input&quot;). Its column layout must match this model; a dedicated file can be set via <code>fileName</code>. Expected data columns (after the time column):</p>
<table>
<tr><td>1</td><td>Pressure of boundary <code>H2Source</code> at the blower inlet [bar] (variable <code>p_out</code>)</td></tr>
<tr><td>2</td><td>Blower speed [rpm]</td></tr>
<tr><td>3</td><td>Pressure of boundary <code>H2Sink</code> at the blower outlet [bar] (variable <code>p_in</code>)</td></tr>
<tr><td>4</td><td>Not used</td></tr>
</table>
</body></html>"),
    experiment(StopTime = 3000, Interval = 1, Tolerance = 1e-07, StartTime = 0),
  __OpenModelica_commandLineOptions = "--matchingAlgorithm=PFPlusExt --indexReductionMethod=dynamicStateSelection -d=initialization,NLSanalyticJacobian",
  __OpenModelica_simulationFlags(lv = "LOG_STDOUT,LOG_ASSERT,LOG_STATS", s = "dassl", variableFilter = ".*"));
end ARBTest;
