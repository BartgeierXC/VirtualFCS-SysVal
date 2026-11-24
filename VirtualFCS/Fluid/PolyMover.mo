within VirtualFCS.Fluid;

model PolyMover
  "Map-driven prescribed-flow mover with optional power-based compression heating"
  outer Modelica.Fluid.System system "System properties";
  replaceable package Medium = Modelica.Media.Air.MoistAir(Temperature(start = system.T_start), AbsolutePressure(start = system.p_start));
  import Modelica.Constants.*;
  import VirtualFCS.Utilities.Poly2D;
  parameter Modelica.Units.SI.Time tau = 1 "Time constant of mover dynamic delay";
  parameter Real c_P[:,:] = [5.83644e-06, -1.02647e-07, -8.78674e-06, -3.17918e-06; 0.144014, -0.168674, -0.063471, 0; -7.79335e-08, 4.54513e-06, 0, 0; -2.82827e-11, 0, 0, 0];
  parameter Real c_Mf[:,:] = [0.21335, -0.269277, -0.0385578; 1.38927e-06, 3.93004e-06, 0; -2.93973e-11, 0, 0];
  parameter Real eta_el = 0.9 "Share of map power not added to the gas (outlet heating = (1 - eta_el)*P)";
  parameter Modelica.Units.SI.Power P_max = 100000;
  parameter Boolean pressureRatioMode = true "= true to use p_out/p_in as map input, else p_out-p_in";
  parameter Boolean useCompressionEnergy = true "= true to raise outlet enthalpy from map compression power / m_flow" annotation(
    Evaluate = true);
  parameter Modelica.Units.SI.MassFlowRate mfMin = system.m_flow_small;
  Modelica.Fluid.Interfaces.FluidPort_a Input(redeclare package Medium = Medium) annotation(
    Placement(visible = true, transformation(origin = {-80, -40}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {-110, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Fluid.Interfaces.FluidPort_b Output(redeclare package Medium = Medium) annotation(
    Placement(visible = true, transformation(origin = {84, -40}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {110, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Electrical.Analog.Interfaces.PositivePin pin_p annotation(
    Placement(visible = true, transformation(origin = {-38, 96}, extent = {{10, -10}, {-10, 10}}, rotation = 0), iconTransformation(origin = {20, 60}, extent = {{-6, -6}, {6, 6}}, rotation = 0)));
  Modelica.Electrical.Analog.Interfaces.NegativePin pin_n annotation(
    Placement(visible = true, transformation(origin = {-62, 96}, extent = {{10, -10}, {-10, 10}}, rotation = 0), iconTransformation(origin = {-16, 60}, extent = {{-6, -6}, {6, 6}}, rotation = 0)));
  Modelica.Blocks.Interfaces.RealOutput speed annotation(
    Placement(visible = true, transformation(origin = {110, 32}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {0, -66}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Blocks.Interfaces.RealInput controlInterface annotation(
    Placement(visible = true, transformation(origin = {-114, 40}, extent = {{-14, -14}, {14, 14}}, rotation = 0), iconTransformation(origin = {-113, 61}, extent = {{-13, -13}, {13, 13}}, rotation = 0)));
  Modelica.Units.SI.Power P_el "Electrical power consumed by the mover";
  Modelica.Units.SI.Power Power_Compressor = P_el "Alias of P_el for compressor instances";
  Modelica.Electrical.Analog.Sources.SignalCurrent signalCurrent annotation(
    Placement(visible = true, transformation(origin = {30, 88}, extent = {{-8, -8}, {8, 8}}, rotation = -90)));
  Modelica.Blocks.Continuous.FirstOrder compressionDelaySpeed(T = tau, initType = Modelica.Blocks.Types.Init.InitialOutput) annotation(
    Placement(visible = true, transformation(origin = {84, 32}, extent = {{-4, -4}, {4, 4}}, rotation = 0)));
  Modelica.Electrical.Analog.Sensors.PowerSensor powerBat annotation(
    Placement(visible = true, transformation(origin = {-50, 80}, extent = {{6, -6}, {-6, 6}}, rotation = 0)));
  Modelica.Blocks.Continuous.Integrator powerController(initType = Modelica.Blocks.Types.Init.InitialOutput, y_start = 0) annotation(
    Placement(visible = true, transformation(origin = {66, 88}, extent = {{6, -6}, {-6, 6}}, rotation = 0)));
  Modelica.Blocks.Math.Feedback feedbackPower annotation(
    Placement(visible = true, transformation(origin = {68, 48}, extent = {{6, -6}, {-6, 6}}, rotation = -90)));
  Modelica.Blocks.Continuous.FirstOrder compressionDelayPower(T = tau, initType = Modelica.Blocks.Types.Init.InitialOutput) annotation(
    Placement(transformation(origin = {62, 20}, extent = {{-4, -4}, {4, 4}})));
  Modelica.Blocks.Sources.RealExpression pressureRatio(y = Output.p/(Input.p + eps)) annotation(
    Placement(transformation(origin = {-87, 12}, extent = {{-7, -10}, {7, 10}})));
  Modelica.Blocks.Continuous.FirstOrder compressionDelayFlow(T = tau, initType = Modelica.Blocks.Types.Init.InitialOutput, y_start = mfMin) annotation(
    Placement(transformation(origin = {-24, -12}, extent = {{4, -4}, {-4, 4}})));
  Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate(redeclare package Medium = Medium, m_flow_small = system.m_flow_small) annotation(
    Placement(visible = true, transformation(origin = {30, -40}, extent = {{-6, -6}, {6, 6}}, rotation = 0)));
  Modelica.Blocks.Nonlinear.Limiter limiterMf(uMin = mfMin, uMax = inf) annotation(
    Placement(transformation(origin = {10, -12}, extent = {{4, -4}, {-4, 4}}, rotation = -0)));
  Modelica.Blocks.Nonlinear.Limiter limiterPmax(uMax = P_max, uMin = eps) annotation(
    Placement(transformation(origin = {44, 20}, extent = {{-4, -4}, {4, 4}}, rotation = -0)));
  Modelica.Fluid.Sensors.Temperature temperature(redeclare package Medium = Medium) annotation(
    Placement(transformation(origin = {38, -18}, extent = {{-10, -10}, {10, 10}})));
  Utilities.Poly2D poly2DPower(c = c_P) annotation(
    Placement(transformation(origin = {-10, 50}, extent = {{-10, -10}, {10, 10}})));
  Utilities.Poly2D poly2DMassflow(c = c_Mf) annotation(
    Placement(transformation(origin = {-10, 10}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.RealExpression pressureDifference(y = max(Output.p - Input.p, 1e-3)) annotation(
    Placement(transformation(origin = {-87, -4}, extent = {{-7, -10}, {7, 10}})));
  Modelica.Blocks.Logical.Switch switchPressureMode annotation(
    Placement(transformation(origin = {-50, 4}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.BooleanExpression pressureMode(y = pressureRatioMode) annotation(
    Placement(transformation(origin = {-120, 4}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Nonlinear.Limiter limiterRpm(uMax = inf, uMin = 1) annotation(
    Placement(transformation(origin = {-60, 40}, extent = {{-4, -4}, {4, 4}})));
  Buildings.Fluid.Movers.BaseClasses.IdealSource idealMFC(redeclare package Medium = Medium, allowFlowReversal = true, control_m_flow = true, m_flow_small = system.m_flow_small/1000, m_flow_start = system.m_flow_small/1000, show_V_flow = false) annotation(
    Placement(transformation(origin = {-30, -40}, extent = {{-10, -10}, {10, 10}})));
  IsentropicEnthalpyRise isentropicRise(redeclare package Medium = Medium, allowFlowReversal = true, useCompressionEnergy = useCompressionEnergy, eta_el = eta_el) annotation(
    Placement(transformation(origin = {0, -40}, extent = {{-10, -10}, {10, 10}})));
equation
  assert(volumeFlowRate.V_flow > -eps, "Mover flow inverted!");
  P_el = pin_p.i*pin_p.v;
  connect(powerBat.power, feedbackPower.u2) annotation(
    Line(points = {{-44, 74}, {12, 74}, {12, 48}, {63, 48}}, color = {0, 0, 127}));
  connect(feedbackPower.y, powerController.u) annotation(
    Line(points = {{68, 53}, {68, 60}, {80, 60}, {80, 88}, {73, 88}}, color = {0, 0, 127}));
  connect(powerController.y, signalCurrent.i) annotation(
    Line(points = {{59, 88}, {40, 88}}, color = {0, 0, 127}));
  connect(pin_n, powerBat.nc) annotation(
    Line(points = {{-62, 96}, {-62, 80}, {-56, 80}}, color = {0, 0, 255}));
  connect(powerBat.nv, pin_n) annotation(
    Line(points = {{-50, 74}, {-62, 74}, {-62, 96}}, color = {0, 0, 255}));
  connect(powerBat.pv, pin_p) annotation(
    Line(points = {{-50, 86}, {-38, 86}, {-38, 96}}, color = {0, 0, 255}));
  connect(pin_p, signalCurrent.p) annotation(
    Line(points = {{-38, 96}, {30, 96}}, color = {0, 0, 255}));
  connect(signalCurrent.n, powerBat.pc) annotation(
    Line(points = {{30, 80}, {-44, 80}}, color = {0, 0, 255}));
  connect(compressionDelaySpeed.y, speed) annotation(
    Line(points = {{88, 32}, {110, 32}}, color = {0, 0, 127}));
  connect(compressionDelayPower.y, feedbackPower.u1) annotation(
    Line(points = {{66, 20}, {68, 20}, {68, 44}}, color = {0, 0, 127}));
  connect(volumeFlowRate.port_b, Output) annotation(
    Line(points = {{36, -40}, {84, -40}}, color = {0, 127, 255}));
  connect(limiterMf.y, compressionDelayFlow.u) annotation(
    Line(points = {{6, -12}, {-19, -12}}, color = {0, 0, 127}));
  connect(limiterPmax.y, compressionDelayPower.u) annotation(
    Line(points = {{48, 20}, {58, 20}}, color = {0, 0, 127}));
  connect(poly2DMassflow.y, limiterMf.u) annotation(
    Line(points = {{2, 10}, {20, 10}, {20, -12}, {14, -12}}, color = {0, 0, 127}));
  connect(poly2DPower.y, limiterPmax.u) annotation(
    Line(points = {{2, 50}, {8, 50}, {8, 20}, {40, 20}}, color = {0, 0, 127}));
  connect(switchPressureMode.y, poly2DMassflow.u2) annotation(
    Line(points = {{-38, 4}, {-22, 4}}, color = {0, 0, 127}));
  connect(switchPressureMode.y, poly2DPower.u2) annotation(
    Line(points = {{-38, 4}, {-26, 4}, {-26, 44}, {-22, 44}}, color = {0, 0, 127}));
  connect(pressureDifference.y, switchPressureMode.u3) annotation(
    Line(points = {{-80, -4}, {-62, -4}}, color = {0, 0, 127}));
  connect(pressureRatio.y, switchPressureMode.u1) annotation(
    Line(points = {{-80, 12}, {-62, 12}}, color = {0, 0, 127}));
  connect(pressureMode.y, switchPressureMode.u2) annotation(
    Line(points = {{-108, 4}, {-62, 4}}, color = {255, 0, 255}));
  connect(controlInterface, limiterRpm.u) annotation(
    Line(points = {{-114, 40}, {-64, 40}}, color = {0, 0, 127}));
  connect(limiterRpm.y, compressionDelaySpeed.u) annotation(
    Line(points = {{-56, 40}, {50, 40}, {50, 32}, {80, 32}}, color = {0, 0, 127}));
  connect(limiterRpm.y, poly2DPower.u1) annotation(
    Line(points = {{-56, 40}, {-32, 40}, {-32, 56}, {-22, 56}}, color = {0, 0, 127}));
  connect(limiterRpm.y, poly2DMassflow.u1) annotation(
    Line(points = {{-56, 40}, {-32, 40}, {-32, 16}, {-22, 16}}, color = {0, 0, 127}));
  connect(idealMFC.port_a, Input) annotation(
    Line(points = {{-40, -40}, {-80, -40}}, color = {0, 127, 255}));
  connect(idealMFC.port_b, isentropicRise.port_a) annotation(
    Line(points = {{-20, -40}, {-10, -40}}, color = {0, 127, 255}));
  connect(isentropicRise.port_b, volumeFlowRate.port_a) annotation(
    Line(points = {{10, -40}, {24, -40}}, color = {0, 127, 255}));
  connect(temperature.port, isentropicRise.port_b) annotation(
    Line(points = {{38, -28}, {10, -28}, {10, -40}}, color = {0, 127, 255}));
  connect(compressionDelayFlow.y, idealMFC.m_flow_in) annotation(
    Line(points = {{-28, -12}, {-36, -12}, {-36, -32}}, color = {0, 0, 127}));
  connect(pressureRatio.y, isentropicRise.pressureRatio) annotation(
    Line(points = {{-80, 12}, {-70, 12}, {-70, -24}, {-6, -24}, {-6, -32}}, color = {0, 0, 127}));
  connect(compressionDelayPower.y, isentropicRise.compressionPower) annotation(
    Line(points = {{66, 20}, {68, 20}, {68, 0}, {24, 0}, {24, -24}, {6, -24}, {6, -32}}, color = {0, 0, 127}));
  annotation(
    Icon(graphics = {Polygon(visible = false, lineColor = {255, 255, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, points = {{20, -75}, {50, -85}, {20, -95}, {20, -75}}), Line(visible = false, points = {{55, -85}, {-60, -85}}, color = {0, 128, 255}), Polygon(visible = false, lineColor = {0, 128, 255}, fillColor = {0, 128, 255}, fillPattern = FillPattern.Solid, points = {{20, -70}, {60, -85}, {20, -100}, {20, -70}}), Polygon(origin = {15, 0}, fillColor = {208, 208, 208}, pattern = LinePattern.None, fillPattern = FillPattern.Solid, points = {{-115, 80}, {-115, -80}, {85, -50}, {85, 50}, {85, 50}, {-115, 80}}), Line(origin = {5.2, 0.61}, points = {{-57, 0}, {47, 0}}, thickness = 1.5, arrow = {Arrow.None, Arrow.Filled}, arrowSize = 20, smooth = Smooth.Bezier)}, coordinateSystem(initialScale = 0.1)),
    Documentation(info = "<html><body>
<p>Prescribed-flow mover driven by two <code>Poly2D</code> maps for mass flow (<code>c_Mf</code>) and electrical power (<code>c_P</code>). The map inputs are the speed set point <code>controlInterface</code> [rpm] and either the pressure ratio (<code>pressureRatioMode = true</code>) or the pressure difference across the mover.</p>
<ul>
<li>The mass flow is imposed by a Buildings <code>IdealSource</code> after a first-order delay <code>tau</code>; there is no shaft model.</li>
<li>The electrical power <code>P_el</code> follows the delayed power map (limited to <code>P_max</code>) through a current source with integral feedback.</li>
<li>With <code>useCompressionEnergy = true</code>, <code>isentropicRise</code> sets the outlet enthalpy to the isentropic enthalpy for the current pressure ratio plus the share <code>(1 - eta_el)</code> of the map power. <code>eta_el</code> does not change <code>P_el</code>.</li>
<li>The simulation stops if the volume flow becomes negative (assertion &quot;Mover flow inverted!&quot;).</li>
</ul>
<h4>Connectors</h4>
<table>
<tr><td><code>Input</code>, <code>Output</code></td><td>Fluid inlet and outlet</td></tr>
<tr><td><code>pin_p</code>, <code>pin_n</code></td><td>Electrical supply</td></tr>
<tr><td><code>controlInterface</code></td><td>Speed set point [rpm], limited to at least 1</td></tr>
<tr><td><code>speed</code></td><td>Delayed speed [rpm]</td></tr>
</table>
<h4>Parameters</h4>
<table>
<tr><td><code>c_Mf</code></td><td>Poly2D coefficients of the mass flow map [kg/s]; inputs speed [rpm] and pressure ratio [-] or pressure difference [Pa]</td></tr>
<tr><td><code>c_P</code></td><td>Poly2D coefficients of the electrical power map [W]; same inputs</td></tr>
<tr><td><code>P_max</code></td><td>Upper limit of the map power [W]</td></tr>
<tr><td><code>mfMin</code></td><td>Lower limit of the map mass flow [kg/s]</td></tr>
<tr><td><code>tau</code></td><td>Time constant of the first-order delays of speed, mass flow and power [s]</td></tr>
</table>
</body></html>"));
end PolyMover;