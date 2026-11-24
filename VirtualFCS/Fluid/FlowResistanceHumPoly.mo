within VirtualFCS.Fluid;

model FlowResistanceHumPoly "Flow model for generic resistance parameterized with the mass flow rate"
  extends Modelica.Fluid.Dissipation.Utilities.Icons.PressureLoss.General_i;
  extends Modelica.Fluid.Interfaces.PartialTwoPortTransport;

  parameter Real M_K_l[:, :](each unit = "dbar.s/g") = [0.153725, -0.00204154;-0.00162921, 2.77099e-05] "Polynomial coefficients of the laminar term; first input dew point [degC], second input temperature [degC]";
  parameter Real M_K_t[:, :] = [227.01, -3.26296;-1.44609, 0.0335717] "Polynomial coefficients of the turbulent term, dp_turb [dbar] = K_t*(m_flow [kg/s])^K_exp; first input dew point [degC], second input temperature [degC]";
  parameter Real M_K_exp[:, :] = [12.8077, -0.171105;-0.147321, 0.00236144] "Polynomial coefficients of the exponent term; first input dew point [degC], second input temperature [degC]";
  
  parameter Real K_l_min = 0.015;
  parameter Real K_l_max = 0.055;
  parameter Real K_t_min = 18;
  parameter Real K_t_max = 92;
  parameter Real K_exp_min = 1;
  parameter Real K_exp_max = 4.2;
  parameter Medium.AbsolutePressure dp_max = 100000 "Default max pressure drop";
  
  constant Modelica.Units.SI.Temperature T_ref = 273.15 "Reference temperature of the fitted coefficients";

  
  Modelica.Units.SI.MassFraction Xw_in = port_a.Xi_outflow[1];
  Modelica.Units.SI.Pressure p_steam;
  Modelica.Units.SI.Pressure p_sat;
  Real phi;
  Real sigma "Correction factor";
  //  Modelica.Units.SI.Temperature DT;
  Modelica.Blocks.Interfaces.RealInput T annotation(
    Placement(transformation(origin = {-120, -60}, extent = {{-20, -20}, {20, 20}}), iconTransformation(origin = {-120, 40}, extent = {{-20, -20}, {20, 20}})));
  Real K_l;
  Real K_t;
  Real K_exp;
  Modelica.Blocks.Math.Feedback feedbackT annotation(
    Placement(transformation(origin = {-40, -60}, extent = {{-10, -10}, {10, 10}})));
  Utilities.Poly2D poly2D_K_l(c = M_K_l)  annotation(
    Placement(transformation(origin = {0, 50}, extent = {{-10, -10}, {10, 10}})));
  parameter Medium.ThermodynamicState state_dp_small = Medium.setState_pTX(Medium.reference_p, Medium.reference_T, Medium.reference_X) "Medium state to compute dp_small";
  parameter Medium.AbsolutePressure dp_small(min = 0) = 1e-10 "Default small pressure drop for regularization of laminar and zero flow (calculated from m_flow_small)";
  Medium.Density d_a "Density at port_a when fluid is flowing from port_a to port_b";
  Medium.Density d_b "If allowFlowReversal=true then density at port_b when fluid is flowing from port_b to port_a else d_a";
  Modelica.Blocks.Sources.RealExpression realToCelsius(y = 273.15) annotation(
    Placement(transformation(origin = {-90, -84}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Math.Feedback feedbackDT annotation(
    Placement(transformation(origin = {-40, 60}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Interfaces.RealInput DT annotation(
    Placement(transformation(origin = {-120, 60}, extent = {{-20, -20}, {20, 20}}), iconTransformation(origin = {-120, 88}, extent = {{-20, -20}, {20, 20}})));
  VirtualFCS.Utilities.Poly2D poly2D_K_t(c = M_K_t)  annotation(
    Placement(transformation(extent = {{-10, -10}, {10, 10}})));
  VirtualFCS.Utilities.Poly2D poly2D_K_exp(c = M_K_exp)  annotation(
    Placement(transformation(origin = {0, -50}, extent = {{-10, -10}, {10, 10}})));

  Modelica.Blocks.Nonlinear.Limiter limiter_K_l(uMax = K_l_max, uMin = K_l_min)  annotation(
    Placement(transformation(origin = {40, 50}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Nonlinear.VariableLimiter DTLimiter annotation(
    Placement(transformation(origin = {-70, 60}, extent = {{-10, 10}, {10, -10}}, rotation = -0)));
  Modelica.Blocks.Sources.RealExpression realLowerDT annotation(
    Placement(transformation(origin = {-95, 85}, extent = {{-5, -9}, {5, 9}})));
  Modelica.Blocks.Nonlinear.Limiter limiter_K_t(uMax = K_t_max, uMin = K_t_min) annotation(
    Placement(transformation(origin = {40, 0}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Nonlinear.Limiter limiter_K_exp(uMax = K_exp_max, uMin = K_exp_min) annotation(
    Placement(transformation(origin = {40, -50}, extent = {{-10, -10}, {10, 10}})));
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
  
  phi = Medium.relativeHumidity(state_a);
  p_sat = Medium.saturationPressureLiquid(T);
  p_steam = phi*p_sat;
  
  K_l = limiter_K_l.y*1e5/1e3;
  K_t = limiter_K_t.y*1e5/1e6;
  K_exp = limiter_K_exp.y;
  sigma = T_ref * port_a.p / (T * Medium.reference_p);
  dp * sigma = min((K_l*m_flow + K_t*Modelica.Fluid.Dissipation.Utilities.Functions.General.SmoothPower(
          m_flow,
          m_flow/100,
          K_exp)
          )*1e5,dp_max);
  
  connect(T, feedbackT.u1) annotation(
    Line(points = {{-120, -60}, {-48, -60}}, color = {0, 0, 127}));
  connect(feedbackDT.y, poly2D_K_l.u1) annotation(
    Line(points = {{-31, 60}, {-21, 60}, {-21, 56}, {-13, 56}}, color = {0, 0, 127}));
  connect(feedbackDT.y, poly2D_K_t.u1) annotation(
    Line(points = {{-31, 60}, {-21, 60}, {-21, 6}, {-13, 6}}, color = {0, 0, 127}));
  connect(feedbackDT.y, poly2D_K_exp.u1) annotation(
    Line(points = {{-31, 60}, {-21, 60}, {-21, -44}, {-13, -44}}, color = {0, 0, 127}));
  connect(feedbackT.y, poly2D_K_l.u2) annotation(
    Line(points = {{-31, -60}, {-25, -60}, {-25, 44}, {-13, 44}}, color = {0, 0, 127}));
  connect(feedbackT.y, poly2D_K_t.u2) annotation(
    Line(points = {{-31, -60}, {-25, -60}, {-25, -6}, {-13, -6}}, color = {0, 0, 127}));
  connect(feedbackT.y, poly2D_K_exp.u2) annotation(
    Line(points = {{-31, -60}, {-25, -60}, {-25, -56}, {-13, -56}}, color = {0, 0, 127}));
  connect(poly2D_K_l.y, limiter_K_l.u) annotation(
    Line(points = {{11, 50}, {27, 50}}, color = {0, 0, 127}));
  connect(poly2D_K_t.y, limiter_K_t.u) annotation(
    Line(points = {{11, 0}, {27, 0}}, color = {0, 0, 127}));
  connect(poly2D_K_exp.y, limiter_K_exp.u) annotation(
    Line(points = {{11, -50}, {27, -50}}, color = {0, 0, 127}));
  connect(realToCelsius.y, feedbackT.u2) annotation(
    Line(points = {{-78, -84}, {-40, -84}, {-40, -68}}, color = {0, 0, 127}));
  connect(realToCelsius.y, feedbackDT.u2) annotation(
    Line(points = {{-78, -84}, {-40, -84}, {-40, 52}}, color = {0, 0, 127}));
  connect(T, DTLimiter.limit1) annotation(
    Line(points = {{-120, -60}, {-82, -60}, {-82, 52}}, color = {0, 0, 127}));
  connect(DT, DTLimiter.u) annotation(
    Line(points = {{-120, 60}, {-82, 60}}, color = {0, 0, 127}));
  connect(DTLimiter.y, feedbackDT.u1) annotation(
    Line(points = {{-58, 60}, {-48, 60}}, color = {0, 0, 127}));
  connect(realLowerDT.y, DTLimiter.limit2) annotation(
    Line(points = {{-89.5, 85}, {-82, 85}, {-82, 68}}, color = {0, 0, 127}));
  annotation(
    Documentation(info = "<html><head></head><body>
<p>Pressure loss of a moist-gas channel (used for the stack cathode) as a function of mass flow, gas temperature
and dew-point temperature:</p>
<pre>dp*sigma = min((K_l*m_flow + K_t*m_flow^K_exp)*1e5, dp_max),   sigma = T_ref*p_a/(T*p_ref)</pre>
<p>with <code>T_ref</code>, <code>p_ref</code> the medium reference state and <code>p_a</code> the inlet pressure. The
power term is regularised with <code>SmoothPower</code>. The coefficients are 2-D polynomials
(<a href=\"modelica://VirtualFCS.Utilities.Poly2D\">Poly2D</a>) with coefficient matrices <code>M_K_l</code>, <code>M_K_t</code>
and <code>M_K_exp</code>. Their first input is the dew-point temperature <code>DT</code> (limited to [0 K, T]) and their
second input is the temperature <code>T</code>, both converted to &deg;C. The polynomial outputs are limited to
[<code>K_l_min</code>, <code>K_l_max</code>], [<code>K_t_min</code>, <code>K_t_max</code>] and
[<code>K_exp_min</code>, <code>K_exp_max</code>]. The limited values of K_l and K_t are scaled by 1e5/1e3 and 1e5/1e6.</p>

<h4>Units (derived from the implementation)</h4>
<p>With <code>m_flow</code> in kg/s and <code>dp</code> in Pa, the limited polynomial outputs have the following meaning:</p>
<pre>dp_lam  [dbar] = K_l,poly [dbar*s/g] * m_flow [g/s]        (1 dbar = 1e4 Pa)
dp_turb [dbar] = K_t,poly * (m_flow [kg/s])^K_exp
K_exp,poly [-]</pre>
<p>The turbulent coefficient has no fixed unit because <code>K_exp</code> varies. The bounds
<code>K_l_min</code> &hellip; <code>K_t_max</code> use the same units.</p>

<h4>Inputs</h4>
<table>
<tr><td><code>T</code></td><td>Gas temperature [K]</td></tr>
<tr><td><code>DT</code></td><td>Dew-point temperature [K]</td></tr>
</table>
<p>The flow is isenthalpic without storage. <code>Xw_in</code> is the water mass fraction of the fluid on the outflow
side of <code>port_a</code> (in <a href=\"modelica://VirtualFCS.Electrochemical.Hydrogen.FuelCellStack\">FuelCellStack</a>: the
cathode junction volume). <code>phi</code>, <code>p_sat</code> and <code>p_steam</code> are diagnostic variables only.
To be completed: data on which the coefficient fit is based.</p>
</body></html>"));
end FlowResistanceHumPoly;
