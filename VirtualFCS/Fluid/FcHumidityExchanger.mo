within VirtualFCS.Fluid;

model FcHumidityExchanger
  outer Modelica.Fluid.System system "System properties";
  import VirtualFCS.Utilities.Types.opModeHTX;
  replaceable package Medium = Modelica.Media.Interfaces.PartialMedium "Medium model" annotation(
    choicesAllMatching = true);
  Modelica.Units.SI.ThermalConductance C1_flow "Heat capacity flow rate into dehumidifier";
  Modelica.Units.SI.ThermalConductance C2_flow "Heat capacity flow rate into humidifier";
  Modelica.Units.SI.ThermalConductance C_flow_min;
  Modelica.Units.SI.HeatFlowRate Q_flow_max, Q_sens;
  //Modelica.Units.SI.HeatFlowRate Q_VapT0 "Evaporation heat flow water at standard conditions";
  //Medium.MassFraction X_CV_DehumOut[Medium.nX];
  //Medium.MassFraction X_CV_HumOut[Medium.nX];
  Modelica.Units.SI.Temperature T_a1, T_a2, T_b1, T_b2;
  Utilities.Volume_standard_litre_flow_rate Vdot_hum_in "Standard volume flow dry air humidifier in";
  Utilities.Volume_standard_litre_flow_rate Vdot_dehum_in "Standard volume flow dry air dehumidifier in";
  Modelica.Units.SI.MassFlowRate mWat_flow_wet_in "Water flow rate dehumidifier in (wet side)";
  Real dmWat_flow_eff,dmWat_flow_eff_lin;
  //, dpa, dpb;
  Medium.MassFraction Xi_hum_in "Regularized inlet water mass fraction humidifier side";
  Medium.MassFraction Xi_dehum_in "Regularized inlet water mass fraction dehumidifier side";
  Modelica.Units.SI.MassFlowRate mFlowHumEff "Regularized inlet mass flow humidifier side";
  Modelica.Units.SI.MassFlowRate mFlowDehumEff "Regularized inlet mass flow dehumidifier side";
  parameter Modelica.Units.SI.Pressure dp0Dry = 7700 "Nominal pressure difference dry side";
  parameter Modelica.Units.SI.Pressure dp0Wet = 7500 "Nominal pressure difference wet side";
  parameter Utilities.Volume_standard_litre_flow_rate VN0Dry = 5000 "Nominal volume flow rate dry side";
  parameter Utilities.Volume_standard_litre_flow_rate VN0Wet = 5000 "Nominal volume flow rate wet side";
  parameter Real epsS(min = 0.0, max = 1.0) = 0.72 "Effectiveness of sensible heat exchange";
  parameter opModeHTX opModeEffL = opModeHTX.fumatech_H100N "Water transfer correlation (fumatech_H50N, fumatech_H100N, fumatech_H100N_meas, User_Parameter)" annotation(
    Placement(visible = false, transformation(extent = {{0, 0}, {0, 0}})));
  parameter Real effL = 0.35 annotation(
    Dialog(enable = if (opModeEffL == opModeHTX.User_Parameter) then true else false));
  //Ports
  Modelica.Fluid.Interfaces.FluidPort_a port_a1(redeclare package Medium = Medium) annotation(
    Placement(transformation(origin = {-100, 56}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {-100, 0}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b1(redeclare package Medium = Medium) annotation(
    Placement(transformation(origin = {100, 56}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {100, 0}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_a2(redeclare package Medium = Medium) annotation(
    Placement(transformation(origin = {-100, -56}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {0, 100}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b2(redeclare package Medium = Medium) annotation(
    Placement(transformation(origin = {100, -56}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {0, -100}, extent = {{-10, -10}, {10, 10}})));
  //  PartialTwoPort models
  //Protected variables
  VirtualFCS.Fluid.PortHtxHandler portHtxHum(redeclare package Medium = Medium) annotation(
    Placement(transformation(origin = {0, -56}, extent = {{-28, -28}, {28, 28}})));
  VirtualFCS.Fluid.PortHtxHandler portHtxDehum(redeclare package Medium = Medium) annotation(
    Placement(transformation(origin = {0, 56}, extent = {{-28, 28}, {28, -28}}, rotation = -0)));
  Medium.ThermodynamicState state_a1 "State for medium inflowing through port_a1";
  Medium.ThermodynamicState state_a2 "State for medium inflowing through port_a2";
  constant Modelica.Units.SI.Density rho_STD = 1.293 "Density of dry air at 0°C and 1.0135bar";
  Modelica.Blocks.Continuous.FirstOrder firstOrderEff(T = 1, y_start = 1) annotation(
    Placement(transformation(origin = {-48, 0}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.RealExpression VdotHumIn(y = abs(Vdot_hum_in)) annotation(
    Placement(transformation(origin = {-100, 0}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Math.Gain VfToSI(k = 1/60000) annotation(
    Placement(transformation(origin = {-10, 0}, extent = {{-10, -10}, {10, 10}})));
equation
//Volume flow (standard conditions)
  Xi_hum_in = Modelica.Fluid.Utilities.regStep(port_a2.m_flow, inStream(port_a2.Xi_outflow[1]), port_a2.Xi_outflow[1], system.m_flow_small);
  Xi_dehum_in = Modelica.Fluid.Utilities.regStep(port_a1.m_flow, inStream(port_a1.Xi_outflow[1]), port_a1.Xi_outflow[1], system.m_flow_small);
  mFlowHumEff = smooth(1, sqrt(port_a2.m_flow^2 + system.m_flow_small^2));
  mFlowDehumEff = smooth(1, sqrt(port_a1.m_flow^2 + system.m_flow_small^2));
  Vdot_hum_in = mFlowHumEff*(1 - Xi_hum_in)/rho_STD*1000*60;
  Vdot_dehum_in = mFlowDehumEff*(1 - Xi_dehum_in)/rho_STD*1000*60;
//Mass and species balances
  if opModeEffL == opModeHTX.fumatech_H50N then
    dmWat_flow_eff = max(min(13.4642*VfToSI.y + 0.0790748*T_a2 + 18.3018*VfToSI.y^2 - 0.0551814*VfToSI.y*T_a2 - 0.000116856*T_a2^2 - 12.75, 0.6), 0.3);
    dmWat_flow_eff_lin = min(3.374e-9*firstOrderEff.y^2-7.414e-5*firstOrderEff.y+0.621,0.55);
  elseif opModeEffL == opModeHTX.fumatech_H100N then
    dmWat_flow_eff = min((11.203389*firstOrderEff.y^(-0.3861)), 0.5);
  elseif opModeEffL == opModeHTX.fumatech_H100N_meas then
    dmWat_flow_eff = min(-1.320E-05*firstOrderEff.y + 4.329E-1, 0.41);
  else
    dmWat_flow_eff = effL;
  end if;
  mWat_flow_wet_in = mFlowDehumEff*Xi_dehum_in;
//portHtxHum.mWat_flow_b = -dmWat_flow_eff*mWat_flow_wet_in;//Why? Isn't this wrong? How can this match the Fumatech data?
  portHtxHum.dmWat_flow = dmWat_flow_eff*mWat_flow_wet_in;
  portHtxDehum.dmWat_flow + portHtxHum.dmWat_flow = 0.0;
  assert(portHtxHum.dmWat_flow > 0, "Irregular water flow.");
//Pressure drop
//dpa = smooth(1, if time < 0.1 then 1000 else dp0Dry*(Vdot_hum_in/VN0Dry)^2);
//dpa = Modelica.Fluid.Utilities.regStep((time-0.2), dp0Dry*(Vdot_hum_in/VN0Dry)^2, 0, 0.2);
//dpb = smooth(1, if time < 0.1 then 1000 else dp0Wet*(Vdot_dehum_in/VN0Wet)^2);
  portHtxHum.dp = dp0Dry*(Vdot_hum_in/VN0Dry)^2;
  portHtxDehum.dp = dp0Wet*(Vdot_dehum_in/VN0Wet)^2;
//portHtxHum.dp = 0.01;
//portHtxDehum.dp = 0.01;
//Energybalance and temperature calculations
//  portHtxDehum.Q_trans + portHtxHum.Q_trans = errQ;
  state_a1 = Medium.setState_phX(port_a1.p, inStream(port_a1.h_outflow), inStream(port_a1.Xi_outflow));
  state_a2 = Medium.setState_phX(port_a2.p, inStream(port_a2.h_outflow), inStream(port_a2.Xi_outflow));
  C1_flow = max(port_a1.m_flow*Medium.specificHeatCapacityCp(state_a1), 1.0e-6);
  C2_flow = max(port_a2.m_flow*Medium.specificHeatCapacityCp(state_a2), 1.0e-6);
  C_flow_min = min(C1_flow, C2_flow);
  Q_flow_max = C_flow_min*(T_a2 - T_a1);
  Q_sens = epsS*Q_flow_max;
  T_a1 = Medium.temperature(state_a1);
  T_a2 = Medium.temperature(state_a2);
  T_b1 = (Q_sens/C_flow_min + T_a1);
//  T_b2 = (T_a2 - Q_sens/C_flow_min);
  T_b2 = (T_a2);
  portHtxHum.T_b = T_b2;
  portHtxDehum.T_b = T_b1;
//Connectors
  connect(port_a1, portHtxDehum.port_a) annotation(
    Line(points = {{-100, 56}, {-28, 56}}));
  connect(portHtxDehum.port_b, port_b1) annotation(
    Line(points = {{28, 56}, {100, 56}}, color = {0, 127, 255}));
  connect(port_a2, portHtxHum.port_a) annotation(
    Line(points = {{-100, -56}, {-28, -56}}));
  connect(portHtxHum.port_b, port_b2) annotation(
    Line(points = {{28, -56}, {100, -56}}, color = {0, 127, 255}));
  connect(VdotHumIn.y, firstOrderEff.u) annotation(
    Line(points = {{-88, 0}, {-60, 0}}, color = {0, 0, 127}));
  connect(firstOrderEff.y, VfToSI.u) annotation(
    Line(points = {{-36, 0}, {-22, 0}}, color = {0, 0, 127}));
  annotation(
    Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}), graphics = {Ellipse(extent = {{-50, -50}, {50, 50}}), Line(origin = {0, 70}, points = {{0, 20}, {0, -20}}, color = {255, 0, 0}, thickness = 5), Line(origin = {0, -70}, points = {{0, 20}, {0, -20}}, color = {170, 0, 255}, thickness = 5), Line(origin = {-70, 0}, rotation = -90, points = {{0, 20}, {0, -20}}, color = {255, 0, 255}, thickness = 5), Line(origin = {70, 0}, rotation = -90, points = {{0, 20}, {0, -20}}, color = {142, 0, 230}, thickness = 5), Polygon(origin = {0, 47}, fillColor = {255, 0, 0}, pattern = LinePattern.None, fillPattern = FillPattern.Solid, points = {{-20, -7}, {0, 5}, {22, -7}, {-20, -7}}), Polygon(origin = {0, -45}, rotation = 180, fillColor = {170, 0, 255}, pattern = LinePattern.None, fillPattern = FillPattern.Solid, points = {{-22, -5}, {0, 7}, {22, -5}, {-22, -5}}), Rectangle(fillColor = {170, 170, 255}, fillPattern = FillPattern.Vertical, extent = {{-30, 40}, {30, -40}}, radius = 4)}),
    graphics = {Text(extent = {{-69, 7}, {71, -24}}, textString = "%C")},
    Documentation(info = "<html><head></head><body>
<p>Static model of a membrane humidifier with two moist-air streams: side 1 (<code>port_a1</code> &rarr;
<code>port_b1</code>, wet or dehumidifier side, typically the cathode exhaust) and side 2 (<code>port_a2</code> &rarr;
<code>port_b2</code>, dry or humidifier side, typically the compressed air to the stack). There is no mass or energy storage.</p>

<h4>Water transfer</h4>
<p>The water mass flow moved from side 1 to side 2 is <code>dmWat_flow_eff*mWat_flow_wet_in</code>, where
<code>mWat_flow_wet_in</code> [kg/s] is the water inflow on side 1. The transfer effectiveness
<code>dmWat_flow_eff</code> [-] depends on <code>opModeEffL</code>:</p>
<ul>
<li><code>fumatech_H50N</code>: polynomial in the filtered dry-side standard volume flow [m3/s] and the dry-side inlet temperature <code>T_a2</code> [K], limited to 0.3&hellip;0.6.</li>
<li><code>fumatech_H100N</code>: <code>min(11.203389*V^(-0.3861), 0.5)</code> with V the filtered dry-side standard volume flow [Nl/min] (fit to data-sheet values).</li>
<li><code>fumatech_H100N_meas</code>: <code>min(-1.320e-5*V + 0.4329, 0.41)</code> (fit to measurements).</li>
<li><code>User_Parameter</code>: constant <code>effL</code>.</li>
</ul>
<p>The dry-side volume flow is filtered by a first-order lag with T = 1 s. Standard volume flows refer to dry air at
0 &deg;C and 1.01325 bar (density 1.293 kg/m3). An assertion stops the simulation if the transferred water flow is not
positive.</p>

<h4>Pressure drop</h4>
<pre>dp_dry = dp0Dry*(Vdot_hum_in/VN0Dry)^2      dp_wet = dp0Wet*(Vdot_dehum_in/VN0Wet)^2</pre>
<p>with the standard volume flows in Nl/min and the nominal pressure drops in Pa.</p>

<h4>Heat transfer</h4>
<p>The sensible heat <code>Q_sens = epsS*C_min*(T_a2 - T_a1)</code> [W] is added to side 1 (<code>T_b1 = T_a1 + Q_sens/C_min</code>),
with <code>C_min</code> the smaller heat capacity flow rate of the two inflows [W/K].
The side-2 outlet temperature equals its inlet temperature (<code>T_b2 = T_a2</code>).
The latent heat of the transferred water is not considered.</p>

<h4>Limitations</h4>
<ul>
<li>The medium must have exactly two substances with water as the first one (e.g. <code>Modelica.Media.Air.MoistAir</code>).</li>
<li>Design flow direction a &rarr; b on both sides.</li>
<li>To be completed: validity range of the Fumatech correlations (flow and temperature range of the underlying data).</li>
</ul>
</body></html>", revisions = "<html>
<ul>
</ul>
</html>"),
    Diagram(graphics));
end FcHumidityExchanger;
