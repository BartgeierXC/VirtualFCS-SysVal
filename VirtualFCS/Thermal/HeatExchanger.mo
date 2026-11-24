within VirtualFCS.Thermal;

model HeatExchanger
outer Modelica.Fluid.System system "System properties";
extends Modelica.Fluid.Interfaces.PartialTwoPort;
  replaceable package Medium = Modelica.Media.Interfaces.PartialMedium "Medium model" annotation (choicesAllMatching=true);
  Modelica.Units.SI.HeatFlowRate Q_a, Q_b;
  Modelica.Units.SI.Temperature T_b "Temperature at port_b";
  Real NTU "Number of transfer units k_th / (|m_flow|*cp)";
  Real effectiveness "NTU effectiveness 1 - exp(-NTU)";
  Medium.SpecificEnthalpy h_a;
  Medium.SpecificHeatCapacity cp_a "Inlet specific heat capacity";
  Modelica.Units.SI.Temperature T_a = Medium.temperature(state_a);
  parameter Modelica.Units.SI.ThermalConductance k_th = 1000 "Thermal conductance between medium and thermal mass";
  parameter Real ntuMax(min=1) = 50
    "Upper bound on NTU used when mass flow vanishes (effectiveness -> 1)";
  parameter Modelica.Units.SI.Pressure dp = 1000;
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heatport_a annotation(
    Placement(transformation(origin = {0, 100}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {0, 27}, extent = {{-10, -10}, {10, 10}})));
protected
  Medium.ThermodynamicState state_a "State for medium inflowing through port_a";
  Medium.ThermodynamicState state_b "State at the actual port_b outlet (p, T_b, Xi)";
  Modelica.Units.SI.ThermalConductance C_flow_a "Capacity rate |m_flow|*cp_a";
equation
//medium states
  state_a = Medium.setState_phX(port_a.p, inStream(port_a.h_outflow), inStream(port_a.Xi_outflow));
  h_a = Medium.specificEnthalpy(state_a);
  cp_a = Medium.specificHeatCapacityCp(state_a);
  Q_a = h_a*port_a.m_flow;
  Q_b = port_b.h_outflow*port_b.m_flow;
  Q_a + Q_b + heatport_a.Q_flow = 0.0;
// Closed-form NTU solution for a fluid exchanging heat with a uniform-temperature wall
  C_flow_a = abs(port_a.m_flow)*cp_a;
  NTU = k_th / noEvent(max(C_flow_a, k_th/ntuMax));
  effectiveness = 1 - exp(-NTU);
  T_b = T_a + effectiveness*(heatport_a.T - T_a);
// Pressure drop in design flow direction
  dp = port_a.p - port_b.p;
  port_a.h_outflow = inStream(port_b.h_outflow);
  state_b = Medium.setState_pTX(port_b.p, T_b, port_b.Xi_outflow);
  port_b.h_outflow = Medium.specificEnthalpy(state_b);
// Mass balance (no storage)
  port_a.m_flow + port_b.m_flow = 0;
// Transport of substances
  port_a.Xi_outflow = inStream(port_b.Xi_outflow);
  port_b.Xi_outflow = inStream(port_a.Xi_outflow);
  port_a.C_outflow = inStream(port_b.C_outflow);
  port_b.C_outflow = inStream(port_a.C_outflow);

  annotation(
    Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}), graphics = {Rectangle( lineColor = {255, 0, 0}, fillColor = {85, 170, 0}, fillPattern = FillPattern.HorizontalCylinder, borderPattern = BorderPattern.Raised, extent = {{-72, 16}, {72, -16}}, radius = 2), Line(origin = {-79, 0}, points = {{-11, 0}, {7, 0}}, thickness = 2), Line(origin = {79, 0}, points = {{-7, 0}, {11, 0}}, thickness = 2)}),
    graphics = {Text(extent = {{-69, 7}, {71, -24}}, textString = "%C")},
    Diagram(graphics),
    Documentation(info = "<html><head></head><body>
<p>Single-fluid heat exchanger that transfers heat between the fluid at
<code>port_a</code>/<code>port_b</code> and a thermal mass via
<code>heatport_a</code>. The wall is treated as spatially uniform (one heat
port), so the energy balance together with a log-mean temperature difference
has the closed-form NTU solution</p>
<pre>T_b = T_wall + (T_a - T_wall)*exp(-k_th / (|m_flow|*cp))
Q   = m_flow*(h_b - h_a)</pre>
<p>which is what this model evaluates (<code>NTU = k_th/(|m_flow|*cp)</code>,
<code>effectiveness = 1 - exp(-NTU)</code>, <code>cp</code> at the inlet state).</p>
<ul>
<li><code>T_b</code> is an explicit convex combination of the inlet and the wall temperature, so it cannot cross the wall temperature. This keeps the model robust when the inlet temperature crosses the wall temperature (thermal pinch), see <a href=\"modelica://VirtualFCS.ComponentTesting.HeatExchangerPinchTest\">HeatExchangerPinchTest</a>.</li>
<li>At vanishing flow, NTU is capped at <code>ntuMax</code> (effectiveness &rarr; 1, <code>T_b</code> &rarr; wall temperature, heat flow &rarr; 0).</li>
<li>Fixed pressure drop <code>dp</code> [Pa] in the design flow direction; no mass or energy storage.</li>
</ul>
<h4>Parameters</h4>
<table>
<tr><td><code>k_th</code></td><td>Thermal conductance between medium and thermal mass [W/K]</td></tr>
<tr><td><code>ntuMax</code></td><td>Upper bound of NTU at vanishing mass flow [-]</td></tr>
<tr><td><code>dp</code></td><td>Pressure drop [Pa]</td></tr>
</table>
</body></html>"));
end HeatExchanger;
