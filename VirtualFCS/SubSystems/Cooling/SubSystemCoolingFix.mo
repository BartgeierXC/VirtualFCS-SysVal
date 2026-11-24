within VirtualFCS.SubSystems.Cooling;

model SubSystemCoolingFix
  import ModelicaServices.Machine.inf;
  import ModelicaServices.Machine.eps;
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
  parameter Modelica.Units.SI.Time tau = 3 "Time constant valve opening house coolant";
  parameter Modelica.Units.SI.Pressure p_TST_coolant_in = 360000 "Pressure inlet house coolant";
  parameter Modelica.Units.SI.VolumeFlowRate K_vs_Hex_valve = 6.639/3600 "House coolant heat exchanger valve K_vs at dp0 = 1 bar";
  parameter Modelica.Units.SI.VolumeFlowRate K_v0_Hex_valve = 0.067/3600 "House coolant heat exchanger valve leakage K_v at dp0 = 1 bar";
  parameter Boolean p_Cl_constant = true "Pressure inlet house coolant constant (otherwise varied by systemControl)";
  parameter Boolean T_Cl_constant = true "Temperature inlet house coolant constant (otherwise varied by systemControl)";
  //*** VALIDATION STATE VARIABLE DECLARATION*** //
  Modelica.Thermal.FluidHeatFlow.Sensors.TemperatureSensor tempFCIn(medium = medium) annotation(
    Placement(transformation(origin = {70, 10}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Units.SI.Power P_cwp = pumpElectricDCFluidHF.firstOrderPT1.y;
  // Internal state variables
  //*** INSTANTIATE COMPONENTS ***//
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
  Modelica.Thermal.FluidHeatFlow.Components.Pipe pipeHex(T0 = system.T_ambient, T0fixed = true, V_flowLaminar = 1.857383e-04, V_flowNominal = 2.835844e-03, dpLaminar(displayUnit = "Pa") = 1e-6, dpNominal(displayUnit = "Pa") = 42552.75, h_g = 0, m = m_coolant_int, medium = medium, useHeatPort = false, tapT = 0.5) annotation(
    Placement(transformation(origin = {10, -40}, extent = {{0, 10}, {20, -10}}, rotation = 180)));
  Modelica.Thermal.FluidHeatFlow.Sources.Ambient boundaryIn(constantAmbientPressure = system.p_ambient, constantAmbientTemperature = system.T_ambient, medium = medium, T(start = system.T_ambient), useTemperatureInput = true) annotation(
    Placement(transformation(origin = {-50, 40}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
  Modelica.Thermal.FluidHeatFlow.Sensors.VolumeFlowSensor volumeFlow(T(start = system.T_ambient), medium = medium) annotation(
    Placement(transformation(origin = {50, 40}, extent = {{10, -10}, {-10, 10}}, rotation = -180)));
  Modelica.Thermal.FluidHeatFlow.Sensors.TemperatureSensor tempFCOut(medium = medium) annotation(
    Placement(transformation(origin = {70, -10}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Blocks.Sources.RealExpression setCwpPower(y = systemControl.P_cwp) annotation(
    Placement(transformation(origin = {0, 20}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Thermal.FluidHeatFlow.Sensors.RelPressureSensor relPressure(medium = medium) annotation(
    Placement(transformation(origin = {100, 0}, extent = {{10, -10}, {-10, 10}}, rotation = 90)));
  Modelica.Thermal.FluidHeatFlow.Components.Pipe pipeHeatEx(T0 = system.T_ambient, T0fixed = true, V_flow(start = 1e-6), V_flowLaminar = pipeHeatEx.V_flowNominal/10, V_flowNominal = 1, dpLaminar = pipeHeatEx.dpNominal/10, dpNominal(displayUnit = "kPa") = 1000, h_g = 0, m = m_coolant_air, medium = medium, tapT = 0.5, useHeatPort = true) annotation(
    Placement(transformation(origin = {80, 40}, extent = {{8, -8}, {-8, 8}}, rotation = 180)));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heatport_a annotation(
    Placement(transformation(origin = {100, 80}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {90, 0}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.RealExpression realT(y = systemControl.T_Cl)  annotation(
    Placement(transformation(origin = {-80, 46}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Thermal.FluidHeatFlow.Sources.Ambient boundaryOut(T(start = system.T_ambient), constantAmbientPressure = system.p_ambient, constantAmbientTemperature = system.T_ambient, medium = medium, useTemperatureInput = false) annotation(
    Placement(transformation(origin = {-50, -40}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
equation
//*** DEFINE CONNECTIONS ***//
  connect(pumpElectricDCFluidHF.pin_n, pin_n) annotation(
    Line(points = {{17, 48}, {-3, 48}, {-3, 100}, {0, 100}}, color = {0, 0, 255}));
  connect(pumpElectricDCFluidHF.pin_p, pin_p) annotation(
    Line(points = {{23, 48}, {37, 48}, {37, 100}, {40, 100}}, color = {0, 0, 255}));
  connect(boundaryIn.flowPort, pumpElectricDCFluidHF.Input) annotation(
    Line(points = {{-40, 40}, {11, 40}}, color = {255, 0, 0}));
  connect(pumpElectricDCFluidHF.Output, volumeFlow.flowPort_a) annotation(
    Line(points = {{29, 40}, {40, 40}}, color = {255, 0, 0}));
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
  connect(realT.y, boundaryIn.ambientTemperature) annotation(
    Line(points = {{-69, 46}, {-61, 46}}, color = {0, 0, 127}));
  connect(boundaryOut.flowPort, pipeHex.flowPort_b) annotation(
    Line(points = {{-40, -40}, {-10, -40}}, color = {255, 0, 0}));
  connect(volumeFlow.flowPort_b, pipeHeatEx.flowPort_a) annotation(
    Line(points = {{60, 40}, {72, 40}}, color = {255, 0, 0}));
  connect(pipeHeatEx.flowPort_b, flowPort_b) annotation(
    Line(points = {{88, 40}, {100, 40}}, color = {255, 0, 0}));
  connect(pipeHex.flowPort_a, flowPort_a) annotation(
    Line(points = {{10, -40}, {100, -40}}, color = {255, 0, 0}));
  connect(pipeHeatEx.heatPort, heatport_a) annotation(
    Line(points = {{80, 48}, {80, 80}, {100, 80}}, color = {191, 0, 0}));
  annotation(
    Icon(graphics = {Rectangle(fillColor = {0, 60, 101}, fillPattern = FillPattern.Solid, lineThickness = 1.5, extent = {{-100, 100}, {100, -100}}, radius = 35), Text(origin = {9, -11}, textColor = {255, 255, 255}, extent = {{-81, 89}, {65, -55}}, textString = "Cool")}, coordinateSystem(initialScale = 0.1)),
    experiment(StopTime = 200, Interval = 1, Tolerance = 1e-06, StartTime = 0),
    Diagram,
    Documentation(info = "<html><head></head><body>
<p>Simplified cooling subsystem without a house-coolant heat exchanger. The coolant pump draws water from
an ambient boundary <code>boundaryIn</code> whose temperature is <code>systemControl.T_Cl</code>. The water passes
through the charge-air cooler <code>pipeHeatEx</code> (<code>heatport_a</code>) to the stack inlet (<code>flowPort_b</code>).
Water returning from the stack (<code>flowPort_a</code>) flows through <code>pipeHex</code> (no heat port) to the
ambient boundary <code>boundaryOut</code>. The stack inlet temperature therefore follows <code>T_Cl</code> directly
(open loop, no recirculation).</p>

<h4>Input variables (from <code>systemControl</code>)</h4>
<table>
<tr><td><code>P_cwp</code></td><td>Coolant pump command [-]</td></tr>
<tr><td><code>T_Cl</code></td><td>Coolant supply temperature [K]</td></tr>
</table>

<h4>Relevant variables</h4>
<table>
<tr><td><code>relPressure.y</code></td><td>Coolant pressure difference stack inlet &ndash; outlet [Pa]</td></tr>
<tr><td><code>tempFCIn.y</code>, <code>tempFCOut.y</code></td><td>Coolant temperature at the stack inlet and outlet [K]</td></tr>
<tr><td><code>P_cwp</code></td><td>Filtered electrical power of the coolant pump [W]</td></tr>
</table>

<p>The parameters <code>m_coolant_ext</code>, <code>G</code>, <code>T_TST_coolant_set</code>, <code>tau</code>,
<code>p_TST_coolant_in</code>, <code>K_vs_Hex_valve</code>, <code>K_v0_Hex_valve</code>, <code>p_Cl_constant</code> and
<code>T_Cl_constant</code> are not used by this variant. They are declared so that the modifiers in
<a href=\"modelica://VirtualFCS.SubSystems.FuelCellSubSystems\">FuelCellSubSystems</a> also apply when
<code>subSystemCooling</code> is redeclared to this class.</p>
</body></html>"));
end SubSystemCoolingFix;