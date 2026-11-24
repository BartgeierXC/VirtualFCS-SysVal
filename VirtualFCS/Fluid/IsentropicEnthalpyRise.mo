within VirtualFCS.Fluid;

model IsentropicEnthalpyRise
  "Two-port with zero dp; optional outlet enthalpy rise from compression power"
  extends Modelica.Fluid.Interfaces.PartialTwoPortTransport;
  parameter Boolean useCompressionEnergy = true "= true to set outlet enthalpy from compressionPower / m_flow" annotation(
    Evaluate = true);
  parameter Real eta_el = 0.9 "Share of compressionPower not added to the gas (outlet heating = (1 - eta_el)*compressionPower)";
  parameter Modelica.Units.SI.MassFlowRate m_flow_heatMin = 1e-2
    "Minimum mass flow used when converting compression power to outlet enthalpy rise";
  parameter Modelica.Units.SI.TemperatureDifference dT_max = 200
    "Maximum outlet temperature rise from compression heating";

  Medium.IsentropicExponent gamma = Medium.isentropicExponent(state_a);
  Medium.Temperature T_in = Medium.temperature(state_a) "Inlet temperature";
  Medium.Temperature T_out "Outlet temperature after optional compression heating";
  Real pr "Mover pressure ratio p_out/p_in, floored at 1";
  Modelica.Units.SI.SpecificEnthalpy h_in = inStream(port_a.h_outflow);
  Modelica.Units.SI.SpecificEnthalpy h_is = Medium.specificEnthalpy_pTX(port_b.p, T_in * pr^((gamma - 1)/gamma), X_in);
  Modelica.Units.SI.SpecificEnthalpy h_out_sum = h_is + max((1-eta_el)*compressionPower, 0)/max(m_flow, m_flow_heatMin);
  Modelica.Units.SI.SpecificEnthalpy h_out_max = Medium.specificEnthalpy_pTX(port_b.p, T_in + dT_max, X_in);
  Modelica.Units.SI.SpecificEnthalpy h_out = min(h_out_sum, h_out_max);
  Real eta_is = (h_is - h_in)/max(h_out - h_in, Modelica.Constants.eps) "Derived isentropic efficiency";
  Medium.MassFraction X_in[Medium.nX] = cat(1, inStream(port_a.Xi_outflow), {1 - sum(inStream(port_a.Xi_outflow))});
  Modelica.Blocks.Interfaces.RealInput pressureRatio "Mover pressure ratio p_out/p_in (for h_is / eta_is only)" annotation(
    Placement(transformation(origin = {-50, 100}, extent = {{-20, -20}, {20, 20}}, rotation = -90), iconTransformation(origin = {-60, 80}, extent = {{-20, -20}, {20, 20}}, rotation = -90)));
  Modelica.Blocks.Interfaces.RealInput compressionPower "Fluid compression power [W] used for h_out" annotation(
    Placement(transformation(origin = {50, 100}, extent = {{-20, -20}, {20, 20}}, rotation = -90), iconTransformation(origin = {60, 80}, extent = {{-20, -20}, {20, 20}}, rotation = -90)));
equation
  dp = 0;
  pr = max(pressureRatio, 1);
  if useCompressionEnergy then
    port_b.h_outflow = h_out;
    T_out = Medium.temperature(Medium.setState_phX(port_b.p, h_out, X_in));
  else
    T_out = T_in;
    port_b.h_outflow = inStream(port_a.h_outflow);
  end if;
  port_a.h_outflow = if allowFlowReversal then inStream(port_b.h_outflow) else Medium.h_default;
  annotation(
    Documentation(info = "<html><body>
<p>Static two-port with <code>dp = 0</code>; the pressure rise is imposed by the upstream flow source.</p>
<p>If <code>useCompressionEnergy</code> is true, the outlet enthalpy is</p>
<pre>h_is  = h(p_out, T_in*pr^((gamma - 1)/gamma), X_in)
h_out = min(h_is + max((1 - eta_el)*compressionPower, 0)/max(m_flow, m_flow_heatMin), h(p_out, T_in + dT_max, X_in))</pre>
<ul>
<li><code>pr = max(pressureRatio, 1)</code> is the mover pressure ratio and <code>gamma</code> the isentropic exponent at the inlet.</li>
<li><code>eta_el</code> only sets the share of <code>compressionPower</code> that is added to the gas as heat on top of the isentropic enthalpy rise. It does not influence the electrical power of the mover.</li>
<li><code>m_flow_heatMin</code> limits the heating at vanishing mass flow, and <code>dT_max</code> caps the outlet temperature rise.</li>
<li><code>eta_is = (h_is - h_in)/(h_out - h_in)</code> is a derived isentropic efficiency and does not enter the equations.</li>
</ul>
<p>If <code>useCompressionEnergy</code> is false, the enthalpy is passed through unchanged.</p>
</body></html>"));
end IsentropicEnthalpyRise;
