within VirtualFCS.SubSystems.Cooling;

model SubSystemCoolingTST
  // System
  outer Utilities.SystemControl systemControl;
  outer Modelica.Fluid.System system "System properties";
  //  inner Modelica.Fluid.System system(energyDynamics = Modelica.Fluid.Types.Dynamics.FixedInitial, massDynamics = Modelica.Fluid.Types.Dynamics.SteadyStateInitial) annotation(
  //    Placement(visible = true, transformation(origin = {-90, 90}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  //*** DEFINE REPLACEABLE PACKAGES ***//
  // Medium declaration
  parameter Modelica.Thermal.FluidHeatFlow.Media.Medium medium = Modelica.Thermal.FluidHeatFlow.Media.Water();
  // Parameter definition
  parameter Modelica.Units.SI.Mass m_coolant_int = 33 "Total coolant fluid mass internal circuit";
  parameter Modelica.Units.SI.Mass m_coolant_ext = 33 "Total coolant fluid mass external circuit";
  parameter Modelica.Units.SI.Mass m_coolant_air = 3.18 "Total coolant fluid mass cathode circuit";
  parameter Modelica.Units.SI.ThermalConductance G = 6200;
  parameter Modelica.Units.SI.Temperature T_TST_coolant_set = Modelica.Units.Conversions.from_degC(18) "External coolant temperature set";
  parameter Modelica.Units.SI.Time slew_time = 72.25 "Time for full transient opening house coolant valve";
  parameter Modelica.Units.SI.Pressure p_TST_coolant_in = 432000 + system.p_ambient "Pressure inlet house coolant";
  parameter Modelica.Units.SI.Pressure p_TST_coolant_out = system.p_ambient "Pressure outlet house coolant";
  parameter Modelica.Units.SI.VolumeFlowRate K_vs_Hex_valve = 6.639/3600 "House coolant heat exchanger valve K_vs at dp0 = 1 bar";
  parameter Modelica.Units.SI.VolumeFlowRate K_v0_Hex_valve = 0.067/3600 "House coolant heat exchanger valve leakage K_v at dp0 = 1 bar";
  parameter Boolean p_Cl_constant = true "Pressure inlet house coolant constant (otherwise varied by systemControl)";
  parameter Boolean T_Cl_constant = true "Temperature inlet house coolant constant (otherwise varied by systemControl)";
  //*** VALIDATION STATE VARIABLE DECLARATION*** //
  Modelica.Thermal.FluidHeatFlow.Sensors.TemperatureSensor tempFCIn(medium = medium) annotation(
    Placement(transformation(origin = {70, 10}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Units.SI.Power P_cwp = pumpElectricDCFluidHF.firstOrderPT1.y;
  // Internal state variables
  Modelica.Thermal.FluidHeatFlow.Sensors.TemperatureSensor tempHXOut(medium = medium) annotation(
    Placement(transformation(origin = {66, -64}, extent = {{10, -10}, {-10, 10}}, rotation = -90)));
  //*** INSTANTIATE COMPONENTS ***//
  Real x_Cl_opening = 1-systemControl.x_Cl;
  
  // Interfaces and boundaries
  Modelica.Electrical.Analog.Interfaces.PositivePin pin_p annotation(
    Placement(transformation(origin = {40, 100}, extent = {{10, -10}, {-10, 10}}), iconTransformation(origin = {50, -90}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Interfaces.NegativePin pin_n annotation(
    Placement(transformation(origin = {0, 100}, extent = {{10, -10}, {-10, 10}}), iconTransformation(origin = {-50, -90}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Thermal.FluidHeatFlow.Interfaces.FlowPort_a flowPort_a(medium = medium) annotation(
    Placement(visible = true, transformation(origin = {100, -40}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {50, 92}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Thermal.FluidHeatFlow.Interfaces.FlowPort_b flowPort_b(medium = medium) annotation(
    Placement(visible = true, transformation(origin = {100, 40}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {-50, 92}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Fluid.PumpElectricDCFluidHFPoly pumpElectricDCFluidHF(medium = medium, m_coolant = 1.23) annotation(
    Placement(transformation(origin = {20, 40}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Thermal.FluidHeatFlow.Components.Pipe pipeHex(T0 = system.T_ambient, T0fixed = true, V_flowLaminar = 1.857383e-04, V_flowNominal = 2.835844e-03, dpLaminar(displayUnit = "Pa") = 1e-6, dpNominal(displayUnit = "Pa") = 42552.75, h_g = 0, m = m_coolant_int, medium = medium, useHeatPort = true, tapT = 0.5) annotation(
    Placement(transformation(origin = {50, -40}, extent = {{0, 10}, {20, -10}}, rotation = 180)));
  Modelica.Thermal.FluidHeatFlow.Sources.Ambient boundary(constantAmbientPressure = system.p_ambient, constantAmbientTemperature = system.T_ambient, medium = medium, T(start = system.T_ambient)) annotation(
    Placement(visible = true, transformation(origin = {-70, 40}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
  Modelica.Thermal.FluidHeatFlow.Sensors.VolumeFlowSensor volumeFlow(T(start = system.T_ambient), medium = medium) annotation(
    Placement(transformation(origin = {50, 40}, extent = {{10, -10}, {-10, 10}}, rotation = -180)));
  Modelica.Thermal.FluidHeatFlow.Sources.Ambient coolantSupply(constantAmbientPressure = p_TST_coolant_in, constantAmbientTemperature = T_TST_coolant_set, medium = medium, usePressureInput = false, useTemperatureInput = true) annotation(
    Placement(transformation(origin = {-70, -80}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
  Modelica.Thermal.FluidHeatFlow.Components.Pipe pipeHexCold(T0 = T_TST_coolant_set, T0fixed = false, V_flowLaminar = pipeHex.V_flowLaminar, V_flowNominal = pipeHex.V_flowNominal, dpLaminar = pipeHex.dpLaminar, dpNominal = pipeHex.dpNominal, h_g = 0, m = m_coolant_ext, medium = medium, useHeatPort = true, V_flow(start = 3e-5)) annotation(
    Placement(transformation(origin = {30, -80}, extent = {{0, -10}, {-20, 10}}, rotation = 180)));
  Modelica.Thermal.FluidHeatFlow.Sources.Ambient coolantSink(constantAmbientPressure = system.p_ambient, constantAmbientTemperature = T_TST_coolant_set, medium = medium, useTemperatureInput = false, usePressureInput = true) annotation(
    Placement(transformation(origin = {90, -80}, extent = {{10, -10}, {-10, 10}}, rotation = -180)));
  Modelica.Thermal.HeatTransfer.Components.ThermalConductor thermalConductor(G = G) annotation(
    Placement(transformation(origin = {40, -60}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Thermal.FluidHeatFlow.Components.Valve valve(m = 0.1, medium = medium, T0 = system.T_ambient, LinearCharacteristic = true, y1 = 1, Kv1 = K_vs_Hex_valve, kv0 = K_v0_Hex_valve/K_vs_Hex_valve, dp0(displayUnit = "Pa") = 1e5, rho0(displayUnit = "kg/m3") = 998, frictionLoss = 0, V_flow(start = 3e-5)) annotation(
    Placement(transformation(origin = {10, -80}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Thermal.FluidHeatFlow.Sensors.TemperatureSensor tempFCOut(medium = medium) annotation(
    Placement(transformation(origin = {70, -10}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Blocks.Sources.RealExpression setCwpPower(y = systemControl.P_cwp) annotation(
    Placement(transformation(origin = {0, 20}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Thermal.FluidHeatFlow.Sensors.RelPressureSensor relPressure(medium = medium) annotation(
    Placement(transformation(origin = {100, 0}, extent = {{10, -10}, {-10, 10}}, rotation = 90)));
  Modelica.Blocks.Sources.RealExpression setCoolantPressureOut(y = if p_Cl_constant then p_TST_coolant_out else max(systemControl.p_Cl, system.p_ambient)) annotation(
    Placement(transformation(origin = {132, -86}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Blocks.Sources.RealExpression setCoolantTemperature(y = if T_Cl_constant then T_TST_coolant_set else systemControl.T_Cl) annotation(
    Placement(transformation(origin = {-100, -74}, extent = {{-10, -10}, {10, 10}}, rotation = -0)));
  Modelica.Thermal.FluidHeatFlow.Components.Pipe pipeHeatEx(T0 = system.T_ambient, T0fixed = true, V_flow(start = 1e-6), V_flowLaminar = pipeHeatEx.V_flowNominal/10, V_flowNominal = 1, dpLaminar = pipeHeatEx.dpNominal/10, dpNominal(displayUnit = "kPa") = 1000, h_g = 0, m = m_coolant_air, medium = medium, tapT = 0.5, useHeatPort = true) annotation(
    Placement(transformation(origin = {80, 40}, extent = {{-8, 8}, {8, -8}}, rotation = -0)));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heatport_a annotation(
    Placement(transformation(origin = {100, 80}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {90, 0}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.RealExpression setValveCharacteristic(y = max(Fluid.ValveCharacteristics.coolantMixValveTST(1 - systemControl.x_Cl), 0)) annotation(
    Placement(transformation(origin = {-50, -60}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Nonlinear.SlewRateLimiter slewRateLimiter(Rising = 1/slew_time, Td = 0.1, y_start = 0, initType = Modelica.Blocks.Types.Init.InitialState) annotation(
    Placement(transformation(origin = {-20, -60}, extent = {{-10, -10}, {10, 10}})));
equation
//*** DEFINE CONNECTIONS ***//
  connect(pumpElectricDCFluidHF.pin_n, pin_n) annotation(
    Line(points = {{17, 48}, {-3, 48}, {-3, 100}, {0, 100}}, color = {0, 0, 255}));
  connect(pumpElectricDCFluidHF.pin_p, pin_p) annotation(
    Line(points = {{23, 48}, {37, 48}, {37, 100}, {40, 100}}, color = {0, 0, 255}));
  connect(pipeHex.flowPort_a, flowPort_a) annotation(
    Line(points = {{50, -40}, {100, -40}}, color = {255, 0, 0}));
  connect(boundary.flowPort, pumpElectricDCFluidHF.Input) annotation(
    Line(points = {{-60, 40}, {11, 40}}, color = {255, 0, 0}));
  connect(pumpElectricDCFluidHF.Output, volumeFlow.flowPort_a) annotation(
    Line(points = {{29, 40}, {40, 40}}, color = {255, 0, 0}));
  connect(pipeHex.heatPort, thermalConductor.port_a) annotation(
    Line(points = {{40, -50}, {40, -50}}, color = {191, 0, 0}));
  connect(pipeHexCold.heatPort, thermalConductor.port_b) annotation(
    Line(points = {{40, -70}, {40, -70}}, color = {191, 0, 0}));
  connect(pipeHex.flowPort_b, boundary.flowPort) annotation(
    Line(points = {{30, -40}, {-20, -40}, {-20, 40}, {-60, 40}}, color = {255, 0, 0}));
  connect(coolantSupply.flowPort, valve.flowPort_a) annotation(
    Line(points = {{-60, -80}, {0, -80}}, color = {255, 0, 0}));
  connect(pipeHexCold.flowPort_b, coolantSink.flowPort) annotation(
    Line(points = {{50, -80}, {80, -80}}, color = {255, 0, 0}));
  connect(valve.flowPort_b, pipeHexCold.flowPort_a) annotation(
    Line(points = {{20, -80}, {30, -80}}, color = {255, 0, 0}));
  connect(setCwpPower.y, pumpElectricDCFluidHF.contol_input) annotation(
    Line(points = {{11, 20}, {17, 20}, {17, 32}}, color = {0, 0, 127}));
  connect(relPressure.flowPort_a, flowPort_b) annotation(
    Line(points = {{100, 10}, {100, 40}}, color = {255, 0, 0}));
  connect(relPressure.flowPort_b, flowPort_a) annotation(
    Line(points = {{100, -10}, {100, -40}}, color = {255, 0, 0}));
  connect(flowPort_b, tempFCIn.flowPort) annotation(
    Line(points = {{100, 40}, {100, 10}, {80, 10}}, color = {255, 0, 0}));
  connect(flowPort_a, tempFCOut.flowPort) annotation(
    Line(points = {{100, -40}, {100, -10}, {80, -10}}, color = {255, 0, 0}));
  connect(tempHXOut.flowPort, pipeHexCold.flowPort_b) annotation(
    Line(points = {{66, -74}, {66, -80}, {50, -80}}, color = {255, 0, 0}));
  connect(setCoolantTemperature.y, coolantSupply.ambientTemperature) annotation(
    Line(points = {{-89, -74}, {-80, -74}}, color = {0, 0, 127}));
  connect(volumeFlow.flowPort_b, pipeHeatEx.flowPort_a) annotation(
    Line(points = {{60, 40}, {72, 40}}, color = {255, 0, 0}));
  connect(pipeHeatEx.flowPort_b, flowPort_b) annotation(
    Line(points = {{88, 40}, {100, 40}}, color = {255, 0, 0}));
  connect(pipeHeatEx.heatPort, heatport_a) annotation(
    Line(points = {{80, 48}, {80, 80}, {100, 80}}, color = {191, 0, 0}));
  connect(setCoolantPressureOut.y, coolantSink.ambientPressure) annotation(
    Line(points = {{122, -86}, {100, -86}}, color = {0, 0, 127}));
  connect(setValveCharacteristic.y, slewRateLimiter.u) annotation(
    Line(points = {{-39, -60}, {-32, -60}}, color = {0, 0, 127}));
  connect(slewRateLimiter.y, valve.y) annotation(
    Line(points = {{-9, -60}, {10, -60}, {10, -70}}, color = {0, 0, 127}));
  annotation(
    Icon(graphics = {Rectangle(fillColor = {0, 60, 101}, fillPattern = FillPattern.Solid, lineThickness = 1.5, extent = {{-100, 100}, {100, -100}}, radius = 35), Text(origin = {9, -11}, textColor = {255, 255, 255}, extent = {{-81, 89}, {65, -55}}, textString = "Cool")}, coordinateSystem(initialScale = 0.1)),
    experiment(StopTime = 200, Interval = 1, Tolerance = 1e-06, StartTime = 0),
    Diagram,
    Documentation(info = "<html><head></head><body>
<p>Simple cooling subsystem for a test stand setup. The main coolant circuit is coupled to a stationary \"house\" coolant circuit via a heat exchanger.</p>
<p>Stack coolant loop: <code>flowPort_a</code> (stack outlet) → <code>pipeHex</code> (hot side of the house-coolant heat exchanger) → open boundary <code>boundary</code> (ambient pressure) → pump → <code>pipeHeatEx</code> (charge-air cooler, <code>heatport_a</code>) → <code>flowPort_b</code> (stack inlet).
House coolant: <code>coolantSupply</code> (pressure <code>p_TST_coolant_in</code>, temperature <code>T_TST_coolant_set</code> or <code>systemControl.T_Cl</code>) → <code>valve</code> → <code>pipeHexCold</code> → <code>coolantSink</code>.
The valve position is <code>coolantMixValveTST(1 - x_Cl)</code> (<a href=\"modelica://VirtualFCS.Fluid.ValveCharacteristics.coolantMixValveTST\">coolantMixValveTST</a>),&nbsp;rate limited to full opening in <code>slew_time</code> [s].
The two pipes are coupled by <code>thermalConductor</code> (conductance <code>G</code> [W/K]).</p>

<h4>Input Variables</h4>
<table>
<tbody><tr><td><code>systemControl.P_cwp</code></td><td>Coolant pump command [-]</td></tr>
<tr><td><code>systemControl.x_Cl</code></td><td>Closing fraction of the house coolant valve [-]; valve opening = <code>1 - x_Cl</code></td></tr>
<tr><td><code>systemControl.p_Cl</code></td><td>House coolant outlet pressure [Pa], used if <code>p_Cl_constant = false</code></td></tr>
<tr><td><code>systemControl.T_Cl</code></td><td>House coolant supply temperature [K], used if <code>T_Cl_constant = false</code></td></tr>
</tbody></table>

<h4>Relevant State Variables</h4>
<table>
<tbody><tr><td><code>relPressure.y</code></td><td>Coolant pressure difference between stack inlet and outlet [Pa]</td></tr>
<tr><td><code>tempFCIn.y</code></td><td>Coolant temperature at the stack inlet [K]</td></tr>
<tr><td><code>tempFCOut.y</code></td><td>Coolant temperature at the stack outlet [K]</td></tr>
<tr><td><code>tempHXOut.y</code></td><td>House coolant temperature at the heat exchanger outlet [K]</td></tr>
<tr><td><code>pumpElectricDCFluidHF.realPowerEl.y</code></td><td>Electrical power of the coolant pump [W]</td></tr>
</tbody></table>

<h4>Physical Parameters</h4>
<table>
<tbody><tr><td><code>pumpElectricDCFluidHF.t_rampup</code></td><td>Ramp time of the coolant pump speed command [s]</td></tr>
<tr><td><code>pumpElectricDCFluidHF.P_0</code>, <code>P_1</code>, <code>P_2</code>, <code>p_con</code></td><td>Coefficients of the coolant pump power function</td></tr>
<tr><td><code>pumpElectricDCFluidHF.c_Vf</code></td><td>Coefficients of the coolant pump volume flow map</td></tr>
<tr><td><code>G</code></td><td>Thermal conductance of the heat exchanger [W/K]</td></tr>
<tr><td><code>slew_time</code></td><td>Time for full travel of the house coolant valve [s]. 72.25 s corresponds to the maximum travel rate of 1.384 %/s of the valve actuator, determined from the time derivative of the analog position signal (Weizinger, master thesis, 2026-05).</td></tr>
<tr><td><code>K_vs_Hex_valve</code></td><td>K<sub>vs</sub> of the fully open house coolant valve at 1 bar (<code>valve.Kv1</code>) [m<sup>3</sup>/s]</td></tr>
<tr><td><code>K_v0_Hex_valve</code></td><td>Leakage K<sub>v</sub> of the closed house coolant valve at 1 bar (<code>valve.kv0 = K_v0_Hex_valve/K_vs_Hex_valve</code>) [m<sup>3</sup>/s]</td></tr>
</tbody></table>

<h4>Functional Parameters</h4>
<table>
<tbody><tr><td><code>pumpElectricDCFluidHF.vflow_max</code></td><td>Volume flow limit of the coolant pump [m<sup>3</sup>/s], displayed in m<sup>3</sup>/h</td></tr>
</tbody></table>
</body></html>"));
end SubSystemCoolingTST;
