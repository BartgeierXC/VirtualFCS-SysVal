within VirtualFCS.ComponentTesting;

model TestHeatRecirculation
  extends Modelica.Icons.Example;
  replaceable package Coolant_Medium = Modelica.Media.Water.ConstantPropertyLiquidWater constrainedby Modelica.Media.Interfaces.PartialMedium;
  parameter Real k = 10;
  parameter Modelica.Thermal.FluidHeatFlow.Media.Medium medium = Modelica.Thermal.FluidHeatFlow.Media.Water();
  parameter Modelica.Units.SI.Temperature TAmb = system.T_ambient;
  inner Modelica.Fluid.System system(energyDynamics = Modelica.Fluid.Types.Dynamics.FixedInitial, p_start(displayUnit = "Pa")) annotation(
    Placement(visible = true, transformation(origin = {-90, -90}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Thermal.HeatTransfer.Components.HeatCapacitor heatCapacitor(C = 40*110, T(fixed = true, start = system.T_start), der_T(fixed = false)) annotation(
    Placement(visible = true, transformation(origin = {-40, 102}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor tempQpos annotation(
    Placement(visible = true, transformation(origin = {-10, 92}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow heatFlowPos annotation(
    Placement(visible = true, transformation(origin = {-80, 82}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.RealExpression qPos(y = 1e4) annotation(
    Placement(visible = true, transformation(origin = {-120, 82}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Thermal.HeatTransfer.Components.ThermalConductor thermalConductor(G = 10000) annotation(
    Placement(visible = true, transformation(origin = {-40, 70}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Thermal.FluidHeatFlow.Sources.VolumeFlow pump(T0 = TAmb, constantVolumeFlow = 0, m = 0, medium = medium, useVolumeFlowInput = true) annotation(
    Placement(visible = true, transformation(origin = {0, 0}, extent = {{-40, -10}, {-20, 10}}, rotation = 0)));
  Modelica.Thermal.FluidHeatFlow.Components.Pipe pipeQpos(T0 = TAmb, T0fixed = true, V_flowLaminar = 0.1, V_flowNominal = 1, dpLaminar(displayUnit = "Pa") = 0.1, dpNominal(displayUnit = "Pa") = 1, h_g = 0, m = 0.1, medium = medium, useHeatPort = true) annotation(
    Placement(visible = true, transformation(origin = {0, 0}, extent = {{0, 10}, {20, -10}}, rotation = 0)));
  Modelica.Thermal.FluidHeatFlow.Sensors.RelTemperatureSensor relTemperatureSensor(medium = medium) annotation(
    Placement(visible = true, transformation(origin = {10, -32}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
  Modelica.Thermal.FluidHeatFlow.Components.OpenTank openTank(ATank = 0.1, T0 = system.T_ambient, hTank = 0.5, level(start = 0.25), medium = medium, pAmbient = system.p_ambient) annotation(
    Placement(visible = true, transformation(origin = {-130, -90}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Thermal.FluidHeatFlow.Components.Pipe pipeQneg(T0 = TAmb, T0fixed = true, V_flowLaminar = 0.1, V_flowNominal = 1, dpLaminar(displayUnit = "Pa") = 0.1, dpNominal(displayUnit = "Pa") = 1, h_g = 0, m = 0.1, medium = medium, useHeatPort = true) annotation(
    Placement(visible = true, transformation(origin = {40, 0}, extent = {{0, 10}, {20, -10}}, rotation = 0)));
  Modelica.Blocks.Sources.RealExpression qNeg(y = -1000) annotation(
    Placement(visible = true, transformation(origin = {-4, 66}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow heatFlowNeg annotation(
    Placement(visible = true, transformation(origin = {30, 70}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Thermal.HeatTransfer.Components.ThermalConductor thermalConductor2(G = 10000) annotation(
    Placement(visible = true, transformation(origin = {50, 34}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Thermal.HeatTransfer.Components.HeatCapacitor heatCapacitor2(C = 40*110, T(fixed = true, start = system.T_start), der_T(fixed = false)) annotation(
    Placement(visible = true, transformation(origin = {58, 96}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor tempQneg annotation(
    Placement(visible = true, transformation(origin = {86, 70}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Thermal.FluidHeatFlow.Sensors.TemperatureSensor tempPump(medium = medium) annotation(
    Placement(visible = true, transformation(origin = {-20, -30}, extent = {{10, -10}, {-10, 10}}, rotation = 90)));
  Modelica.Thermal.FluidHeatFlow.Sensors.TemperatureSensor tempHeat(medium = medium) annotation(
    Placement(visible = true, transformation(origin = {40, -30}, extent = {{10, -10}, {-10, 10}}, rotation = 90)));
  Modelica.Thermal.FluidHeatFlow.Sensors.TemperatureSensor tempCool(medium = medium) annotation(
    Placement(visible = true, transformation(origin = {70, -30}, extent = {{10, -10}, {-10, 10}}, rotation = 90)));
  Modelica.Blocks.Sources.Constant constDT(k = 1) annotation(
    Placement(visible = true, transformation(origin = {-110, 30}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Thermal.FluidHeatFlow.Sources.VolumeFlow pumpCool(T0 = TAmb, constantVolumeFlow = 1e-2, medium = medium, useVolumeFlowInput = true) annotation(
    Placement(visible = true, transformation(origin = {20, -90}, extent = {{-40, -10}, {-20, 10}}, rotation = 180)));
  Modelica.Thermal.FluidHeatFlow.Components.Pipe pipeCoolHot(T0 = TAmb, T0fixed = false, V_flowLaminar = 0.1, V_flowNominal = 1, dpLaminar(displayUnit = "Pa") = 0.09999999999999999, dpNominal(displayUnit = "Pa") = 1, h_g = 0, medium = medium, useHeatPort = true) annotation(
    Placement(visible = true, transformation(origin = {40, -60}, extent = {{0, 10}, {20, -10}}, rotation = 180)));
  Modelica.Thermal.FluidHeatFlow.Components.Pipe pipeCoolCold(T0 = TAmb, T0fixed = true, V_flowLaminar = 0.1, V_flowNominal = 1, dpLaminar(displayUnit = "Pa") = 0.09999999999999999, dpNominal(displayUnit = "Pa") = 1, h_g = 0, medium = medium, useHeatPort = true) annotation(
    Placement(visible = true, transformation(origin = {10, -90}, extent = {{0, -10}, {20, 10}}, rotation = -180)));
  Modelica.Thermal.FluidHeatFlow.Sources.Ambient ambientIn(constantAmbientPressure = system.p_ambient, constantAmbientTemperature(displayUnit = "K") = TAmb - 20, medium = medium) annotation(
    Placement(visible = true, transformation(origin = {20, -90}, extent = {{60, -10}, {80, 10}}, rotation = 0)));
  Modelica.Thermal.FluidHeatFlow.Sources.Ambient ambientOut(constantAmbientPressure = system.p_ambient, constantAmbientTemperature = TAmb, medium = medium) annotation(
    Placement(visible = true, transformation(origin = {20, -90}, extent = {{-60, -10}, {-80, 10}}, rotation = 0)));
  Modelica.Thermal.FluidHeatFlow.Sensors.TemperatureSensor tempCoolCold(medium = medium) annotation(
    Placement(visible = true, transformation(origin = {20, -110}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Thermal.FluidHeatFlow.Sensors.TemperatureSensor tempCoolWarm(medium = medium) annotation(
    Placement(visible = true, transformation(origin = {-20, -110}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Thermal.FluidHeatFlow.Sensors.TemperatureSensor tempCoolOut(medium = medium) annotation(
    Placement(visible = true, transformation(origin = {-70, -60}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.Constant constCoolTemp(k = 333) annotation(
    Placement(visible = true, transformation(origin = {120, -110}, extent = {{-40, 20}, {-20, 0}}, rotation = 180)));
  Modelica.Blocks.Continuous.LimPID piCool(controllerType = Modelica.Blocks.Types.SimpleController.PI, yMax = 0, yMin = -1) annotation(
    Placement(visible = true, transformation(origin = {90, -120}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
  Modelica.Blocks.Math.Gain gain(k = -1) annotation(
    Placement(visible = true, transformation(origin = {62, -120}, extent = {{6, -6}, {-6, 6}}, rotation = 0)));
  Modelica.Thermal.HeatTransfer.Components.ThermalConductor thermalConductorHex(G = 10000) annotation(
    Placement(visible = true, transformation(origin = {14, -74}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Continuous.LimPID piDT(controllerType = Modelica.Blocks.Types.SimpleController.PI, yMax = -1e-6, yMin = -1) annotation(
    Placement(visible = true, transformation(origin = {-70, 30}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Math.Gain gain1(k = -1) annotation(
    Placement(visible = true, transformation(origin = {-42, 30}, extent = {{-6, -6}, {6, 6}}, rotation = 0)));
equation
  connect(tempQpos.port, heatCapacitor.port) annotation(
    Line(points = {{-20, 92}, {-30, 92}, {-30, 86}, {-40, 86}, {-40, 92}}, color = {191, 0, 0}));
  connect(qPos.y, heatFlowPos.Q_flow) annotation(
    Line(points = {{-109, 82}, {-90, 82}}, color = {0, 0, 127}));
  connect(heatFlowPos.port, thermalConductor.port_a) annotation(
    Line(points = {{-70, 82}, {-60, 82}, {-60, 86}, {-40, 86}, {-40, 80}}, color = {191, 0, 0}));
  connect(heatCapacitor.port, thermalConductor.port_a) annotation(
    Line(points = {{-40, 92}, {-40, 80}}, color = {191, 0, 0}));
  connect(pump.flowPort_b, pipeQpos.flowPort_a) annotation(
    Line(points = {{-20, 0}, {0, 0}}, color = {255, 0, 0}));
  connect(openTank.flowPort, pump.flowPort_a) annotation(
    Line(points = {{-130, -100}, {-130, 0}, {-40, 0}}, color = {255, 0, 0}));
  connect(pipeQpos.flowPort_b, pipeQneg.flowPort_a) annotation(
    Line(points = {{20, 0}, {40, 0}}, color = {255, 0, 0}));
  connect(thermalConductor2.port_b, pipeQneg.heatPort) annotation(
    Line(points = {{50, 24}, {50, 10}}, color = {191, 0, 0}));
  connect(thermalConductor.port_b, pipeQpos.heatPort) annotation(
    Line(points = {{-40, 60}, {-40, 40}, {10, 40}, {10, 10}}, color = {191, 0, 0}));
  connect(qNeg.y, heatFlowNeg.Q_flow) annotation(
    Line(points = {{8, 66}, {12, 66}, {12, 70}, {20, 70}}, color = {0, 0, 127}));
  connect(heatFlowNeg.port, heatCapacitor2.port) annotation(
    Line(points = {{40, 70}, {58, 70}, {58, 86}}, color = {191, 0, 0}));
  connect(heatFlowNeg.port, tempQneg.port) annotation(
    Line(points = {{40, 70}, {76, 70}}, color = {191, 0, 0}));
  connect(heatFlowNeg.port, thermalConductor2.port_a) annotation(
    Line(points = {{40, 70}, {58, 70}, {58, 54}, {50, 54}, {50, 44}}, color = {191, 0, 0}));
  connect(tempPump.flowPort, pump.flowPort_b) annotation(
    Line(points = {{-20, -20}, {-20, 0}}, color = {255, 0, 0}));
  connect(tempHeat.flowPort, pipeQneg.flowPort_a) annotation(
    Line(points = {{40, -20}, {40, 0}}, color = {255, 0, 0}));
  connect(tempCool.flowPort, pipeQneg.flowPort_b) annotation(
    Line(points = {{70, -20}, {70, 0}, {60, 0}}, color = {255, 0, 0}));
  connect(relTemperatureSensor.flowPort_a, pipeQpos.flowPort_b) annotation(
    Line(points = {{20, -32}, {20, 0}}, color = {255, 0, 0}));
  connect(relTemperatureSensor.flowPort_b, pipeQpos.flowPort_a) annotation(
    Line(points = {{0, -32}, {0, 0}}, color = {255, 0, 0}));
  connect(pipeCoolCold.flowPort_a, pumpCool.flowPort_b) annotation(
    Line(points = {{10, -90}, {40, -90}}, color = {255, 0, 0}));
  connect(pumpCool.flowPort_a, ambientIn.flowPort) annotation(
    Line(points = {{60, -90}, {80, -90}}, color = {255, 0, 0}));
  connect(ambientOut.flowPort, pipeCoolCold.flowPort_b) annotation(
    Line(points = {{-40, -90}, {-10, -90}}, color = {255, 0, 0}));
  connect(pipeCoolHot.flowPort_b, pump.flowPort_a) annotation(
    Line(points = {{20, -60}, {-60, -60}, {-60, 0}, {-40, 0}}, color = {255, 0, 0}));
  connect(pipeQneg.flowPort_b, pipeCoolHot.flowPort_a) annotation(
    Line(points = {{60, 0}, {80, 0}, {80, -60}, {40, -60}}, color = {255, 0, 0}));
  connect(tempCoolCold.flowPort, pipeCoolCold.flowPort_a) annotation(
    Line(points = {{20, -100}, {20, -90}, {10, -90}}, color = {255, 0, 0}));
  connect(tempCoolWarm.flowPort, pipeCoolCold.flowPort_b) annotation(
    Line(points = {{-20, -100}, {-20, -90}, {-10, -90}}, color = {255, 0, 0}));
  connect(tempCoolOut.flowPort, pipeCoolHot.flowPort_b) annotation(
    Line(points = {{-60, -60}, {20, -60}}, color = {255, 0, 0}));
  connect(constCoolTemp.y, piCool.u_s) annotation(
    Line(points = {{140, -120}, {102, -120}}, color = {0, 0, 127}));
  connect(tempCoolOut.y, piCool.u_m) annotation(
    Line(points = {{-80, -60}, {-150, -60}, {-150, -140}, {90, -140}, {90, -132}}, color = {0, 0, 127}));
  connect(piCool.y, gain.u) annotation(
    Line(points = {{80, -120}, {69, -120}}, color = {0, 0, 127}));
  connect(gain.y, pumpCool.volumeFlow) annotation(
    Line(points = {{55, -120}, {50, -120}, {50, -100}}, color = {0, 0, 127}));
  connect(pipeCoolCold.heatPort, thermalConductorHex.port_a) annotation(
    Line(points = {{0, -80}, {0, -74}, {4, -74}}, color = {191, 0, 0}));
  connect(thermalConductorHex.port_b, pipeCoolHot.heatPort) annotation(
    Line(points = {{24, -74}, {30, -74}, {30, -70}}, color = {191, 0, 0}));
  connect(constDT.y, piDT.u_s) annotation(
    Line(points = {{-99, 30}, {-83, 30}}, color = {0, 0, 127}));
  connect(relTemperatureSensor.y, piDT.u_m) annotation(
    Line(points = {{10, -42}, {10, -44}, {-70, -44}, {-70, 18}}, color = {0, 0, 127}));
  connect(piDT.y, gain1.u) annotation(
    Line(points = {{-58, 30}, {-50, 30}}, color = {0, 0, 127}));
  connect(gain1.y, pump.volumeFlow) annotation(
    Line(points = {{-36, 30}, {-30, 30}, {-30, 10}}, color = {0, 0, 127}));
  annotation(
    Documentation(info = "<html><head></head><body>
<p>Stand-alone test of a heated and cooled water loop built from MSL FluidHeatFlow components: two heat sources (+10 kW and -1 kW) on thermal masses, an open tank, a cooling circuit with ambient boundaries and PI-controlled pumps. It uses no VirtualFCS components.</p>
</body></html>"),
    experiment(StartTime = 0, StopTime = 100, Tolerance = 1e-06, Interval = 1));
end TestHeatRecirculation;
