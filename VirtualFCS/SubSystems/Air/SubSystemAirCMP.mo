within VirtualFCS.SubSystems.Air;

model SubSystemAirCMP
  // System
  outer Modelica.Fluid.System system "System properties";
  outer Utilities.SystemControl systemControl;
  import Modelica.Constants.*;
  //*** DEFINE REPLACEABLE PACKAGES ***//
  // Medium declaration
  replaceable package Medium = Modelica.Media.Air.MoistAir(Temperature(start = system.T_start), AbsolutePressure(start = system.p_start));
  // Parameter definition
  parameter Modelica.Units.SI.Pressure dp_nominal = 1e5;
  parameter Modelica.Units.SI.MassFlowRate mflow_nominal = 0.1;
  parameter Modelica.Units.SI.Time t_hum_valve = 25 "Opening time constant humidifier valve [s]";
  parameter Real Kv_p_valve(unit = "m3/h") = 28 "Kv (metric) flow coefficient [m3/h]";
  parameter Real Fxt_full_p_valve = 0.473 "Critical choke coefficient";
  parameter Real Kv_hum_valve(unit = "m3/h") = 193.5 "Kv (metric) flow coefficient [m3/h]";
  parameter Modelica.Units.SI.MassFraction X_w = Medium.massFraction_pTphi(system.p_ambient, system.T_ambient, 0.2);
  parameter Modelica.Units.SI.ThermalConductance k_th = 182.6 "Thermal conductance heat exchanger.";
  // Constants definition
  constant Modelica.Media.IdealGases.Common.DataRecord oxygen = Modelica.Media.IdealGases.Common.SingleGasesData.O2;
  //*** VALIDATION STATE VARIABLE DECLARATION*** //
  Modelica.Units.SI.Power P_cmp = max(pin_p.i*pin_p.v, eps) "The electrical power demand of the compressor";
  Modelica.Units.SI.MassFlowRate m_flow_cmp = cmp.Input.m_flow "Compressor air massflow ";
  Real phi_FC_in = Medium.relativeHumidity_pTX(Output.p, tempFCIn.T, Output.Xi_outflow) "Relative humidity at fuel cell inlet";
  // Internal state variables
  Modelica.Fluid.Sensors.Temperature tempCmpOut(redeclare package Medium = Medium) annotation(
    Placement(transformation(origin = {40, 73}, extent = {{-8, -7}, {8, 7}})));
  Modelica.Fluid.Sensors.Temperature tempHxOut(redeclare package Medium = Medium) annotation(
    Placement(transformation(origin = {119, 25}, extent = {{-7, -7}, {7, 7}})));
  Modelica.Fluid.Sensors.Temperature tempFCOut(redeclare package Medium = Medium) annotation(
    Placement(transformation(origin = {131, -43}, extent = {{-7, -7}, {7, 7}})));
  Modelica.Fluid.Sensors.Temperature tempFCIn(redeclare package Medium = Medium) annotation(
    Placement(transformation(origin = {131, -3}, extent = {{-7, -7}, {7, 7}})));
  //*** INSTANTIATE COMPONENTS ***//
  // Interfaces and boundaries
  Modelica.Fluid.Interfaces.FluidPort_a Input(redeclare package Medium = Medium) annotation(
    Placement(transformation(origin = {100, -51}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {62, 120}, extent = {{-20, -20}, {20, 20}})));
  Modelica.Fluid.Interfaces.FluidPort_b Output(redeclare package Medium = Medium) annotation(
    Placement(transformation(origin = {100, -10}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {-60, 121}, extent = {{-20, -19}, {20, 19}})));
  Modelica.Electrical.Analog.Interfaces.PositivePin pin_p annotation(
    Placement(visible = true, transformation(origin = {30, 48}, extent = {{10, -10}, {-10, 10}}, rotation = 0), iconTransformation(origin = {50, -90}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Electrical.Analog.Interfaces.NegativePin pin_n annotation(
    Placement(visible = true, transformation(origin = {-4, 48}, extent = {{10, -10}, {-10, 10}}, rotation = 0), iconTransformation(origin = {-50, -90}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  // Control components
  Modelica.Blocks.Sources.RealExpression setXAirPressureValve(y = 1 - systemControl.x_p_Ca) annotation(
    Placement(transformation(origin = {-20, -96}, extent = {{-10, -10}, {10, 10}})));
  // Machines
  //VirtualFCS.Fluid.CompressorLuT compressor(mf_max = 1.1*subSystemAirControl.stoic_Air_min*j_FC_lim*A_FC_surf*(0.02897/(96485*4*0.21)*N_FC_stack)) annotation(
  //Placement(visible = true, transformation(origin = {12, 18}, extent = {{-16, -16}, {16, 16}}, rotation = 0)));
  Fluid.CompressorPoly cmp(eta_el = 0.881, redeclare package Medium = Medium, c_Mf = [1.23343e-10, -8.72743e-11, -2.86475e-10, -5.28596e-11; 3.32314e-06, -5.57495e-06, -5.94695e-07, 0; 6.63531e-11, 8.07634e-11, 0, 0; -1.1223e-15, 0, 0, 0], c_P = [2.85121e-06, -7.4624e-07, -4.51327e-06, -2.2005e-06; 0.0703784, -0.0840068, -0.031413, 0; -1.43825e-07, 2.20965e-06, 0, 0; -4.75931e-12, 0, 0, 0]) annotation(
    Placement(visible = true, transformation(origin = {12, 18}, extent = {{-16, -16}, {16, 16}}, rotation = 0)));
  // Sensors
  // Valves
  Modelica.Fluid.Sensors.Pressure Inlet_air_pressure(redeclare package Medium = Medium) annotation(
    Placement(visible = true, transformation(origin = {74, 70}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heatPort_a annotation(
    Placement(transformation(origin = {100, 80}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {90, 0}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Fluid.Sensors.RelativePressure relativePressure(redeclare package Medium = Medium) annotation(
    Placement(transformation(origin = {110, -30}, extent = {{10, -10}, {-10, 10}}, rotation = 90)));
  Modelica.Blocks.Sources.RealExpression setCmpRpm(y = systemControl.w_cmp) annotation(
    Placement(transformation(origin = {-50, 50}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Fluid.Sources.Boundary_pT airSink(redeclare package Medium = Medium, nPorts = 1, p = system.p_ambient) annotation(
    Placement(transformation(origin = {-90, -50}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Fluid.Valves.ValveCompressible valveDownstream(CvData = Modelica.Fluid.Types.CvTypes.Kv, Kv = Kv_p_valve, redeclare package Medium = Medium, dp_nominal = dp_nominal, m_flow_nominal = mflow_nominal, opening(start = 1), p_nominal = dp_nominal, filteredOpening = true, riseTime = 0.1, m_flow_start = system.m_flow_start, m_flow_small = system.m_flow_small, leakageOpening = 0.01, show_T = false, show_V_flow = false, m_flow(start = system.m_flow_start), dp(start = system.dp_small), Fxt_full = Fxt_full_p_valve, redeclare function valveCharacteristic = VirtualFCS.Fluid.ValveCharacteristics.burkert2301_DN50_50_90) annotation(
    Placement(transformation(origin = {10, -50}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
  Modelica.Blocks.Sources.RealExpression setXHumBypass(y = 1 - systemControl.x_w_Ca) annotation(
    Placement(transformation(origin = {30, -96}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Fluid.Sources.Boundary_pT airSource(redeclare package Medium = Medium, nPorts = 1, p = system.p_ambient, T = system.T_ambient, X = {X_w, 1 - X_w}) annotation(
    Placement(transformation(origin = {-90, 18}, extent = {{-10, -10}, {10, 10}})));
  Thermal.HeatExchanger heatX(redeclare package Medium = Medium, dp(displayUnit = "Pa") = 1, T_b(displayUnit = "K"), k_th = k_th) annotation(
    Placement(transformation(origin = {50, 18}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Fluid.Valves.ValveCompressible valveMixHumBp(CvData = Modelica.Fluid.Types.CvTypes.Kv, Kv = Kv_hum_valve, redeclare package Medium = Medium, dp(start = system.dp_small), dp_nominal = dp_nominal, filteredOpening = true, leakageOpening = 0.1, m_flow(start = system.m_flow_start), m_flow_nominal = mflow_nominal, m_flow_small = system.m_flow_small, m_flow_start = system.m_flow_start, opening(start = 0.95, fixed = true), p_nominal = dp_nominal, riseTime = t_hum_valve, show_T = false, show_V_flow = false, redeclare function valveCharacteristic = VirtualFCS.Fluid.ValveCharacteristics.burkert2671_DN50) annotation(
    Placement(transformation(origin = {52, -50}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
  Modelica.Fluid.Valves.ValveCompressible valveMixHum(CvData = Modelica.Fluid.Types.CvTypes.Kv, Kv = Kv_hum_valve, redeclare package Medium = Medium, dp(start = system.dp_small), dp_nominal = dp_nominal, filteredOpening = true, leakageOpening = 0.1, m_flow(start = system.m_flow_start), m_flow_nominal = mflow_nominal, m_flow_small = system.m_flow_small, m_flow_start = system.m_flow_start, p_nominal = dp_nominal, riseTime = t_hum_valve, show_T = false, show_V_flow = false, redeclare function valveCharacteristic = VirtualFCS.Fluid.ValveCharacteristics.burkert2671_DN50) annotation(
    Placement(transformation(origin = {80, -30}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
  Fluid.FcHumidityExchanger humidifier(redeclare package Medium = Medium, opModeEffL = VirtualFCS.Utilities.Types.opModeHTX.fumatech_H50N) annotation(
    Placement(transformation(origin = {70, 0}, extent = {{10, -10}, {-10, 10}}, rotation = -0)));
  Modelica.Blocks.Sources.RealExpression setXHum(y = systemControl.x_w_Ca) annotation(
    Placement(transformation(origin = {90, -96}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Fluid.Fittings.GenericResistances.VolumeFlowRate airFilterResistance(redeclare package Medium = Medium, a = 678975, b = 6573) annotation(
    Placement(transformation(origin = {-50, 18}, extent = {{-10, -10}, {10, 10}})));
equation
//  Power_Compressor_mez = (cmp.Input.m_flow*298.15*1004/(1*0.8))*(((Output.p*0.00001)^0.28) - 1);
//Input.p*(();
//Power_Compressor_mez = (sen_Air_mflow.m_flow*298.15*1004/(0.9*0.7))*(((Output.p*0.00001)^0.28)-1);//Input.p*(();
//Rendement_compressor = (cmp.Input.m_flow*298.15*1004/(0.9*t))*(((Output.p*0.00001)^0.28) - 1);
//*** DEFINE CONNECTIONS ***//
  connect(pin_p, cmp.pin_p) annotation(
    Line(points = {{30, 48}, {15, 48}, {15, 28}}, color = {0, 0, 255}));
  connect(pin_n, cmp.pin_n) annotation(
    Line(points = {{-4, 48}, {10, 48}, {10, 28}}, color = {0, 0, 255}));
  connect(cmp.Output, Inlet_air_pressure.port) annotation(
    Line(points = {{30, 18}, {40, 18}, {40, 48}, {74, 48}, {74, 60}}, color = {0, 127, 255}));
  connect(setCmpRpm.y, cmp.controlInterface) annotation(
    Line(points = {{-38, 50}, {-24, 50}, {-24, 28}, {-6, 28}}, color = {0, 0, 127}));
  connect(setXAirPressureValve.y, valveDownstream.opening) annotation(
    Line(points = {{-9, -96}, {9, -96}, {9, -58}}, color = {0, 0, 127}));
  connect(tempFCOut.port, Input) annotation(
    Line(points = {{131, -50}, {100, -50}}, color = {0, 127, 255}));
  connect(airSink.ports[1], valveDownstream.port_b) annotation(
    Line(points = {{-80, -50}, {0, -50}}, color = {0, 127, 255}));
  connect(cmp.Output, tempCmpOut.port) annotation(
    Line(points = {{30, 18}, {40, 18}, {40, 66}}, color = {0, 127, 255}));
  connect(cmp.Output, heatX.port_a) annotation(
    Line(points = {{30, 18}, {40, 18}}, color = {0, 127, 255}));
  connect(valveMixHumBp.port_a, Input) annotation(
    Line(points = {{62, -50}, {100, -50}}, color = {0, 127, 255}));
  connect(valveMixHumBp.port_b, valveDownstream.port_a) annotation(
    Line(points = {{42, -50}, {20, -50}}, color = {0, 127, 255}));
  connect(relativePressure.port_b, Input) annotation(
    Line(points = {{110, -40}, {110, -50}, {100, -50}}, color = {0, 127, 255}));
  connect(relativePressure.port_a, Output) annotation(
    Line(points = {{110, -20}, {110, -10}, {100, -10}}, color = {0, 127, 255}));
  connect(valveMixHum.port_a, Input) annotation(
    Line(points = {{80, -40}, {80, -50}, {100, -50}}, color = {0, 127, 255}));
  connect(setXHumBypass.y, valveMixHumBp.opening) annotation(
    Line(points = {{42, -96}, {52, -96}, {52, -58}}, color = {0, 0, 127}));
  connect(humidifier.port_b1, valveDownstream.port_a) annotation(
    Line(points = {{60, 0}, {30, 0}, {30, -50}, {20, -50}}, color = {0, 127, 255}));
  connect(humidifier.port_a2, heatX.port_b) annotation(
    Line(points = {{70, 10}, {70, 18}, {60, 18}}, color = {0, 127, 255}));
  connect(humidifier.port_b2, Output) annotation(
    Line(points = {{70, -10}, {100, -10}}, color = {0, 127, 255}));
  connect(humidifier.port_a1, valveMixHum.port_b) annotation(
    Line(points = {{80, 0}, {80, -20}}, color = {0, 127, 255}));
  connect(heatPort_a, heatX.heatport_a) annotation(
    Line(points = {{100, 80}, {100, 32}, {50, 32}, {50, 20}}, color = {191, 0, 0}));
  connect(heatX.port_b, tempHxOut.port) annotation(
    Line(points = {{60, 18}, {119, 18}}, color = {0, 127, 255}));
  connect(tempFCIn.port, Output) annotation(
    Line(points = {{132, -10}, {100, -10}}, color = {0, 127, 255}));
  connect(setXHum.y, valveMixHum.opening) annotation(
    Line(points = {{79, -96}, {68, -96}, {68, -30}, {72, -30}}, color = {0, 0, 127}));
  connect(airFilterResistance.port_b, cmp.Input) annotation(
    Line(points = {{-40, 18}, {-6, 18}}, color = {0, 127, 255}));
  connect(airFilterResistance.port_a, airSource.ports[1]) annotation(
    Line(points = {{-60, 18}, {-80, 18}}, color = {0, 127, 255}));
  annotation(
    Icon(coordinateSystem(initialScale = 0.1), graphics = {Rectangle(fillColor = {0, 60, 101}, fillPattern = FillPattern.Solid, lineThickness = 1.5, extent = {{-100, 100}, {100, -100}}, radius = 35), Text(origin = {-44, 70}, textColor = {255, 255, 255}, extent = {{-22, 12}, {112, -142}}, textString = "Air")}),
    Diagram(coordinateSystem(initialScale = 0.1)),
    Documentation(info = "<html><head></head><body>
<p>Air supply subsystem with an electrically driven compressor, charge-air cooler, membrane humidifier with
bypass, and a back-pressure valve. Set points are read from the <code>outer</code>
<a href=\"modelica://VirtualFCS.Utilities.SystemControl\">SystemControl</a> instance <code>systemControl</code>.</p>

<h4>Flow path</h4>
<p>Ambient air (<code>airSource</code>, relative humidity 0.2 at <code>system.p_ambient</code> and <code>system.T_ambient</code>)
&rarr; air filter resistance &rarr; compressor <code>cmp</code> &rarr; heat exchanger <code>heatX</code> (coupled to
<code>heatPort_a</code>) &rarr; humidifier dry side &rarr; <code>Output</code> (stack cathode inlet).
The stack cathode exhaust at <code>Input</code> passes either through the humidifier wet side (<code>valveMixHum</code>) or
through the bypass valve (<code>valveMixHumBp</code>) and leaves through the back-pressure valve
<code>valveDownstream</code> to ambient.</p>

<h4>Input variables (from <code>systemControl</code>)</h4>
<table>
<tr><td><code>w_cmp</code></td><td>Compressor speed set point [rpm]</td></tr>
<tr><td><code>x_p_Ca</code></td><td>Closing fraction of the back-pressure valve [-]; valve opening = <code>1 - x_p_Ca</code></td></tr>
<tr><td><code>x_w_Ca</code></td><td>Opening of the humidifier valve [-]; bypass opening = <code>1 - x_w_Ca</code></td></tr>
</table>

<h4>Relevant variables</h4>
<table>
<tr><td><code>P_cmp</code></td><td>Electrical power drawn by the compressor [W]</td></tr>
<tr><td><code>m_flow_cmp</code></td><td>Compressor air mass flow [kg/s]</td></tr>
<tr><td><code>phi_FC_in</code></td><td>Relative humidity at the stack inlet [-]</td></tr>
<tr><td><code>relativePressure.p_rel</code></td><td>Cathode pressure difference stack inlet &ndash; outlet [Pa]</td></tr>
<tr><td><code>tempCmpOut.T</code>, <code>tempHxOut.T</code>, <code>tempFCIn.T</code>, <code>tempFCOut.T</code></td><td>Air temperatures after the compressor, after the heat exchanger, at the stack inlet and at the stack outlet [K]</td></tr>
</table>

<h4>Parameters</h4>
<table>
<tr><td><code>Kv_p_valve</code></td><td>Kv of the back-pressure valve [m3/h], characteristic <a href=\"modelica://VirtualFCS.Fluid.ValveCharacteristics.burkert2301_DN50_50_90\">burkert2301_DN50_50_90</a></td></tr>
<tr><td><code>Fxt_full_p_valve</code></td><td>Critical pressure-ratio factor of the back-pressure valve [-]</td></tr>
<tr><td><code>Kv_hum_valve</code></td><td>Kv of the humidifier and bypass valves [m3/h], characteristic <a href=\"modelica://VirtualFCS.Fluid.ValveCharacteristics.burkert2671_DN50\">burkert2671_DN50</a></td></tr>
<tr><td><code>t_hum_valve</code></td><td>Rise time of the humidifier and bypass valves [s]</td></tr>
<tr><td><code>dp_nominal</code>, <code>mflow_nominal</code></td><td>Nominal pressure drop [Pa] and mass flow rate [kg/s] of the valves</td></tr>
<tr><td><code>k_th</code></td><td>Thermal conductance of the charge-air heat exchanger [W/K]</td></tr>
<tr><td><code>X_w</code></td><td>Water mass fraction of the ambient air [kg/kg]</td></tr>
<tr><td><code>cmp.c_P</code>, <code>cmp.c_Mf</code>, <code>cmp.tau</code>, <code>cmp.P_max</code></td><td>Compressor maps, time constant and power limit, see <a href=\"modelica://VirtualFCS.Fluid.PolyMover\">PolyMover</a></td></tr>
</table>
<p>The humidifier uses the <code>fumatech_H50N</code> water-transfer correlation of
<a href=\"modelica://VirtualFCS.Fluid.FcHumidityExchanger\">FcHumidityExchanger</a>.</p>
</body></html>"));
end SubSystemAirCMP;