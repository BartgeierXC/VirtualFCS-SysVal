within VirtualFCS.ComponentTesting;

model TestFlowResistance "Test of a mover against a flow resistance"
  extends Modelica.Icons.Example;
  inner Modelica.Fluid.System system(m_flow_small = 1e-3)  annotation(
    Placement(visible = true, transformation(origin = {90, 90}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  import Modelica.Constants.F;
  import Modelica.Constants.eps;
  replaceable package Medium = Modelica.Media.IdealGases.SingleGases.H2 constrainedby Modelica.Media.Interfaces.PartialSimpleIdealGasMedium;
  constant Modelica.Units.SI.MassFraction X_O2 = Modelica.Media.IdealGases.MixtureGases.CombustionAir.X_default[2];
  constant Modelica.Media.IdealGases.Common.DataRecord oxygen = Modelica.Media.IdealGases.Common.SingleGasesData.O2;
  
  parameter Real dp_cf_a_An(unit = "Pa*s^2/m^6") = 10;
  parameter Real dp_cf_b_An(unit = "Pa*s/m^3") = 1.6e6;
  //Real rpm_set;
  //Real p_outlet_set;
  Modelica.Fluid.Sources.FixedBoundary H2Sink(redeclare package Medium = Medium, nPorts = 1, p (displayUnit = "Pa")) annotation(
    Placement(transformation(origin = {-90, 20}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.Ramp ramp(height = 5000, duration = 50, startTime = 10) annotation(
    Placement(transformation(origin = {-90, 72}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Fluid.Fittings.GenericResistances.VolumeFlowRate volumeFlowRate(redeclare package Medium = Medium, a = dp_cf_a_An, b = dp_cf_b_An, dp(displayUnit = "Pa"), allowFlowReversal = false) annotation(
    Placement(transformation(origin = {50, 20}, extent = {{-10, -10}, {10, 10}})));
  Fluid.CompressorPoly arb(redeclare package Medium = Medium, c_P = [9.37728, -0.000144344, 2.10688e-08; 0.0172672, 1.79272e-06, 0; 6.19626e-06, 0, 0], c_Mf = [-8.99586e-06, -2.97628e-09, 1.23047e-14; 1.53861e-07, 4.10077e-14, 0; 1.05211e-12, 0, 0], pressureRatioMode = false, P_max = 1e3, mfMin = system.m_flow_small/100)  annotation(
    Placement(transformation(origin = {-30, 20}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Sources.ConstantVoltage constantVoltage(V = 336) annotation(
    Placement(transformation(origin = {-30, 70}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Electrical.Analog.Basic.Ground ground annotation(
    Placement(transformation(origin = {-50, 90}, extent = {{-10, 10}, {10, -10}}, rotation = -0)));
  Modelica.Fluid.Fittings.TeeJunctionVolume teeJunctionVolume(redeclare package Medium = Medium, V = 0.01)  annotation(
    Placement(transformation(origin = {0, -40}, extent = {{10, 10}, {-10, -10}})));
  Modelica.Fluid.Sources.MassFlowSource_T boundary(use_m_flow_in = true, redeclare package Medium = Medium, nPorts = 1)  annotation(
    Placement(transformation(origin = {-30, -70}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.Ramp ramp1(duration = 50, height = -0.001, startTime = 10) annotation(
    Placement(transformation(origin = {-90, -62}, extent = {{-10, -10}, {10, 10}})));
equation
  connect(arb.Input, H2Sink.ports[1]) annotation(
    Line(points = {{-40, 20}, {-80, 20}}, color = {0, 127, 255}));
  connect(arb.Output, volumeFlowRate.port_a) annotation(
    Line(points = {{-18, 20}, {40, 20}}, color = {0, 127, 255}));
  connect(ramp.y, arb.controlInterface) annotation(
    Line(points = {{-78, 72}, {-60, 72}, {-60, 26}, {-42, 26}}, color = {0, 0, 127}));
  connect(constantVoltage.n, ground.p) annotation(
    Line(points = {{-40, 70}, {-50, 70}, {-50, 80}}, color = {0, 0, 255}));
  connect(constantVoltage.p, arb.pin_p) annotation(
    Line(points = {{-20, 70}, {-20, 50}, {-28, 50}, {-28, 26}}, color = {0, 0, 255}));
  connect(constantVoltage.n, arb.pin_n) annotation(
    Line(points = {{-40, 70}, {-40, 50}, {-32, 50}, {-32, 26}}, color = {0, 0, 255}));
  connect(volumeFlowRate.port_b, teeJunctionVolume.port_1) annotation(
    Line(points = {{60, 20}, {80, 20}, {80, -40}, {10, -40}}, color = {0, 127, 255}));
  connect(teeJunctionVolume.port_2, arb.Input) annotation(
    Line(points = {{-10, -40}, {-60, -40}, {-60, 20}, {-40, 20}}, color = {0, 127, 255}));
  connect(boundary.ports[1], teeJunctionVolume.port_3) annotation(
    Line(points = {{-20, -70}, {0, -70}, {0, -50}}, color = {0, 127, 255}));
  connect(ramp1.y, boundary.m_flow_in) annotation(
    Line(points = {{-78, -62}, {-40, -62}}, color = {0, 0, 127}));
  annotation(
    Documentation(info = "<html><head></head><body>
<p>Test of a <a href=\"modelica://VirtualFCS.Fluid.CompressorPoly\">CompressorPoly</a> (recirculation blower maps, pressure-difference mode) in hydrogen against a generic MSL <code>VolumeFlowRate</code> resistance and a tee junction volume. The boundary mass flow and the blower speed are ramped.</p>
</body></html>"),
    experiment(StopTime = 60, Interval = 0.01, Tolerance = 1e-06, StartTime = 0),
  __OpenModelica_commandLineOptions = "--matchingAlgorithm=PFPlusExt --indexReductionMethod=dynamicStateSelection -d=initialization,NLSanalyticJacobian",
  __OpenModelica_simulationFlags(lv = "LOG_STDOUT,LOG_ASSERT,LOG_EVENTS,LOG_NLS,LOG_STATS", s = "dassl", variableFilter = ".*", cpu = "()"));
end TestFlowResistance;