within VirtualFCS.ComponentTesting;

model ValveCompressibleBurkert2671DN50Test
  "ValveCompressible with Bürkert Type 2671 DN50 Kv characteristic"
  extends Modelica.Icons.Example;
  inner Modelica.Fluid.System system annotation(
    Placement(transformation(origin = {90, 90}, extent = {{-10, -10}, {10, 10}})));
  replaceable package Medium = Modelica.Media.Air.MoistAir(Temperature(start = system.T_start), AbsolutePressure(start = system.p_start));
  parameter Modelica.Units.SI.Pressure dp_nominal = 2e4 "Nominal pressure drop";
  parameter Modelica.Units.SI.MassFlowRate m_flow_nominal = 0.1 "Nominal mass flow rate";
  parameter Real Kv_full(unit = "m3/h") = 193.5 "Fully open Kv of DN50 Type 2671";
  Real rc = Fluid.ValveCharacteristics.burkert2671_DN50(rampOpening.y) "Relative flow coefficient from datasheet table";
  Real Kv_pos(unit = "m3/h") = rc*Kv_full "Interpolated Kv at current opening";
  Modelica.Fluid.Sources.Boundary_pT airSource(redeclare package Medium = Medium, nPorts = 1, p = system.p_ambient + dp_nominal, T = system.T_ambient) annotation(
    Placement(transformation(origin = {-70, 0}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Fluid.Sources.Boundary_pT airSink(redeclare package Medium = Medium, nPorts = 1, p = system.p_ambient, T = system.T_ambient) annotation(
    Placement(transformation(origin = {70, 0}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Fluid.Valves.ValveCompressible valve(redeclare package Medium = Medium, CvData = Modelica.Fluid.Types.CvTypes.Kv, Kv = Kv_full, dp_nominal = dp_nominal, m_flow_nominal = m_flow_nominal, p_nominal = system.p_ambient + dp_nominal, filteredOpening = false, show_T = false, show_V_flow = false, redeclare function valveCharacteristic = VirtualFCS.Fluid.ValveCharacteristics.burkert2671_DN50) annotation(
    Placement(transformation(origin = {0, 0}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.Ramp rampOpening(height = 1, duration = 10, offset = 0, startTime = 0) annotation(
    Placement(transformation(origin = {0, 50}, extent = {{-10, -10}, {10, 10}})));
equation
  connect(airSource.ports[1], valve.port_a) annotation(
    Line(points = {{-60, 0}, {-10, 0}}, color = {0, 127, 255}));
  connect(valve.port_b, airSink.ports[1]) annotation(
    Line(points = {{10, 0}, {60, 0}}, color = {0, 127, 255}));
  connect(rampOpening.y, valve.opening) annotation(
    Line(points = {{11, 50}, {0, 50}, {0, 8}}, color = {0, 0, 127}));
  annotation(
    experiment(StopTime = 10, Interval = 0.05, Tolerance = 1e-6),
    Documentation(info = "<html>
<p>Ramps disc opening from 0 to 1 on a DN50 Bürkert 2671 characteristic.
Plot <code>rc</code> or <code>Kv_pos</code> versus <code>rampOpening.y</code> against DS2671 section 5.3.</p>
</html>"));
end ValveCompressibleBurkert2671DN50Test;
