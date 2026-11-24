within VirtualFCS.ComponentTesting;

model HeatExchangerTest "Simple model to test the HeatExchanger model"
  extends Modelica.Icons.Example;
  replaceable package Medium =Modelica.Media.Air.MoistAir;

  inner Modelica.Fluid.System system annotation(
    Placement(visible = true, transformation(origin = {90, 90}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));

  Modelica.Fluid.Sources.MassFlowSource_T source(
    redeclare package Medium = Medium,
    nPorts = 1,
    use_T_in = true, use_m_flow_in = true, m_flow = 0.05) annotation(
    Placement(visible = true, transformation(origin = {-70, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Fluid.Sources.Boundary_pT sink(
    redeclare package Medium = Medium,
    nPorts = 1,
    p = system.p_ambient + 1000) annotation(
    Placement(visible = true, transformation(origin = {72, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
  VirtualFCS.Thermal.HeatExchanger heatExchanger(
    redeclare package Medium = Medium,
    k_th = 500) annotation(
    Placement(visible = true, transformation(origin = {2, 0}, extent = {{-20, -20}, {20, 20}}, rotation = 0)));
  Modelica.Fluid.Sensors.Temperature temperatureIn(redeclare package Medium = Medium) annotation(
    Placement(visible = true, transformation(origin = {-30, -26}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
  Modelica.Fluid.Sensors.Temperature temperatureOut(redeclare package Medium = Medium) annotation(
    Placement(visible = true, transformation(origin = {34, -26}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature prescribedTemperature annotation(
    Placement(transformation(origin = {-30, 50}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.Ramp rampMfin(duration = 20, height = 0.05, startTime = 10, offset = 0.01) annotation(
    Placement(transformation(origin = {-110, 10}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.Sine sineTIn(amplitude = 50, f = 1/10, offset = system.T_ambient + 50)  annotation(
    Placement(transformation(origin = {-110, -30}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.Sine sineTCool(amplitude = 50, f = 1/15, offset = system.T_ambient + 40) annotation(
    Placement(transformation(origin = {-110, 50}, extent = {{-10, -10}, {10, 10}})));
equation
  connect(source.ports[1], heatExchanger.port_a) annotation(
    Line(points = {{-60, 0}, {-18, 0}}, color = {0, 127, 255}, thickness = 1));
  connect(heatExchanger.port_b, sink.ports[1]) annotation(
    Line(points = {{22, 0}, {62, 0}}, color = {0, 127, 255}, thickness = 1));
  connect(temperatureIn.port, heatExchanger.port_a) annotation(
    Line(points = {{-30, -16}, {-30, 0}, {-18, 0}}, color = {0, 127, 255}));
  connect(temperatureOut.port, heatExchanger.port_b) annotation(
    Line(points = {{34, -16}, {34, 0}, {22, 0}}, color = {0, 127, 255}));
  connect(prescribedTemperature.port, heatExchanger.heatport_a) annotation(
    Line(points = {{-20, 50}, {2, 50}, {2, 6}}, color = {191, 0, 0}));
  connect(rampMfin.y, source.m_flow_in) annotation(
    Line(points = {{-98, 10}, {-89, 10}, {-89, 8}, {-80, 8}}, color = {0, 0, 127}));
  connect(sineTIn.y, source.T_in) annotation(
    Line(points = {{-98, -30}, {-90, -30}, {-90, 4}, {-82, 4}}, color = {0, 0, 127}));
  connect(sineTCool.y, prescribedTemperature.T) annotation(
    Line(points = {{-98, 50}, {-42, 50}}, color = {0, 0, 127}));
  annotation(
    Documentation(info = "<html><head></head><body>
<p>Test of <a href=\"modelica://VirtualFCS.Thermal.HeatExchanger\">HeatExchanger</a> with moist air: sinusoidal inlet temperature, sinusoidal prescribed wall temperature and a ramped mass flow.</p>
</body></html>"),
    experiment(StopTime = 120, Interval = 0.2, Tolerance = 1e-06));
end HeatExchangerTest;