within VirtualFCS.SubSystems.Hydrogen;

model SubSystemHydrogenTST
  // System
  outer Modelica.Fluid.System system "System properties";
  outer Utilities.SystemControl systemControl;
  import Modelica.Constants.*;
  // Medium declaration
  replaceable package Anode_Medium = Modelica.Media.IdealGases.SingleGases.H2(Temperature(start = system.T_start), AbsolutePressure(start = system.p_start)) constrainedby Modelica.Media.Interfaces.PartialSimpleIdealGasMedium;
  //*** VALIDATION STATE VARIABLE DECLARATION*** //
  Modelica.Units.SI.Power P_arb = arb.P_el "The electrical power demand of the recirculation blower";
  // Internal state variables
  
  //*** INSTANTIATE COMPONENTS ***//
  // Interfaces and boundaries
  Modelica.Electrical.Analog.Interfaces.PositivePin pin_p annotation(
    Placement(transformation(origin = {-20, 20}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {50, -90}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Interfaces.NegativePin pin_n annotation(
    Placement(transformation(origin = {-20, 0}, extent = {{10, 10}, {-10, -10}}), iconTransformation(origin = {-30, -90}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_H2ToStack(redeclare package Medium = Anode_Medium) annotation(
    Placement(transformation(origin = {120, 74}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {-54, 119}, extent = {{-18, -19}, {18, 19}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_StackToH2(redeclare package Medium = Anode_Medium) annotation(
    Placement(transformation(origin = {120, -76}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {54, 119}, extent = {{-18, -19}, {18, 19}})));
  // Thermal components
  // Control components
  Modelica.Blocks.Sources.RealExpression setBlowerSpeed(y = systemControl.w_arb) annotation(
    Placement(transformation(origin = {-80, -20}, extent = {{-10, -10}, {10, 10}})));
  // Vessels
  // Machines
  // Sensors
  Modelica.Fluid.Sensors.MassFlowRate mflowH2(redeclare package Medium = Anode_Medium, allowFlowReversal = true) annotation(
    Placement(transformation(origin = {-20, 74}, extent = {{-10, 10}, {10, -10}})));
  // Valves
  // Other
  Modelica.Fluid.Sensors.RelativePressure relativePressure(redeclare package Medium = Anode_Medium) annotation(
    Placement(transformation(origin = {120, 0}, extent = {{10, -10}, {-10, 10}}, rotation = 90)));
  Modelica.Fluid.Fittings.TeeJunctionIdeal teeJunctionIdealToStack(redeclare package Medium = Anode_Medium) annotation(
    Placement(transformation(origin = {26, 74}, extent = {{-10, 10}, {10, -10}}, rotation = -0)));
  Modelica.Blocks.Sources.RealExpression setPressure(y = max(systemControl.p_An, Anode_Medium.p_default)) annotation(
    Placement(transformation(origin = {-136, 82}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Fluid.Sources.Boundary_pT boundary(use_p_in = true, nPorts = 1, redeclare package Medium = Anode_Medium) annotation(
    Placement(transformation(origin = {-70, 74}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Continuous.FirstOrder firstOrderPT1(T = 1) annotation(
    Placement(transformation(origin = {-106, 82}, extent = {{-6, -6}, {6, 6}})));
  Fluid.ARBPoly arb(redeclare package Medium = Anode_Medium, c_Mf = [-8.99586e-06, -2.97628e-09, 1.23047e-14; 1.53861e-07, 4.10077e-14, 0; 1.05211e-12, 0, 0], pressureRatioMode = false, P_max = 1e3, mfMin = system.m_flow_small/100, c_P = [2.78307e-05, 0.00551895, -3.57774e-07, 4.15845e-12; 0.0299617, 4.43868e-06, 1.89174e-11, 0; -1.50602e-05, -6.12058e-10, 0, 0; 4.38687e-09, 0, 0, 0]) annotation(
    Placement(transformation(origin = {26, 6}, extent = {{-14, -14}, {14, 14}}, rotation = 90)));
equation
//*** DEFINE CONNECTIONS ***//
  connect(teeJunctionIdealToStack.port_2, port_H2ToStack) annotation(
    Line(points = {{36, 74}, {120, 74}}, color = {0, 127, 255}));
  connect(firstOrderPT1.y, boundary.p_in) annotation(
    Line(points = {{-100, 82}, {-82, 82}}, color = {0, 0, 127}));
  connect(setPressure.y, firstOrderPT1.u) annotation(
    Line(points = {{-125, 82}, {-114, 82}}, color = {0, 0, 127}));
  connect(arb.Output, teeJunctionIdealToStack.port_3) annotation(
    Line(points = {{26, 22}, {26, 64}}, color = {0, 127, 255}));
  connect(setBlowerSpeed.y, arb.controlInterface) annotation(
    Line(points = {{-69, -20}, {18, -20}, {18, -10}}, color = {0, 0, 127}));
  connect(arb.pin_p, pin_p) annotation(
    Line(points = {{18, 8}, {0, 8}, {0, 20}, {-20, 20}}, color = {0, 0, 255}));
  connect(arb.pin_n, pin_n) annotation(
    Line(points = {{18, 4}, {0, 4}, {0, 0}, {-20, 0}}, color = {0, 0, 255}));
  connect(mflowH2.port_a, boundary.ports[1]) annotation(
    Line(points = {{-30, 74}, {-60, 74}}, color = {0, 127, 255}));
  connect(mflowH2.port_b, teeJunctionIdealToStack.port_1) annotation(
    Line(points = {{-10, 74}, {16, 74}}, color = {0, 127, 255}));
  connect(arb.Input, port_StackToH2) annotation(
    Line(points = {{26, -10}, {26, -76}, {120, -76}}, color = {0, 127, 255}));
  connect(relativePressure.port_a, port_H2ToStack) annotation(
    Line(points = {{120, 10}, {120, 74}}, color = {0, 127, 255}));
  connect(relativePressure.port_b, port_StackToH2) annotation(
    Line(points = {{120, -10}, {120, -76}}, color = {0, 127, 255}));
  annotation(
    Diagram(coordinateSystem(extent = {{-150, -100}, {150, 100}}, initialScale = 0.1), graphics = {Text(origin = {50, 14}, extent = {{-14, 4}, {22, -6}}, textString = "Recirculation blower")}),
    Icon(graphics = {Rectangle(fillColor = {0, 60, 101}, fillPattern = FillPattern.Solid, lineThickness = 1.5, extent = {{-100, 100}, {100, -100}}, radius = 35), Text(origin = {-78, 83}, textColor = {255, 255, 255}, extent = {{30, -23}, {128, -141}}, textString = "H2")}, coordinateSystem(extent = {{-150, -100}, {150, 100}}, initialScale = 0.1)),
    Documentation(info = "<html><head></head><body>
<p>Hydrogen supply subsystem for the anode of the
<a href=\"modelica://VirtualFCS.Electrochemical.Hydrogen.FuelCellStack\">FuelCellStack</a>, with anode recirculation.
Set points are read from the <code>outer</code>
<a href=\"modelica://VirtualFCS.Utilities.SystemControl\">SystemControl</a> instance <code>systemControl</code>.</p>

<h4>Flow path</h4>
<p>Fresh hydrogen comes from the pressure boundary <code>boundary</code>. Its pressure is
<code>max(systemControl.p_An, p_default)</code>, filtered by a first-order lag with T = 1 s.
It passes the mass flow sensor <code>mflowH2</code> and a tee junction to <code>port_H2ToStack</code> (anode inlet).
The anode exhaust at <code>port_StackToH2</code> is returned to the tee junction by the anode recirculation blower
<code>arb</code> (<a href=\"modelica://VirtualFCS.Fluid.ARBPoly\">ARBPoly</a>, maps in pressure-difference mode,
power limit <code>P_max</code> = 1 kW). Purge is not modelled; apart from recirculation the anode loop is dead-ended.</p>

<h4>Input variables (from <code>systemControl</code>)</h4>
<table>
<tr><td><code>p_An</code></td><td>Hydrogen supply pressure [Pa]</td></tr>
<tr><td><code>w_arb</code></td><td>Recirculation blower speed [rpm]</td></tr>
</table>

<h4>Relevant variables</h4>
<table>
<tr><td><code>P_arb</code> (= <code>arb.P_el</code>)</td><td>Electrical power of the recirculation blower [W]</td></tr>
<tr><td><code>mflowH2.m_flow</code></td><td>Fresh hydrogen mass flow [kg/s]</td></tr>
<tr><td><code>relativePressure.p_rel</code></td><td>Anode pressure difference stack inlet &ndash; outlet [Pa]</td></tr>
</table>

<h4>Parameters</h4>
<table>
<tr><td><code>arb.c_P</code>, <code>arb.c_Mf</code></td><td>Power and mass flow maps of the recirculation blower, see <a href=\"modelica://VirtualFCS.Fluid.PolyMover\">PolyMover</a></td></tr>
<tr><td><code>arb.tau</code></td><td>Time constant of the blower dynamics [s]</td></tr>
<tr><td><code>arb.P_max</code></td><td>Power limit of the blower [W]</td></tr>
<tr><td><code>arb.pressureRatioMode</code></td><td>Map input: pressure ratio (true) or pressure difference (false)</td></tr>
</table>
</body></html>"));
end SubSystemHydrogenTST;