within VirtualFCS.Fluid;

model FcWaterSource
outer Modelica.Fluid.System system "System properties";
import VirtualFCS.Utilities.Types.opModeFC;
extends Modelica.Fluid.Interfaces.PartialTwoPort;
replaceable package Medium = Modelica.Media.Interfaces.PartialMedium "Medium model" annotation (choicesAllMatching=true);
  Modelica.Units.SI.HeatFlowRate Q_a, Q_b;
  Modelica.Units.SI.HeatFlowRate Q_VapT0 "Evaporation heat flow water at standard conditions";
  Modelica.Units.SI.Temperature T_b(start=system.T_ambient, fixed=true) "Temperature at port_b";
  Modelica.Units.SI.MassFlowRate mAir_flow_a "Air flow rate port_a";
  Modelica.Units.SI.MassFlowRate mAir_flow_b "Air flow rate port_b";
  Modelica.Units.SI.MassFlowRate mWat_flow_a "Water flow rate port_a";
  Modelica.Units.SI.MassFlowRate mWat_flow_b "Water flow rate port_b";
  Modelica.Units.SI.MassFlowRate mWatSource_flow "Water flow rate source";
  Medium.MassFraction X_w_SourceOut "Outlet water mass fraction of source";
  Medium.MassFraction X_w_raw "Unbounded outlet water mass fraction";
  Modelica.Units.SI.MassFlowRate mDen "Regularized denominator for outlet composition";
  Modelica.Units.SI.Temperature T_a(start=system.T_ambient, fixed=true);
  Medium.SpecificEnthalpy h_a;
  Medium.MassFraction X_CV[Medium.nX];
parameter opModeFC opModeEbal=opModeFC.LHV "Base for calculation of energy balance (1: LHV, 2: HHV)" annotation(
    Placement(visible = true, transformation(extent = {{0, 0}, {0, 0}})));
parameter Modelica.Units.SI.Pressure dp=1000 "Pressure drop water source";
parameter Modelica.Units.SI.TemperatureDifference dT_out=1 "Temperature difference thermal mass to outflow water source";
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heatport_a annotation(
    Placement(transformation(origin = {2, 100}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {0, 101}, extent = {{-10, -10}, {10, 10}})));Modelica.Blocks.Interfaces.RealInput mFlowWat_FC annotation(
    Placement(transformation(origin = {-98, -82}, extent = {{-20, -20}, {20, 20}}), iconTransformation(origin = {-98, -82}, extent = {{-20, -20}, {20, 20}})));
protected
  Medium.ThermodynamicState state_a "State for medium inflowing through port_a";
  parameter Medium.SpecificEnthalpy hVapT0 = Modelica.Media.Air.MoistAir.enthalpyOfVaporization(T = T_norm);
  parameter Modelica.Units.SI.Temperature T_norm=298.15 "Reference temperature enthalpy of formation";
  constant Real X_eps = 1e-8 "Numerical margin for bounded mass fractions";
equation
//medium states
  state_a = Medium.setState_phX(port_a.p, inStream(port_a.h_outflow), inStream(port_a.Xi_outflow));
//Energybalance and temperature calculations
  h_a = Medium.specificEnthalpy(state_a);
  Q_VapT0 = hVapT0*mWatSource_flow;
  Q_a = h_a*port_a.m_flow;
  Q_b = port_b.h_outflow*port_b.m_flow;
  if opModeEbal == opModeFC.LHV then
    Q_a + Q_b + heatport_a.Q_flow + Q_VapT0 = 0.0;
  else
    Q_a + Q_b + heatport_a.Q_flow = 0.0;
  end if;
  T_a = Medium.temperature(state_a);
  if sign(heatport_a.Q_flow) < 0 then
    heatport_a.T - T_b = -dT_out;
  else
    heatport_a.T - T_b = dT_out;
  end if;
// Pressure drop in design flow direction  
  port_a.p - port_b.p = dp;
  port_a.h_outflow = inStream(port_b.h_outflow);
