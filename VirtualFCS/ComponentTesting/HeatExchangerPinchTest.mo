within VirtualFCS.ComponentTesting;

model HeatExchangerPinchTest
  "Drives HeatExchanger through the thermal pinch (air inlet temperature ramping down through the wall temperature) to check its numerical robustness when switching from cooling to heating"
  extends Modelica.Icons.Example;
  replaceable package Medium = Modelica.Media.Air.MoistAir;

  inner Modelica.Fluid.System system annotation(
    Placement(visible = true, transformation(origin = {80, 80}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));

  Modelica.Blocks.Sources.Ramp compressorOutletTemperatureRamp(
    height = -70,
    duration = 20,
    offset = 360,
    startTime = 5) annotation(
    Placement(visible = true, transformation(origin = {-110, -30}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));

  Modelica.Fluid.Sources.MassFlowSource_T source(
    redeclare package Medium = Medium,
    nPorts = 1,
    use_T_in = true,
    m_flow = 0.05) annotation(
    Placement(visible = true, transformation(origin = {-70, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Fluid.Sources.Boundary_pT sink(
    redeclare package Medium = Medium,
    nPorts = 1,
    p = system.p_ambient) annotation(
    Placement(visible = true, transformation(origin = {72, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));

  VirtualFCS.Thermal.HeatExchanger heatExchanger(
    redeclare package Medium = Medium,
    k_th = 50) annotation(
    Placement(visible = true, transformation(origin = {2, 0}, extent = {{-20, -20}, {20, 20}}, rotation = 0)));

  Modelica.Thermal.HeatTransfer.Components.HeatCapacitor wallMass(
    C = 1e6,
    T(start = 320.0, fixed = true)) annotation(
    Placement(visible = true, transformation(origin = {2, 50}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));

  Modelica.Fluid.Sensors.Temperature temperatureIn(redeclare package Medium = Medium) annotation(
    Placement(visible = true, transformation(origin = {-30, -26}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
  Modelica.Fluid.Sensors.Temperature temperatureOut(redeclare package Medium = Medium) annotation(
    Placement(visible = true, transformation(origin = {34, -26}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
equation
  connect(source.ports[1], heatExchanger.port_a) annotation(
    Line(points = {{-60, 0}, {-18, 0}}, color = {0, 127, 255}, thickness = 1));
  connect(heatExchanger.port_b, sink.ports[1]) annotation(
    Line(points = {{22, 0}, {62, 0}}, color = {0, 127, 255}, thickness = 1));
  connect(heatExchanger.heatport_a, wallMass.port) annotation(
    Line(points = {{2, 6}, {2, 40}}, color = {191, 0, 0}));
  connect(temperatureIn.port, heatExchanger.port_a) annotation(
    Line(points = {{-30, -16}, {-30, 0}, {-18, 0}}, color = {0, 127, 255}));
  connect(temperatureOut.port, heatExchanger.port_b) annotation(
    Line(points = {{34, -16}, {34, 0}, {22, 0}}, color = {0, 127, 255}));
  connect(compressorOutletTemperatureRamp.y, source.T_in) annotation(
    Line(points = {{-98, -30}, {-90, -30}, {-90, 4}, {-82, 4}}, color = {0, 0, 127}));
  annotation(
    experiment(StartTime = 0, StopTime = 60, Interval = 0.01, Tolerance = 1e-4),
    Documentation(info = "<html><body>
<p>Regression test for <a href=\"modelica://VirtualFCS.Thermal.HeatExchanger\">HeatExchanger</a> at the thermal pinch. This is the situation of the air-side heat exchanger in the fuel cell system when the compressor outlet temperature drops below the coolant temperature.</p>
<ul>
<li>Air at a constant mass flow enters the heat exchanger. Its inlet temperature ramps from 360 K down to 290 K over t = 5..25 s (a constant -3.5 K/s slew).</li>
<li>The wall is a large thermal mass that starts at 320 K. With <code>C = 1e6 J/K</code> and <code>k_th = 50 W/K</code> its time constant is 20000 s, so its temperature stays close to 320 K over the simulated 60 s while remaining a dynamic state.</li>
<li>The inlet temperature crosses the wall temperature at t &asymp; 16.4 s at a constant rate, so the exchanger switches from cooling to heating the air.</li>
</ul>
<p>The simulation is expected to run through the crossing without solver failure. The outlet temperature then always lies between the inlet and the wall temperature.</p>
</body></html>"));
end HeatExchangerPinchTest;
