within VirtualFCS.Fluid;

model PortHtxHandler
outer Modelica.Fluid.System system "System properties";
 // Medium.ThermodynamicState state_b "State for medium inflowing through port_b";
  extends Modelica.Fluid.Interfaces.PartialTwoPort;
replaceable package Medium = Modelica.Media.Interfaces.PartialMedium "Medium model" annotation (choicesAllMatching=true);
  Modelica.Units.SI.HeatFlowRate Q_a, Q_b;
  Modelica.Units.SI.HeatFlowRate Q_trans "Heat flow rate to or from ports";
  Modelica.Units.SI.Temperature T_b "Temperature at port_b";
  Medium.SpecificEnthalpy h_a;
  Modelica.Units.SI.Pressure dp;
  Modelica.Units.SI.MassFlowRate dmWat_flow "Added water flow rate";
  Modelica.Units.SI.MassFlowRate mAir_flow_a "Air flow rate port_a";
  Modelica.Units.SI.MassFlowRate mAir_flow_b "Air flow rate port_b";
  Modelica.Units.SI.MassFlowRate mWat_flow_a "Water flow rate port_a";
  Modelica.Units.SI.MassFlowRate mWat_flow_b "Water flow rate port_b";
  Medium.MassFraction X_CV_b[Medium.nX];
  Medium.MassFraction X_w_b "Outlet water mass fraction";
  Medium.MassFraction X_w_raw "Unbounded outlet water mass fraction";
  Modelica.Units.SI.MassFlowRate mDen "Regularized denominator for outlet composition";
protected
  Medium.ThermodynamicState state_a "State for medium inflowing through port_a";
  constant Real X_eps = 1e-8 "Numerical margin for bounded mass fractions";
equation
// medium states
  state_a = Medium.setState_phX(port_a.p, inStream(port_a.h_outflow), inStream(port_a.Xi_outflow));
//  state_b = Medium.setState_phX(port_b.p, inStream(port_b.h_outflow), inStream(port_b.Xi_outflow));
  h_a = Medium.specificEnthalpy(state_a);
  Q_a = h_a*port_a.m_flow;
  Q_b = port_b.h_outflow*port_b.m_flow;
  Q_a + Q_b + Q_trans = 0.0;  
// Pressure drop in design flow direction
  port_a.p - port_b.p = dp;
  port_a.h_outflow = inStream(port_b.h_outflow);
  port_b.h_outflow = Medium.specificEnthalpy_pTX(port_b.p, T_b, port_b.Xi_outflow);
  port_a.m_flow + port_b.m_flow + dmWat_flow = 0;
// Mass fractions
  mAir_flow_a = port_a.m_flow*(1 - inStream(port_a.Xi_outflow[1]));
  mAir_flow_b = port_b.m_flow*(1 - port_b.Xi_outflow[1]);
  mWat_flow_a = port_a.m_flow*inStream(port_a.Xi_outflow[1]);
  mWat_flow_b = port_b.m_flow*port_b.Xi_outflow[1];
  mDen = smooth(1, sqrt((port_a.m_flow + dmWat_flow)^2 + system.m_flow_small^2));
  X_w_raw = (mWat_flow_a + dmWat_flow)/mDen;
  X_w_b = noEvent(min(1 - X_eps, max(X_eps, X_w_raw)));
  X_CV_b = {X_w_b, 1 - X_w_b};
  port_a.Xi_outflow = inStream(port_b.Xi_outflow);
  port_b.Xi_outflow = X_CV_b[1:Medium.nXi];
//port_b.Xi_outflow = inStream(port_a.Xi_outflow);
  port_a.C_outflow = inStream(port_b.C_outflow);
  port_b.C_outflow = inStream(port_a.C_outflow);
  annotation(
    Documentation(info = "<html><head></head><body>
<p>Auxiliary two-port used by <a href=\"modelica://VirtualFCS.Fluid.FcHumidityExchanger\">FcHumidityExchanger</a>.
The enclosing model sets the pressure drop <code>dp</code> [Pa], the outlet temperature <code>T_b</code> [K] and the added
water mass flow <code>dmWat_flow</code> [kg/s] (negative values remove water). The heat flow <code>Q_trans</code> [W]
needed to close the steady-state energy balance results from these. There is no storage.</p>
<p>The medium must have exactly two substances with water as the first one (e.g. <code>Modelica.Media.Air.MoistAir</code>).</p>
</body></html>"));
end PortHtxHandler;
