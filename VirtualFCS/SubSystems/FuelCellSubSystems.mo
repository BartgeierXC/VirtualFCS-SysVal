within VirtualFCS.SubSystems;

model FuelCellSubSystems
  // System
  outer Modelica.Fluid.System system "System properties";
  // Medium declaration
  replaceable package Cathode_Medium = Modelica.Media.Air.MoistAir;
  replaceable package Anode_Medium = Modelica.Media.IdealGases.SingleGases.H2 constrainedby Modelica.Media.Interfaces.PartialSimpleIdealGasMedium;
  constant Modelica.Thermal.FluidHeatFlow.Media.Medium Coolant_Medium = Modelica.Thermal.FluidHeatFlow.Media.Water() annotation(
    Placement(visible = false, transformation(extent = {{0, 0}, {0, 0}})));
  // H2 Subsystem Parameters
  Modelica.Fluid.Interfaces.FluidPort_a H2_port_a(redeclare package Medium = Anode_Medium) annotation(
    Placement(visible = true, transformation(origin = {-50, 80}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {-70, 90}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Fluid.Interfaces.FluidPort_b H2_port_b(redeclare package Medium = Anode_Medium) annotation(
    Placement(visible = true, transformation(origin = {-66, 80}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {-90, 90}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Fluid.Interfaces.FluidPort_a air_port_a(redeclare package Medium = Cathode_Medium) annotation(
    Placement(visible = true, transformation(origin = {70, 80}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {70, 90}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Fluid.Interfaces.FluidPort_b air_port_b(redeclare package Medium = Cathode_Medium) annotation(
    Placement(visible = true, transformation(origin = {50, 80}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {90, 90}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Thermal.FluidHeatFlow.Interfaces.FlowPort_a coolant_port_a(medium = Coolant_Medium) annotation(
    Placement(visible = true, transformation(origin = {10, 80}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {-10, 90}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Thermal.FluidHeatFlow.Interfaces.FlowPort_b coolant_port_b(medium = Coolant_Medium) annotation(
    Placement(visible = true, transformation(origin = {-10, 80}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {10, 90}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  VirtualFCS.SubSystems.Hydrogen.SubSystemHydrogenTST subSystemHydrogen annotation(
    Placement(visible = true, transformation(origin = {-60, 0}, extent = {{-15, -10}, {15, 10}}, rotation = 0)));
  replaceable VirtualFCS.SubSystems.Air.SubSystemAirCMP subSystemAir annotation(
    Placement(visible = true, transformation(origin = {60, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  replaceable Cooling.SubSystemCoolingTST subSystemCooling(medium = Coolant_Medium, p_Cl_constant = false, T_Cl_constant = false, T_TST_coolant_set(displayUnit = "K"), m_coolant_int = 17, m_coolant_ext = 17, p_TST_coolant_in(displayUnit = "Pa"), G = 7300) annotation(
    Placement(transformation(extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Interfaces.PositivePin pin_p annotation(
    Placement(visible = true, transformation(origin = {20, -100}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {130, 30}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Electrical.Analog.Interfaces.NegativePin pin_n annotation(
    Placement(visible = true, transformation(origin = {-20, -100}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {130, -30}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
equation
  connect(subSystemHydrogen.pin_n, pin_n) annotation(
    Line(points = {{-62, -8}, {-62, -40}, {-20, -40}, {-20, -100}}, color = {0, 0, 255}));
  connect(subSystemCooling.pin_n, pin_n) annotation(
    Line(points = {{-4, -8}, {-6, -8}, {-6, -40}, {-20, -40}, {-20, -100}}, color = {0, 0, 255}));
  connect(subSystemAir.pin_n, pin_n) annotation(
    Line(points = {{56, -8}, {56, -40}, {-20, -40}, {-20, -100}}, color = {0, 0, 255}));
  connect(pin_p, subSystemCooling.pin_p) annotation(
    Line(points = {{20, -100}, {20, -32}, {6, -32}, {6, -8}}, color = {0, 0, 255}));
  connect(pin_p, subSystemAir.pin_p) annotation(
    Line(points = {{20, -100}, {20, -32}, {66, -32}, {66, -8}}, color = {0, 0, 255}));
  connect(subSystemHydrogen.port_H2ToStack, H2_port_a) annotation(
    Line(points = {{-66, 12}, {-64, 12}, {-64, 52}, {-50, 52}, {-50, 80}}, color = {0, 127, 255}));
  connect(subSystemHydrogen.port_StackToH2, H2_port_b) annotation(
    Line(points = {{-54, 12}, {-54, 60}, {-66, 60}, {-66, 80}}, color = {0, 127, 255}));
  connect(subSystemAir.Output, air_port_a) annotation(
    Line(points = {{54, 12}, {54, 50}, {70, 50}, {70, 80}}, color = {0, 127, 255}));
  connect(subSystemAir.Input, air_port_b) annotation(
    Line(points = {{66, 12}, {66, 60}, {50, 60}, {50, 80}}, color = {0, 127, 255}));
  connect(subSystemHydrogen.pin_p, pin_p) annotation(
    Line(points = {{-54, -8}, {-54, -32}, {20, -32}, {20, -100}}, color = {0, 0, 255}));
  connect(subSystemCooling.flowPort_a, coolant_port_b) annotation(
    Line(points = {{6, 10}, {6, 60}, {-10, 60}, {-10, 80}}, color = {255, 0, 0}));
  connect(subSystemCooling.flowPort_b, coolant_port_a) annotation(
    Line(points = {{-4, 10}, {-6, 10}, {-6, 50}, {10, 50}, {10, 80}}, color = {255, 0, 0}));
  connect(subSystemAir.heatPort_a, subSystemCooling.heatport_a) annotation(
    Line(points = {{70, 0}, {80, 0}, {80, -20}, {20, -20}, {20, 0}, {10, 0}}, color = {191, 0, 0}));
  annotation(
    Documentation(info = "<html><head></head><body>
<p>Container for the balance of plant (BoP) of a fuel cell stack: hydrogen supply with anode recirculation
(<a href=\"modelica://VirtualFCS.SubSystems.Hydrogen.SubSystemHydrogenTST\">SubSystemHydrogenTST</a>), air supply
(<code>subSystemAir</code>, replaceable, default
<a href=\"modelica://VirtualFCS.SubSystems.Air.SubSystemAirCMP\">SubSystemAirCMP</a>) and cooling loop
(<code>subSystemCooling</code>, replaceable, default
<a href=\"modelica://VirtualFCS.SubSystems.Cooling.SubSystemCoolingTST\">SubSystemCoolingTST</a>).</p>

<h4>Connectors</h4>
<table>
<tr><td><code>H2_port_a</code> / <code>H2_port_b</code></td><td>Hydrogen to / from the stack anode</td></tr>
<tr><td><code>air_port_a</code> / <code>air_port_b</code></td><td>Air to / from the stack cathode</td></tr>
<tr><td><code>coolant_port_a</code> / <code>coolant_port_b</code></td><td>Coolant to / from the stack (FluidHeatFlow, water). <code>coolant_port_a</code> is fed by <code>subSystemCooling.flowPort_b</code>.</td></tr>
<tr><td><code>pin_p</code>, <code>pin_n</code></td><td>Electrical supply of all BoP components (compressor, recirculation blower, coolant pump)</td></tr>
</table>

<p>The air-side heat exchanger (charge-air cooler) of the air subsystem is thermally coupled to the cooling
subsystem via <code>subSystemAir.heatPort_a</code> &ndash; <code>subSystemCooling.heatport_a</code>.</p>
<p>A replacement for <code>subSystemCooling</code> must accept the modifiers set here (<code>medium</code>,
<code>p_Cl_constant</code>, <code>T_Cl_constant</code>, <code>T_TST_coolant_set</code>, <code>m_coolant_int</code>,
<code>m_coolant_ext</code>, <code>p_TST_coolant_in</code>, <code>G</code>). All subsystems read their set points
from an <code>outer</code> <a href=\"modelica://VirtualFCS.Utilities.SystemControl\">SystemControl</a> instance
<code>systemControl</code>. The operating-point table must match the selected subsystem variants.</p>
</body></html>"),
    Icon(graphics = {Text(origin = {-31, -100}, textColor = {0, 0, 255}, extent = {{-105, 8}, {167, -40}}, textString = "%name"), Rectangle(extent = {{-100, 100}, {100, -100}}), Rectangle(fillColor = {0, 60, 101}, fillPattern = FillPattern.Solid, lineThickness = 1.5, extent = {{-100, 100}, {100, -100}}, radius = 35), Text(origin = {-82, 60}, textColor = {255, 255, 255}, extent = {{-22, 10}, {22, -10}}, textString = "H2"), Text(origin = {-2, 60}, textColor = {255, 255, 255}, extent = {{-22, 10}, {22, -10}}, textString = "Cool"), Text(origin = {80, 60}, textColor = {255, 255, 255}, extent = {{-22, 10}, {22, -10}}, textString = "Air")}, coordinateSystem(initialScale = 0.1)));
end FuelCellSubSystems;