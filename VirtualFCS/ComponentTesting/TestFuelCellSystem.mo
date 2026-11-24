within VirtualFCS.ComponentTesting;

model TestFuelCellSystem "Fuel cell system operated along the operating points provided by SystemControl"
  extends Modelica.Icons.Example;
  inner Modelica.Fluid.System system( m_flow_start = system.m_flow_small, dp_small(displayUnit = "Pa") = 10, m_flow_small = 1e-6, p_ambient(displayUnit = "bar") = 95000, T_ambient = 298.15)  annotation(
    Placement(visible = true, transformation(origin = {-90, -90}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  inner Utilities.SystemControl systemControl(table = [1, 100, 130000, 3000, 0.95, 1, 1e5, 0.1, 0.1; 10, 100, 130000, 3000, 0.95, 1, 1e5, 0.5, 0.5; 100, 100, 130000, 3000, 0.8, 1, 1e5, 0.5, 1; 200, 240, 130000, 3000, 0.8, 1, 1e5, 0.5, 1], tableOnFile = true, tau = 0.1)  annotation(
    Placement(transformation(origin = {-90, 90}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Sources.SignalCurrent signalCurrent annotation(
    Placement(transformation(origin = {0, 60}, extent = {{10, -10}, {-10, 10}})));
  // FCS configured for manual pump control
  Electrochemical.Hydrogen.FuelCellSystem fuelCellSystem annotation(
    Placement(transformation(extent = {{-20, -20}, {20, 20}})));
  Modelica.Electrical.Analog.Sources.ConstantVoltage constantVoltage(V = 336) annotation(
    Placement(transformation(origin = {0, -60}, extent = {{10, -10}, {-10, 10}}, rotation = -0)));
  Modelica.Electrical.Analog.Basic.Ground ground annotation(
    Placement(transformation(origin = {-20, -70}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.RealExpression realExpression(y = systemControl.I)  annotation(
    Placement(transformation(origin = {60, 80}, extent = {{10, -10}, {-10, 10}}, rotation = -0)));
equation
  connect(fuelCellSystem.pin_p, signalCurrent.p) annotation(
    Line(points = {{10, 18}, {10, 60}}, color = {0, 0, 255}));
  connect(fuelCellSystem.pin_n, signalCurrent.n) annotation(
    Line(points = {{-10, 18}, {-10, 60}}, color = {0, 0, 255}));
  connect(constantVoltage.p, fuelCellSystem.pin_p_bat) annotation(
    Line(points = {{10, -60}, {10, -18}}, color = {0, 0, 255}));
  connect(constantVoltage.n, fuelCellSystem.pin_n_bat) annotation(
    Line(points = {{-10, -60}, {-10, -18}}, color = {0, 0, 255}));
  connect(constantVoltage.n, ground.p) annotation(
    Line(points = {{-10, -60}, {-20, -60}}, color = {0, 0, 255}));
  connect(realExpression.y, signalCurrent.i) annotation(
    Line(points = {{50, 80}, {0, 80}, {0, 72}}, color = {0, 0, 127}));
  annotation(
    Diagram,
    Icon,
    Documentation(info = "<html><head></head><body>
<p>This example operates a <a href=\"modelica://VirtualFCS.Electrochemical.Hydrogen.FuelCellSystem\">FuelCellSystem</a> (fuel cell stack with hydrogen, air and cooling subsystems) along the operating points provided by <code>systemControl</code>.</p>
<ul>
<li>The stack load is a <code>SignalCurrent</code> source that follows the current set point <code>systemControl.I</code>.</li>
<li>The remaining set points (anode pressure, blower and compressor speed, valve positions, coolant pump power, coolant supply conditions) are read by the subsystems from <code>systemControl</code>.</li>
<li>With <code>tableOnFile = true</code>, <code>systemControl</code> reads its operating points from the file given by <code>systemControl.fileName</code>. The inline <code>table</code> is only used when <code>tableOnFile = false</code>.</li>
<li>The <code>ConstantVoltage</code> source represents the DC bus that supplies the balance-of-plant components (compressor, recirculation blower, coolant pump).</li>
</ul>
<p>This model is the reference simulation for regression checks of the library. By default <code>systemControl</code> reads the interface file <code>OpCons_data.txt</code>, which must have the SystemControl layout (at least 8 data columns, see <a href=\"modelica://VirtualFCS.Utilities.SystemControl\">SystemControl</a>).</p>
</body></html>"),
    experiment(StartTime = 0, StopTime = 840, Tolerance = 0.0001, Interval = 1),
    __OpenModelica_commandLineOptions = "--matchingAlgorithm=PFPlusExt --indexReductionMethod=dynamicStateSelection -d=initialization -d=backenddaeinfo,bltdump",
    __OpenModelica_simulationFlags(cpu = "()", lv = "LOG_STDOUT,LOG_ASSERT,LOG_STATS", s = "dassl",variableFilter = ".*"));
end TestFuelCellSystem;
