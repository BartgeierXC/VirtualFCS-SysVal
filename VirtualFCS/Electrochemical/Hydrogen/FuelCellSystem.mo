within VirtualFCS.Electrochemical.Hydrogen;

model FuelCellSystem
  // System
  outer Modelica.Fluid.System system "System properties";
  replaceable package Cathode_Medium = Modelica.Media.Air.MoistAir;
  replaceable package Anode_Medium = Modelica.Media.IdealGases.SingleGases.H2 constrainedby Modelica.Media.Interfaces.PartialSimpleIdealGasMedium;
  // Power and efficiency calculations
  Modelica.Units.SI.Power Power_system "Power delivered from the FC system (Stack - BOP)";
  Modelica.Units.SI.Power Power_stack "Power delivered from the FC stack";
  Modelica.Units.SI.Energy Energy_stack "Total energy converted by the FC stack";
  Modelica.Units.SI.Power Power_BoP "Power consumed by the BOP components";
  Modelica.Units.SI.Efficiency eta_FC_sys "Fuel cell system efficiency";
  //*** PLAUSIBILITY RANGE LIMITS ***//
  parameter Modelica.Units.SI.Temperature T_Ca_min(displayUnit = "degC") = 263.15 "Min plausible cathode (air) stream temperature";
  parameter Modelica.Units.SI.Temperature T_Ca_max(displayUnit = "degC") = 373.15 "Max plausible cathode (air) stream temperature";
  parameter Modelica.Units.SI.Temperature T_cool_min(displayUnit = "degC") = 273.15 "Min plausible coolant (water) temperature";
  parameter Modelica.Units.SI.Temperature T_cool_max(displayUnit = "degC") = 373.15 "Max plausible coolant (water) temperature";
  parameter Modelica.Units.SI.Temperature T_stack_min(displayUnit = "degC") = 263.15 "Min plausible stack temperature";
  parameter Modelica.Units.SI.Temperature T_stack_max(displayUnit = "degC") = 373.15 "Max plausible stack temperature";
  parameter Modelica.Units.SI.Pressure p_Ca_min(displayUnit = "bar") = 0.4e5 "Min plausible cathode (air) pressure";
  parameter Modelica.Units.SI.Pressure p_Ca_max(displayUnit = "bar") = 4.0e5 "Max plausible cathode (air) pressure";
  parameter Modelica.Units.SI.Pressure p_An_min(displayUnit = "bar") = 0.4e5 "Min plausible anode (H2) pressure";
  parameter Modelica.Units.SI.Pressure p_An_max(displayUnit = "bar") = 12.0e5 "Max plausible anode (H2) pressure";
  parameter Modelica.Units.SI.Pressure p_cool_min(displayUnit = "bar") = 0.2e5 "Min plausible coolant pressure";
  parameter Modelica.Units.SI.Pressure p_cool_max(displayUnit = "bar") = 6.0e5 "Max plausible coolant pressure";
  //*** INSTANTIATE COMPONENTS ***//
  VirtualFCS.Electrochemical.Hydrogen.FuelCellStack fuelCellStack(A_FC_surf = 0.0305, N_FC_stack = 275, j_0_ref = 2.721837e2, E_A = 4.417500e4, f_CL = 9.672601e-1, D_GDL_ref = 5.388195e-5, D_CL_ref = 4.970848e-6, r_el = 6.606254e-6, m_coolant = 4.31, m_FC_stack = 63.7, V_Ca = 5.12e-3) annotation(
    Placement(visible = true, transformation(origin = {-1, 6}, extent = {{-26, -26}, {26, 26}}, rotation = 0)));
  Modelica.Electrical.Analog.Interfaces.PositivePin pin_p annotation(
    Placement(visible = true, transformation(origin = {40, 96}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {50, 90}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Electrical.Analog.Interfaces.NegativePin pin_n annotation(
    Placement(visible = true, transformation(origin = {-40, 96}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {-50, 90}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  VirtualFCS.SubSystems.FuelCellSubSystems fuelCellSubSystems(redeclare VirtualFCS.SubSystems.Air.SubSystemAirCMP subSystemAir, redeclare VirtualFCS.SubSystems.Cooling.SubSystemCoolingTST subSystemCooling) annotation(
    Placement(visible = true, transformation(origin = {0, -60}, extent = {{-25, -25}, {25, 25}}, rotation = 0)));
  Modelica.Electrical.Analog.Sensors.CurrentSensor currentSensor annotation(
    Placement(transformation(origin = {-40, 60}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  VirtualFCS.Utilities.CalcPulsedMean calcMeanEta annotation(
    Placement(visible = false, transformation(extent = {{0, 0}, {0, 0}})));
  Modelica.Electrical.Analog.Interfaces.PositivePin pin_p_bat annotation(
    Placement(visible = true, transformation(origin = {96, 40}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {52, -88}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Electrical.Analog.Interfaces.NegativePin pin_n_bat annotation(
    Placement(visible = true, transformation(origin = {96, -20}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {-52, -90}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Electrical.Analog.Sensors.VoltageSensor voltageSensor annotation(
    Placement(visible = true, transformation(origin = {0, 50}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
equation
  calcMeanEta.u = eta_FC_sys;
  Power_stack = fuelCellStack.pin_n.i*fuelCellStack.pin_p.v;
  der(Energy_stack) = Power_stack;
  Power_BoP = fuelCellSubSystems.pin_n.i*fuelCellSubSystems.pin_p.v;
  Power_system = Power_stack + Power_BoP;
  eta_FC_sys = max((1 - min(abs(Power_BoP/(Power_stack + 1e-6)), 1))*fuelCellStack.eta_FC_LHV, 0);
//*** MEDIA PLAUSIBILITY ASSERTIONS ***//
// Cathode (air) temperatures
  assert(fuelCellStack.temperatureCathodeIn.T >= T_Ca_min and fuelCellStack.temperatureCathodeIn.T <= T_Ca_max, "Cathode air inlet temperature " + String(fuelCellStack.temperatureCathodeIn.T) + " K outside plausible range [" + String(T_Ca_min) + ", " + String(T_Ca_max) + "] K");
  assert(fuelCellStack.temperatureCathodeOut.T >= T_Ca_min and fuelCellStack.temperatureCathodeOut.T <= T_Ca_max, "Cathode air outlet temperature " + String(fuelCellStack.temperatureCathodeOut.T) + " K outside plausible range [" + String(T_Ca_min) + ", " + String(T_Ca_max) + "] K");
// Coolant (water) temperatures
  assert(fuelCellStack.temperatureCoolantIn.y >= T_cool_min and fuelCellStack.temperatureCoolantIn.y <= T_cool_max, "Coolant inlet temperature " + String(fuelCellStack.temperatureCoolantIn.y) + " K outside plausible range [" + String(T_cool_min) + ", " + String(T_cool_max) + "] K");
  assert(fuelCellStack.temperatureCoolantOut.y >= T_cool_min and fuelCellStack.temperatureCoolantOut.y <= T_cool_max, "Coolant outlet temperature " + String(fuelCellStack.temperatureCoolantOut.y) + " K outside plausible range [" + String(T_cool_min) + ", " + String(T_cool_max) + "] K");
// Stack temperature (the anode gas is not heated by the stack)
  assert(fuelCellStack.T_S >= T_stack_min and fuelCellStack.T_S <= T_stack_max, "Stack temperature " + String(fuelCellStack.T_S) + " K outside plausible range [" + String(T_stack_min) + ", " + String(T_stack_max) + "] K");
// Cathode (air) pressures
  assert(fuelCellStack.port_a_Air.p >= p_Ca_min and fuelCellStack.port_a_Air.p <= p_Ca_max, "Cathode air inlet pressure " + String(fuelCellStack.port_a_Air.p) + " Pa outside plausible range [" + String(p_Ca_min) + ", " + String(p_Ca_max) + "] Pa");
  assert(fuelCellStack.port_b_Air.p >= p_Ca_min and fuelCellStack.port_b_Air.p <= p_Ca_max, "Cathode air outlet pressure " + String(fuelCellStack.port_b_Air.p) + " Pa outside plausible range [" + String(p_Ca_min) + ", " + String(p_Ca_max) + "] Pa");
// Anode (H2) pressures
  assert(fuelCellStack.port_a_H2.p >= p_An_min and fuelCellStack.port_a_H2.p <= p_An_max, "Anode H2 inlet pressure " + String(fuelCellStack.port_a_H2.p) + " Pa outside plausible range [" + String(p_An_min) + ", " + String(p_An_max) + "] Pa");
  assert(fuelCellStack.port_b_H2.p >= p_An_min and fuelCellStack.port_b_H2.p <= p_An_max, "Anode H2 outlet pressure " + String(fuelCellStack.port_b_H2.p) + " Pa outside plausible range [" + String(p_An_min) + ", " + String(p_An_max) + "] Pa");
// Coolant pressures
  assert(fuelCellStack.port_a_Coolant.p >= p_cool_min and fuelCellStack.port_a_Coolant.p <= p_cool_max, "Coolant inlet pressure " + String(fuelCellStack.port_a_Coolant.p) + " Pa outside plausible range [" + String(p_cool_min) + ", " + String(p_cool_max) + "] Pa");
  assert(fuelCellStack.port_b_Coolant.p >= p_cool_min and fuelCellStack.port_b_Coolant.p <= p_cool_max, "Coolant outlet pressure " + String(fuelCellStack.port_b_Coolant.p) + " Pa outside plausible range [" + String(p_cool_min) + ", " + String(p_cool_max) + "] Pa");
  connect(fuelCellSubSystems.pin_p, pin_p_bat) annotation(
    Line(points = {{32.5, -52.5}, {60, -52.5}, {60, 40}, {96, 40}}, color = {0, 0, 255}));
  connect(fuelCellSubSystems.pin_n, pin_n_bat) annotation(
    Line(points = {{32.5, -67.5}, {80, -67.5}, {80, -20}, {96, -20}}, color = {0, 0, 255}));
  connect(fuelCellSubSystems.air_port_b, fuelCellStack.port_b_Air) annotation(
    Line(points = {{22, -38}, {40, -38}, {40, -6}, {18, -6}}, color = {0, 127, 255}));
  connect(fuelCellSubSystems.H2_port_b, fuelCellStack.port_b_H2) annotation(
    Line(points = {{-22, -38}, {-40, -38}, {-40, -6}, {-20, -6}}, color = {0, 127, 255}));
  connect(fuelCellSubSystems.H2_port_a, fuelCellStack.port_a_H2) annotation(
    Line(points = {{-18, -38}, {-18, -20}, {-30, -20}, {-30, 18}, {-20, 18}}, color = {0, 127, 255}));
  connect(fuelCellSubSystems.air_port_a, fuelCellStack.port_a_Air) annotation(
    Line(points = {{18, -38}, {16, -38}, {16, -20}, {30, -20}, {30, 18}, {18, 18}}, color = {0, 127, 255}));
  connect(fuelCellSubSystems.coolant_port_a, fuelCellStack.port_a_Coolant) annotation(
    Line(points = {{-2, -38}, {-4, -38}, {-4, -20}, {-6, -20}, {-6, -10}}, color = {255, 0, 0}));
  connect(fuelCellSubSystems.coolant_port_b, fuelCellStack.port_b_Coolant) annotation(
    Line(points = {{2, -38}, {2, -20}, {4, -20}, {4, -10}}, color = {255, 0, 0}));
  connect(fuelCellStack.pin_p, voltageSensor.p) annotation(
    Line(points = {{12, 26}, {14, 26}, {14, 50}, {10, 50}}, color = {0, 0, 255}));
  connect(fuelCellStack.pin_p, pin_p) annotation(
    Line(points = {{12, 26}, {14, 26}, {14, 50}, {40, 50}, {40, 96}}, color = {0, 0, 255}));
  connect(fuelCellStack.pin_n, voltageSensor.n) annotation(
    Line(points = {{-14, 26}, {-16, 26}, {-16, 50}, {-10, 50}}, color = {0, 0, 255}));
  connect(fuelCellStack.pin_n, currentSensor.n) annotation(
    Line(points = {{-14, 26}, {-16, 26}, {-16, 50}, {-40, 50}}, color = {0, 0, 255}));
  connect(currentSensor.p, pin_n) annotation(
    Line(points = {{-40, 70}, {-40, 96}}, color = {0, 0, 255}));
protected
  annotation(
    Icon(graphics = {Text(origin = {-6, -250}, textColor = {0, 0, 255}, extent = {{-150, 120}, {150, 150}}, textString = "%name"), Rectangle(fillColor = {0, 60, 101}, fillPattern = FillPattern.Solid, lineThickness = 1.5, extent = {{-100, 100}, {100, -100}}, radius = 35), Rectangle(origin = {-55, -1}, fillColor = {255, 255, 255}, pattern = LinePattern.None, fillPattern = FillPattern.Solid, extent = {{-9, 60.5}, {9, -61}}), Rectangle(origin = {58.5, -1}, fillColor = {255, 255, 255}, pattern = LinePattern.None, fillPattern = FillPattern.Solid, extent = {{-9, 60.5}, {9, -61}}), Rectangle(origin = {-40, -1}, fillColor = {255, 255, 255}, pattern = LinePattern.None, fillPattern = FillPattern.Solid, extent = {{-3, 46.9}, {4.2, -47}}), Rectangle(origin = {-29.8, -1}, fillColor = {255, 255, 255}, pattern = LinePattern.None, fillPattern = FillPattern.Solid, extent = {{-3, 46.9}, {4.2, -47}}), Rectangle(origin = {-19.1, -1}, fillColor = {255, 255, 255}, pattern = LinePattern.None, fillPattern = FillPattern.Solid, extent = {{-3, 46.9}, {4.2, -47}}), Rectangle(origin = {-8.7, -1}, fillColor = {255, 255, 255}, pattern = LinePattern.None, fillPattern = FillPattern.Solid, extent = {{-3, 46.9}, {4.2, -47}}), Rectangle(origin = {1.5, -1}, fillColor = {255, 255, 255}, pattern = LinePattern.None, fillPattern = FillPattern.Solid, extent = {{-3, 46.9}, {4.2, -47}}), Rectangle(origin = {12.1, -1}, fillColor = {255, 255, 255}, pattern = LinePattern.None, fillPattern = FillPattern.Solid, extent = {{-3, 46.9}, {4.2, -47}}), Rectangle(origin = {22.1, -1}, fillColor = {255, 255, 255}, pattern = LinePattern.None, fillPattern = FillPattern.Solid, extent = {{-3, 46.9}, {4.2, -47}}), Rectangle(origin = {32.3, -1}, fillColor = {255, 255, 255}, pattern = LinePattern.None, fillPattern = FillPattern.Solid, extent = {{-3, 46.9}, {4.2, -47}}), Rectangle(origin = {42.9, -1}, fillColor = {255, 255, 255}, pattern = LinePattern.None, fillPattern = FillPattern.Solid, extent = {{-3, 46.9}, {4.2, -47}})}, coordinateSystem(initialScale = 0.1)),
    Documentation(info = "<html><head></head><body>
<p>The FuelCellSystem class combines a <a href=\"modelica://VirtualFCS.Electrochemical.Hydrogen.FuelCellStack\">FuelCellStack</a> with a <a href=\"modelica://VirtualFCS.SubSystems.FuelCellSubSystems\">FuelCellSubSystems</a> module that supplies hydrogen, air and coolant to the stack. The air and cooling subsystems are <a href=\"modelica://VirtualFCS.SubSystems.Air.SubSystemAirCMP\">SubSystemAirCMP</a> and <a href=\"modelica://VirtualFCS.SubSystems.Cooling.SubSystemCoolingTST\">SubSystemCoolingTST</a>.</p>
<p>The stack is connected electrically via <code>pin_p</code>/<code>pin_n</code>. The balance-of-plant components (compressor, recirculation blower, coolant pump) are supplied via <code>pin_p_bat</code>/<code>pin_n_bat</code>.</p>
<p>The stack parameters set in this class (<code>A_FC_surf</code>, <code>N_FC_stack</code>, <code>j_0_ref</code>, <code>E_A</code>, <code>f_CL</code>, <code>D_GDL_ref</code>, <code>D_CL_ref</code>, <code>r_el</code>, <code>m_coolant</code>) are fitted to a Bosch fuel cell stack Gen1. The layer thicknesses <code>d_Mem</code>, <code>d_CL</code> and <code>d_GDL</code> (protected in FuelCellStack) are generic values. Heat exchange between the stack and its surroundings is not modelled; heat is only removed by the coolant and the gas streams.</p>

<h4>Requirements</h4>
<p>The enclosing model must provide <code>inner Modelica.Fluid.System system</code> and <code>inner VirtualFCS.Utilities.SystemControl systemControl</code>. The subsystems read their set points from <code>systemControl</code>; its operating-point table must match the selected subsystem variants (see <a href=\"modelica://VirtualFCS.Utilities.SystemControl\">SystemControl</a>).</p>

<h4>Outputs</h4>
<ul>
<li><code>Power_stack</code>: electrical power delivered by the stack.</li>
<li><code>Power_BoP</code>: electrical power of the balance-of-plant components (negative when consumed).</li>
<li><code>Power_system = Power_stack + Power_BoP</code>: net power of the system.</li>
<li><code>Energy_stack</code>: electrical energy delivered by the stack (time integral of <code>Power_stack</code>).</li>
<li><code>eta_FC_sys = max((1 - min(|Power_BoP/Power_stack|, 1))*eta_FC_LHV, 0)</code>: system efficiency based on the lower heating value; <code>calcMeanEta</code> provides its pulsed mean.</li>
</ul>

<h4>Plausibility limits</h4>
<p>The parameters <code>T_Ca_min</code> ... <code>p_cool_max</code> define plausible operating ranges for the cathode air, coolant and stack temperatures and for the cathode, anode and coolant pressures at the stack ports. They do not change the physics. A value outside its range stops the simulation with a message that names the quantity, instead of a later failure inside a component correlation.</p>
<table>
<tr><th>Quantity</th><th>Default range</th></tr>
<tr><td>Cathode air temperature at stack inlet and outlet (<code>T_Ca_min</code>, <code>T_Ca_max</code>)</td><td>263.15 &ndash; 373.15 K</td></tr>
<tr><td>Coolant temperature at stack inlet and outlet (<code>T_cool_min</code>, <code>T_cool_max</code>)</td><td>273.15 &ndash; 373.15 K</td></tr>
<tr><td>Stack temperature (<code>T_stack_min</code>, <code>T_stack_max</code>)</td><td>263.15 &ndash; 373.15 K</td></tr>
<tr><td>Cathode pressure (<code>p_Ca_min</code>, <code>p_Ca_max</code>)</td><td>0.4e5 &ndash; 4.0e5 Pa</td></tr>
<tr><td>Anode pressure (<code>p_An_min</code>, <code>p_An_max</code>)</td><td>0.4e5 &ndash; 12.0e5 Pa</td></tr>
<tr><td>Coolant pressure (<code>p_cool_min</code>, <code>p_cool_max</code>)</td><td>0.2e5 &ndash; 6.0e5 Pa</td></tr>
</table>
</body></html>"),
    experiment(StartTime = 0, StopTime = 100, Tolerance = 1e-06, Interval = 1),
    __OpenModelica_commandLineOptions = "--matchingAlgorithm=PFPlusExt --indexReductionMethod=dynamicStateSelection -d=initialization,NLSanalyticJacobian",
    __OpenModelica_simulationFlags(lv = "LOG_STDOUT,LOG_ASSERT,LOG_STATS", s = "dassl", variableFilter = ".*"));
end FuelCellSystem;
