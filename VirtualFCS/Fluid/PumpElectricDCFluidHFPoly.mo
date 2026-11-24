within VirtualFCS.Fluid;

model PumpElectricDCFluidHFPoly
  // System
  outer Modelica.Fluid.System system "System wide properties";
  import ModelicaServices.Machine.inf;
  import ModelicaServices.Machine.eps;
  //*** DEFINE REPLACEABLE PACKAGES ***//
  // Medium declaration
  parameter Modelica.Thermal.FluidHeatFlow.Media.Medium medium = Modelica.Thermal.FluidHeatFlow.Media.Water();
  //*** INSTANTIATE COMPONENTS ***//
  // Interfaces and boundaries
  Modelica.Electrical.Analog.Interfaces.PositivePin pin_p annotation(
    Placement(visible = true, transformation(origin = {80, 100}, extent = {{10, -10}, {-10, 10}}, rotation = 0), iconTransformation(origin = {30, 80}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Electrical.Analog.Interfaces.NegativePin pin_n annotation(
    Placement(visible = true, transformation(origin = {40, 100}, extent = {{10, -10}, {-10, 10}}, rotation = 0), iconTransformation(origin = {-30, 80}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  // Control components
  Modelica.Blocks.Interfaces.RealInput contol_input annotation(
    Placement(visible = true, transformation(origin = {-110, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {-30, -80}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
  // Machines
  // Sensors
  // Other
  parameter Modelica.Units.SI.VolumeFlowRate vflow_max(displayUnit = "m3/h") = 16.8/3600 "Maximum volume flow";
  parameter Modelica.Units.NonSI.AngularVelocity_rpm w_max = 2900;
  parameter Modelica.Units.SI.Power P_2 = 2058.3 "Quadratic power function factor.";
  parameter Modelica.Units.SI.Power P_1 = -783.1 "Linear power function factor.";
  parameter Modelica.Units.SI.Power P_0 = 239.1 "Constant power function factor.";
  parameter Real p_con = 0.19 "Constant power function coefficient. Pump power is constant below p_con.";
  parameter Modelica.Units.SI.Time t_rampup = 3 "Time for the speed command to ramp from 0 to 1";
  parameter Modelica.Units.SI.Mass m_coolant = 1 "Mass of coolant in pump";
  // Power & Efficiency
  parameter Real c_Vf[:, :] = [-0.00219526, -0.0282857;5.01111e-06, 1.20527e-05;-2.51755e-10, -1.71267e-09] "Volume flow map coefficients: inputs speed [rpm] and pressure rise [bar], output volume flow [m3/s]";
  parameter Real eta_el = 0.87 "Electrical motor efficiency (currently not used)";
  Modelica.Thermal.FluidHeatFlow.Sources.VolumeFlow pump(T0 = system.T_ambient, m = m_coolant, medium = medium, useVolumeFlowInput = true, T0fixed = true, constantVolumeFlow = 1e-6, V_flow(start = 1e-6)) annotation(
    Placement(visible = true, transformation(origin = {30, -60}, extent = {{-40, -10}, {-20, 10}}, rotation = 0)));
  Modelica.Thermal.FluidHeatFlow.Interfaces.FlowPort_a Input(medium = medium) annotation(
    Placement(visible = true, transformation(origin = {-100, -60}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {-90, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Thermal.FluidHeatFlow.Interfaces.FlowPort_b Output(medium = medium) annotation(
    Placement(visible = true, transformation(origin = {100, -60}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {90, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Thermal.FluidHeatFlow.Sensors.RelPressureSensor relPressureSensor(medium = medium) annotation(
    Placement(transformation(origin = {-80, -90}, extent = {{10, 10}, {-10, -10}})));
  Modelica.Thermal.FluidHeatFlow.Sensors.VolumeFlowSensor volumeFlowSensor(medium = medium) annotation(
    Placement(transformation(origin = {60, -60}, extent = {{10, -10}, {-10, 10}}, rotation = -180)));
  Modelica.Blocks.Sources.RealExpression realPowerEl(y = pin_p.v*pin_p.i) annotation(
    Placement(transformation(origin = {50, 10}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Electrical.Analog.Sources.SignalCurrent currentLoss annotation(
    Placement(visible = true, transformation(origin = {60, 80}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
  Modelica.Blocks.Nonlinear.SlewRateLimiter slewRateLim(Rising = 1/t_rampup, Td = 1) annotation(
    Placement(transformation(origin = {-70, 6}, extent = {{-4, -4}, {4, 4}})));
  Modelica.Blocks.Nonlinear.Limiter limiterPressure(uMax = inf, uMin = eps) annotation(
    Placement(transformation(origin = {-56, -6}, extent = {{-4, -4}, {4, 4}})));
  Utilities.Poly2D poly2DVf(c = c_Vf) annotation(
    Placement(transformation(origin = {-30, 0}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Continuous.FirstOrder firstOrderPT1(T = 1) annotation(
    Placement(transformation(origin = {18, 10}, extent = {{10, -10}, {-10, 10}}, rotation = -0)));
  Modelica.Blocks.Nonlinear.Limiter limiterPmax(uMax = w_max, uMin = eps) annotation(
    Placement(transformation(origin = {-90, 0}, extent = {{-4, -4}, {4, 4}})));
  Modelica.Blocks.Math.Feedback feedback annotation(
    Placement(transformation(origin = {0, 40}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.RealExpression realPfunction(y = P_0 + P_1*max(slewRateLim.y, p_con) + P_2*max(slewRateLim.y, p_con)^2) annotation(
    Placement(transformation(origin = {-60, 40}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Continuous.FirstOrder firstOrderPT11(T = 1) annotation(
    Placement(transformation(origin = {-30, 40}, extent = {{-10, -10}, {10, 10}}, rotation = -0)));
  Modelica.Blocks.Math.Gain gainPatoBar(k = 1e-5) annotation(
    Placement(transformation(origin = {-80, -30}, extent = {{-6, -6}, {6, 6}}, rotation = 90)));
equation
//assert(poly2DEta.y > -eps, "Pump efficiency negative.");
//assert(volumeFlowSensor.y > -eps, "Medium flow outside feasible region for pump DC (negative).");
//*** DEFINE CONNECTIONS ***//
  connect(relPressureSensor.flowPort_b, Input) annotation(
    Line(points = {{-90, -90}, {-100, -90}, {-100, -60}}, color = {255, 0, 0}));
  connect(relPressureSensor.flowPort_a, Output) annotation(
    Line(points = {{-70, -90}, {100, -90}, {100, -60}}, color = {255, 0, 0}));
  connect(currentLoss.p, pin_p) annotation(
    Line(points = {{70, 80}, {80, 80}, {80, 100}}, color = {0, 0, 255}));
  connect(currentLoss.n, pin_n) annotation(
    Line(points = {{50, 80}, {40, 80}, {40, 100}}, color = {0, 0, 255}));
  connect(limiterPressure.y, poly2DVf.u2) annotation(
    Line(points = {{-52, -6}, {-42, -6}}, color = {0, 0, 127}));
  connect(contol_input, limiterPmax.u) annotation(
    Line(points = {{-110, 0}, {-95, 0}}, color = {0, 0, 127}));
  connect(pump.flowPort_b, volumeFlowSensor.flowPort_a) annotation(
    Line(points = {{10, -60}, {50, -60}}, color = {255, 0, 0}));
  connect(volumeFlowSensor.flowPort_b, Output) annotation(
    Line(points = {{70, -60}, {100, -60}}, color = {255, 0, 0}));
  connect(Input, pump.flowPort_a) annotation(
    Line(points = {{-100, -60}, {-10, -60}}, color = {255, 0, 0}));
  connect(firstOrderPT1.y, feedback.u2) annotation(
    Line(points = {{8, 10}, {0, 10}, {0, 32}}, color = {0, 0, 127}));
  connect(feedback.y, currentLoss.i) annotation(
    Line(points = {{10, 40}, {60, 40}, {60, 68}}, color = {0, 0, 127}));
  connect(realPowerEl.y, firstOrderPT1.u) annotation(
    Line(points = {{39, 10}, {30, 10}}, color = {0, 0, 127}));
  connect(firstOrderPT11.y, feedback.u1) annotation(
    Line(points = {{-18, 40}, {-8, 40}}, color = {0, 0, 127}));
  connect(realPfunction.y, firstOrderPT11.u) annotation(
    Line(points = {{-49, 40}, {-42, 40}}, color = {0, 0, 127}));
  connect(gainPatoBar.u, relPressureSensor.y) annotation(
    Line(points = {{-80, -38}, {-80, -78}}, color = {0, 0, 127}));
  connect(gainPatoBar.y, limiterPressure.u) annotation(
    Line(points = {{-80, -24}, {-80, -6}, {-61, -6}}, color = {0, 0, 127}));
  connect(limiterVf.y, pump.volumeFlow) annotation(
    Line(points = {{0, -34}, {0, -50}}, color = {0, 0, 127}));
  connect(poly2DVf.y, limiterVf.u) annotation(
    Line(points = {{-18, 0}, {0, 0}, {0, -26}}, color = {0, 0, 127}));
  connect(gainWmax.y, poly2DVf.u1) annotation(
    Line(points = {{-48, 6}, {-42, 6}}, color = {0, 0, 127}));
  connect(slewRateLim.y, gainWmax.u) annotation(
    Line(points = {{-66, 6}, {-56, 6}}, color = {0, 0, 127}));
  connect(limiterPmax.y, slewRateLim.u) annotation(
    Line(points = {{-86, 0}, {-80, 0}, {-80, 6}, {-74, 6}}, color = {0, 0, 127}));
protected
public
  Modelica.Blocks.Nonlinear.Limiter limiterVf(uMax = vflow_max, uMin = eps) annotation(
    Placement(transformation(origin = {0, -30}, extent = {{-4, -4}, {4, 4}}, rotation = -90)));
  Modelica.Blocks.Math.Gain gainWmax(k = w_max) annotation(
    Placement(transformation(origin = {-52, 6}, extent = {{-4, -4}, {4, 4}})));
  annotation(
    Icon(coordinateSystem(initialScale = 0.1), graphics = {Ellipse(origin = {-2, -15}, fillColor = {208, 208, 208}, fillPattern = FillPattern.Solid, lineThickness = 3, extent = {{-78, 95}, {82, -65}}), Line(origin = {40, 40}, points = {{-40, 40}, {40, -40}, {40, -40}}, thickness = 3), Line(origin = {40, -40}, points = {{-40, -40}, {40, 40}, {40, 40}}, thickness = 3)}),
    Diagram(graphics = {Bitmap(origin = {-43, -4}, extent = {{1, 0}, {-1, 0}})}),
    Documentation(info = "<html><head></head><body>
<p>Electrically driven coolant pump based on <code>Modelica.Thermal.FluidHeatFlow</code>. It uses the conditions of the outer <code>system</code>.</p>
<ul>
<li>The control input is the normalized pump speed. It is rate limited by <code>t_rampup</code> and scaled with <code>w_max</code> [rpm].</li>
<li>The volume flow follows from the map <code>c_Vf</code> as a function of speed [rpm] and the pressure rise across the pump [bar], limited to <code>vflow_max</code>.</li>
<li>The electrical power target is <code>P_0 + P_1*u + P_2*u^2</code> with <code>u = max(speed command, p_con)</code>. It is imposed on the electrical pins by the current source <code>currentLoss</code>, which is driven by the difference between target and actual power (gain 1 A/W). In steady state the drawn power is therefore slightly below the target, by the factor <code>V/(1 + V)</code> for the pin voltage <code>V</code>.</li>
<li>The electrical power is not converted into heat in the coolant, and <code>eta_el</code> is currently not used.</li>
</ul>
<h4>Connectors</h4>
<table>
<tr><td><code>Input</code>, <code>Output</code></td><td>Coolant inlet and outlet (FluidHeatFlow)</td></tr>
<tr><td><code>pin_p</code>, <code>pin_n</code></td><td>Electrical supply</td></tr>
<tr><td><code>contol_input</code></td><td>Normalised speed command [-] (1 corresponds to <code>w_max</code>)</td></tr>
</table>
</body></html>"));
end PumpElectricDCFluidHFPoly;