//  port_b.h_outflow = Medium.specificEnthalpy_pTX(port_b.p, T_b, port_b.Xi_outflow); // Mass and species balance (no storage)
  port_b.h_outflow = homotopy(
  actual  = Medium.specificEnthalpy_pTX(port_b.p, T_b, port_b.Xi_outflow),
  simplified = Medium.specificEnthalpy_pTX(1e5, T_b, {1}));  // fixed init
  mAir_flow_a = port_a.m_flow*(1-inStream(port_a.Xi_outflow[1]));
  mAir_flow_b = port_b.m_flow*(1-actualStream(port_b.Xi_outflow[1]));
  mWat_flow_a = port_a.m_flow*inStream(port_a.Xi_outflow[1]);
  mWat_flow_b = port_b.m_flow*actualStream(port_b.Xi_outflow[1]);
  mWatSource_flow = mFlowWat_FC;
  mDen = smooth(1, sqrt((port_a.m_flow + mWatSource_flow)^2 + system.m_flow_small^2));
  X_w_raw = (mWat_flow_a + mWatSource_flow) / mDen;
  X_w_SourceOut = noEvent(min(1 - X_eps, max(X_eps, X_w_raw)));
  X_CV = {X_w_SourceOut, 1 - X_w_SourceOut}; 
  port_a.m_flow + port_b.m_flow + mWatSource_flow = 0;
// Transport of substances
  port_a.Xi_outflow = inStream(port_b.Xi_outflow);
//port_b.Xi_outflow = inStream(port_a.Xi_outflow);
  port_b.Xi_outflow = X_CV[1:Medium.nXi];
  port_a.C_outflow = inStream(port_b.C_outflow);
  port_b.C_outflow = inStream(port_a.C_outflow);
annotation(
    Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}), graphics = {Polygon(origin = {0, 10},lineColor = {255, 170, 255}, fillColor = {0, 255, 255}, fillPattern = FillPattern.VerticalCylinder, points = {{-80, 80}, {80, 80}, {80, 20}, {0, -80}, {-80, 20}, {-80, 80}}), Ellipse(origin = {-57, 67}, lineColor = {0, 255, 255}, fillColor = {0, 0, 255}, fillPattern = FillPattern.Sphere, extent = {{-7, 13}, {7, -13}}), Ellipse(origin = {-35, 45}, lineColor = {0, 255, 255}, fillColor = {0, 0, 255}, fillPattern = FillPattern.Sphere, extent = {{-7, 13}, {7, -13}}), Ellipse(origin = {-15, 19}, lineColor = {0, 255, 255}, fillColor = {0, 0, 255}, fillPattern = FillPattern.Sphere, extent = {{-7, 13}, {7, -13}}), Ellipse(origin = {-1, -12}, lineColor = {0, 255, 255}, fillColor = {0, 0, 255}, fillPattern = FillPattern.Sphere, extent = {{-7, 8}, {7, -8}}), Ellipse(origin = {1, -38}, lineColor = {0, 255, 255}, fillColor = {0, 0, 255}, fillPattern = FillPattern.Sphere, extent = {{-7, 8}, {7, -8}})}),
    graphics = {Text(extent = {{-69, 7}, {71, -24}}, textString = "%C")},
        Documentation(info = "<html><head></head><body>
<p>Two-port that adds the water mass flow <code>mFlowWat_FC</code> [kg/s] (input) to a moist-air stream, e.g. the
product water of a fuel cell stack. The heat port <code>heatport_a</code> connects to the stack thermal mass.</p>
<ul>
<li>Mass balance: <code>port_a.m_flow + port_b.m_flow + mFlowWat_FC = 0</code>. The outlet water mass fraction follows from the inflowing water plus the added water (bounded to [1e-8, 1 - 1e-8]).</li>
<li>Outlet temperature: <code>T_b = heatport_a.T + dT_out</code> if heat flows from the component into the heat port (<code>heatport_a.Q_flow &lt; 0</code>), otherwise <code>T_b = heatport_a.T - dT_out</code> [K].</li>
<li>Energy balance: the heat port supplies the enthalpy difference between outlet and inlet. With <code>opModeEbal = LHV</code>, the term <code>Q_VapT0 = h_vap(298.15 K)*mFlowWat_FC</code> is included in the balance, so the vaporisation enthalpy of the added water is not drawn from the heat port (consistent with a stack heat source based on the lower heating value). With <code>HHV</code>, this term is omitted.</li>
<li>Fixed pressure drop <code>dp</code> [Pa] in the design flow direction.</li>
</ul>
<p>The medium must have exactly two substances with water as the first one (e.g. <code>Modelica.Media.Air.MoistAir</code>).</p>
</body></html>", revisions = "<html>
<ul>
</ul>
</html>"),
    Diagram(graphics));
end FcWaterSource;
