within VirtualFCS.Fluid;

model FlowResistanceTemp "Flow model for generic resistance parameterized with the mass flow rate"
  extends Modelica.Fluid.Dissipation.Utilities.Icons.PressureLoss.General_i;
  extends Modelica.Fluid.Interfaces.PartialTwoPortTransport;
  parameter Real K_l = 4.822124e+02 "Coefficient for laminar term [kPa.s/kg]";
  parameter Real K_t = 2.362020e+03 "Coefficient for turbulent term; dp_turb [kPa] = K_t*m_flow^K_exp with m_flow in kg/s";
  parameter Real K_exp = 3.874072 "Exponent of the turbulent term [-]";

  parameter Modelica.Units.SI.Pressure p_ref = Medium.reference_p;
  Real sigma "Pressure correction factor.";
  Real Vf_nl = V_flow*60000;
  Real Vf_small = m_flow_small/rho_ref/100;
  parameter Modelica.Units.SI.Temperature T_ref = Medium.reference_T;
  Modelica.Blocks.Interfaces.RealInput T annotation(
    Placement(transformation(origin = {-120, -60}, extent = {{-20, -20}, {20, 20}}), iconTransformation(origin = {-120, 40}, extent = {{-20, -20}, {20, 20}})));
  
  Medium.Density d_a "Density at port_a when fluid is flowing from port_a to port_b";
  Medium.Density d_b "If allowFlowReversal=true then density at port_b when fluid is flowing from port_b to port_a else d_a";
  constant Modelica.Units.SI.Density rho_ref = Medium.density_phX(Medium.reference_p, Medium.h_default, Medium.X_default);
equation
// Isenthalpic state transformation (no storage and no loss of energy)
  port_a.h_outflow = inStream(port_b.h_outflow);
  port_b.h_outflow = inStream(port_a.h_outflow);
// Medium properties
  d_a = Medium.density(state_a);
  if allowFlowReversal then
    d_b = Medium.density(state_b);
  else
    d_b = d_a;
  end if;
  sigma = T_ref*port_a.p^2/(T*p_ref^2);
  dp * sigma = (K_l*m_flow + K_t*Modelica.Fluid.Dissipation.Utilities.Functions.General.SmoothPower(m_flow, m_flow_small/100, K_exp))*1e3;
  annotation(
    Documentation(info = "<html><head></head><body>
<p>Pressure loss as a function of mass flow and temperature:</p>
<pre>dp*sigma = (K_l*m_flow + K_t*m_flow^K_exp)*1e3,   sigma = T_ref*p_a^2/(T*p_ref^2)</pre>
<p>with <code>p_a</code> the inlet pressure and <code>T_ref</code>, <code>p_ref</code> defaulting to the medium reference
state. The pressure ratio enters <code>sigma</code> squared. The power term is regularised with <code>SmoothPower</code>
(transition at <code>m_flow_small/100</code>). The flow is isenthalpic without storage. <code>Vf_nl</code> is the volume
flow in l/min (diagnostic).</p>

<h4>Units (derived from the implementation)</h4>
<p>With <code>dp</code> in Pa and <code>m_flow</code> in kg/s:</p>
<pre>K_l   [kPa*s/kg]
dp_turb [kPa] = K_t*(m_flow [kg/s])^K_exp   (K_t has no fixed unit because K_exp varies)
K_exp [-]</pre>

<h4>Inputs</h4>
<table>
<tr><td><code>T</code></td><td>Gas temperature [K]</td></tr>
</table>
<p>To be completed: data on which the default fit is based.</p>
</body></html>"));
end FlowResistanceTemp;
