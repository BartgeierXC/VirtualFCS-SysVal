within VirtualFCS.ComponentTesting;

model TestAirSubsystem "Open-loop test of the air subsystem (CMP)"
  extends Modelica.Icons.Example;
  import ModelicaServices.Machine.eps;
  import ModelicaServices.Machine.inf;
  replaceable package Cathode_Medium = Modelica.Media.Air.MoistAir;
  inner Modelica.Fluid.System system(allowFlowReversal = false, m_flow_start = system.m_flow_small, dp_small(displayUnit = "Pa") = 10, m_flow_small = 1e-3, p_ambient = 94500, T_ambient = 298.15)  annotation(
    Placement(visible = true, transformation(origin = {-90, -90}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  inner Utilities.SystemControl systemControl annotation(
    Placement(transformation(origin = {90, 90}, extent = {{-10, -10}, {10, 10}})));
  
  constant Modelica.Thermal.FluidHeatFlow.Media.Medium Coolant_Medium = Modelica.Thermal.FluidHeatFlow.Media.Water();
  parameter Real N_FC_stack = 275;
  Modelica.Units.SI.Current I = OpCons[1].y;
  Real T_Si_C = temperature_Si.T - 273.15;
  Real T_So_C = temperature_So.T - 273.15;
  
  Real T_CMP_o = subSystemAirTST.tempCmpOut.T - 273.15;
  //  Modelica.Units.SI.MolarFlowRate nf_H2O_S_Ein = abs(subSystemAirTST.Output.m_flow*subSystemAirTST.Output.Xi_outflow[Cathode_Medium.Water]/Cathode_Medium.MMX[Cathode_Medium.Water]);
  Modelica.Units.SI.MolarFlowRate nf_H2O_prod = I*N_FC_stack/(Modelica.Constants.F*2);
  Modelica.Units.SI.MassFlowRate mf_H2O_S_Ein = x_w_Si * mf_Si;
  Modelica.Units.SI.MassFlowRate mf_H2O_prod = nf_H2O_prod*Cathode_Medium.steam.MM;
  Modelica.Units.SI.MassFlowRate mf_Si = OpCons[10].y/3600;
  Modelica.Units.SI.MassFlowRate mf_So = mf_Si - I*N_FC_stack*Modelica.Media.IdealGases.Common.SingleGasesData.O2.MM/(Modelica.Constants.F*4) + mf_H2O_prod annotation(
    Placement(visible = false, transformation(extent = {{0, 0}, {0, 0}})));
  Real x_w_Si = Cathode_Medium.massFraction_pTphi(real_p_Si.y, Modelica.Units.Conversions.from_degC(OpCons[7].y), phi_Si_set);
  Real x_w_So = (x_w_Si * mf_Si + mf_H2O_prod) / mf_So;
  Real phi_Si_set = OpCons[8].y/100;
  Real phi_Si_dif = phi_Si_set - Cathode_Medium.relativeHumidity_pTX(real_p_Si.y, Modelica.Units.Conversions.from_degC(OpCons[7].y), {x_w_Si, 1-x_w_Si});
  Real phi_Si = Cathode_Medium.relativeHumidity_pTX(subSystemAirTST.Output.p, temperature_Si.T, subSystemAirTST.Output.Xi_outflow);
  Real phi_So = Cathode_Medium.relativeHumidity_pTX(subSystemAirTST.Input.p, temperature_So.T, {x_w_So, 1-x_w_So});
  Modelica.Electrical.Analog.Sources.ConstantVoltage constantVoltage(V = 336) annotation(
    Placement(transformation(origin = {0, -60}, extent = {{10, -10}, {-10, 10}}, rotation = -0)));
  Modelica.Electrical.Analog.Basic.Ground ground annotation(
    Placement(transformation(origin = {-20, -70}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.RealExpression real_p_Si(y = max(system.p_ambient, Modelica.Units.Conversions.from_bar(OpCons[9].y)))  annotation(
    Placement(transformation(origin = {-90, 58}, extent = {{-10, -10}, {10, 10}})));
  SubSystems.Air.SubSystemAirCMP subSystemAirTST(k_th = 500)  annotation(
    Placement(transformation(extent = {{-10, -10}, {10, 10}})));
  Modelica.Fluid.Sources.Boundary_pT AirSink(nPorts = 1, use_p_in = true, use_T_in = false, redeclare package Medium = Cathode_Medium)  annotation(
    Placement(transformation(origin = {-50, 50}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.RealExpression real_mf_So(y = mf_So) annotation(
    Placement(transformation(origin = {90, 64}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Blocks.Sources.RealExpression real_T_So(y = Modelica.Units.Conversions.from_degC(OpCons[11].y)) annotation(
    Placement(transformation(origin = {90, 50}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Blocks.Sources.RealExpression real_X1_So(y = x_w_So) annotation(
    Placement(transformation(origin = {90, 34}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Blocks.Sources.RealExpression real_X2_So(y = 1- x_w_So) annotation(
    Placement(transformation(origin = {90, 20}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Blocks.Sources.RealExpression real_T_Cl(y = max(1 + system.T_ambient, Modelica.Units.Conversions.from_degC(OpCons[12].y))) annotation(
    Placement(transformation(origin = {130, -26}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Blocks.Sources.CombiTimeTable opCons(extrapolation = Modelica.Blocks.Types.Extrapolation.HoldLastPoint, fileName = Modelica.Utilities.Files.loadResource("modelica://VirtualFCS.Resources.LuT/OpCons_data.txt"), smoothness = Modelica.Blocks.Types.Smoothness.ConstantSegments, table = [0, 0, 180000, 150000, 1.5, 1.8, 0, 0, 180000, 150000, 1.5, 1.8, 0], tableName = "op_cons", tableOnFile = true, verboseRead = false) annotation(
    Placement(transformation(origin = {-90, 90}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Continuous.FirstOrder OpCons[12](each T = 1e-3, each y_start = eps) annotation(
    Placement(transformation(origin = {-60, 90}, extent = {{-6, -6}, {6, 6}})));
  Modelica.Fluid.Sensors.Temperature temperature_Si(redeclare package Medium = Cathode_Medium)  annotation(
    Placement(transformation(origin = {-6, 60}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Fluid.Sensors.Temperature temperature_So(redeclare package Medium = Cathode_Medium) annotation(
    Placement(transformation(origin = {6, 90}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Fluid.Sources.MassFlowSource_T AirSource(use_m_flow_in = true, use_T_in = true, use_X_in = true, redeclare package Medium = Cathode_Medium, nPorts = 1)  annotation(
    Placement(transformation(origin = {50, 50}, extent = {{10, -10}, {-10, 10}}, rotation = -0)));
  Modelica.Thermal.FluidHeatFlow.Components.Pipe pipeHeatEx(T0 = system.T_ambient, T0fixed = true, V_flow(start = 1e-6), V_flowLaminar = pipeHeatEx.V_flowNominal/10, V_flowNominal = 1, dpLaminar = pipeHeatEx.dpNominal/10, dpNominal(displayUnit = "kPa") = 1000, h_g = 0, m = 1e-3, medium = Coolant_Medium, useHeatPort = true) annotation(
    Placement(transformation(origin = {28, 8.88178e-16}, extent = {{-8, 8}, {8, -8}}, rotation = 90)));
  Modelica.Thermal.FluidHeatFlow.Sources.VolumeFlow volumeFlow(m = 1, T0 = system.T_ambient, useVolumeFlowInput = false, constantVolumeFlow(displayUnit = "l/s") = 0.0026666666666666666, medium = Coolant_Medium)  annotation(
    Placement(transformation(origin = {50, -20}, extent = {{10, 10}, {-10, -10}}, rotation = -0)));
  Modelica.Thermal.FluidHeatFlow.Sources.Ambient ambient(medium = Coolant_Medium)  annotation(
    Placement(transformation(origin = {50, 20}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Thermal.FluidHeatFlow.Sources.Ambient coolantSource(usePressureInput = false, useTemperatureInput = true, constantAmbientPressure = system.p_ambient, medium = Coolant_Medium)  annotation(
    Placement(transformation(origin = {90, -20}, extent = {{-10, -10}, {10, 10}})));
equation
  assert(phi_Si_dif > 1e-3, "Incorrect x_w calculation!", AssertionLevel.warning);
  connect(constantVoltage.n, ground.p) annotation(
    Line(points = {{-10, -60}, {-20, -60}}, color = {0, 0, 255}));
  connect(constantVoltage.n, subSystemAirTST.pin_n) annotation(
    Line(points = {{-10, -60}, {-4, -60}, {-4, -8}}, color = {0, 0, 255}));
  connect(constantVoltage.p, subSystemAirTST.pin_p) annotation(
    Line(points = {{10, -60}, {6, -60}, {6, -8}}, color = {0, 0, 255}));
  connect(AirSink.ports[1], subSystemAirTST.Output) annotation(
    Line(points = {{-40, 50}, {-6, 50}, {-6, 12}}, color = {0, 127, 255}));
  connect(opCons.y, OpCons.u) annotation(
    Line(points = {{-79, 90}, {-68, 90}}, color = {0, 0, 127}, thickness = 0.5));
  connect(real_p_Si.y, AirSink.p_in) annotation(
    Line(points = {{-78, 58}, {-62, 58}}, color = {0, 0, 127}));
  connect(temperature_Si.port, subSystemAirTST.Output) annotation(
    Line(points = {{-6, 50}, {-6, 12}}, color = {0, 127, 255}));
  connect(temperature_So.port, subSystemAirTST.Input) annotation(
    Line(points = {{6, 80}, {6, 12}}, color = {0, 127, 255}));
  connect(AirSource.ports[1], subSystemAirTST.Input) annotation(
    Line(points = {{40, 50}, {6, 50}, {6, 12}}, color = {0, 127, 255}));
  connect(real_T_So.y, AirSource.T_in) annotation(
    Line(points = {{80, 50}, {70, 50}, {70, 54}, {62, 54}}, color = {0, 0, 127}));
  connect(real_mf_So.y, AirSource.m_flow_in) annotation(
    Line(points = {{80, 64}, {70, 64}, {70, 58}, {60, 58}}, color = {0, 0, 127}));
  connect(real_X1_So.y, AirSource.X_in[1]) annotation(
    Line(points = {{80, 34}, {70, 34}, {70, 46}, {62, 46}}, color = {0, 0, 127}));
  connect(real_X2_So.y, AirSource.X_in[2]) annotation(
    Line(points = {{80, 20}, {70, 20}, {70, 46}, {62, 46}}, color = {0, 0, 127}));
  connect(pipeHeatEx.heatPort, subSystemAirTST.heatPort_a) annotation(
    Line(points = {{20, 0}, {10, 0}}, color = {191, 0, 0}));
  connect(volumeFlow.flowPort_b, pipeHeatEx.flowPort_a) annotation(
    Line(points = {{40, -20}, {28, -20}, {28, -8}}, color = {255, 0, 0}));
  connect(ambient.flowPort, pipeHeatEx.flowPort_b) annotation(
    Line(points = {{40, 20}, {28, 20}, {28, 8}}, color = {255, 0, 0}));
  connect(coolantSource.flowPort, volumeFlow.flowPort_a) annotation(
    Line(points = {{80, -20}, {60, -20}}, color = {255, 0, 0}));
  connect(real_T_Cl.y, coolantSource.ambientTemperature) annotation(
    Line(points = {{120, -26}, {100, -26}}, color = {0, 0, 127}));
  annotation(
    Diagram,
    Icon,
    Documentation(info = "<html><head></head><body>
<p>Open-loop test of <a href=\"modelica://VirtualFCS.SubSystems.Air.SubSystemAirCMP\">SubSystemAirCMP</a>. The stack is replaced by boundaries: the cathode exhaust mass flow, temperature and humidity are computed from the current and the air flow by a molar balance (O2 consumption, product water). The charge-air cooler is coupled to a coolant pipe with prescribed inlet temperature. The subsystem itself reads its set points from the inner <code>systemControl</code>, which needs a table in the SystemControl layout.</p>
<h4>Operating-point input</h4>
<p>Operating points are read from the text table <code>op_cons</code> in <code>OpCons_data.txt</code>, which is a variable interface file (see <a href=\"modelica://VirtualFCS.Utilities.SystemControl\">SystemControl</a>, &quot;Operating-point input&quot;). Its column layout must match this model; a dedicated file can be set via <code>fileName</code>. Expected data columns (after the time column):</p>
<table>
<tr><td>1</td><td>Stack current [A]</td></tr>
<tr><td>2&ndash;6</td><td>Not used</td></tr>
<tr><td>7</td><td>Air temperature at stack inlet [&deg;C]</td></tr>
<tr><td>8</td><td>Relative humidity at stack inlet [%]</td></tr>
<tr><td>9</td><td>Pressure at stack inlet [bar]</td></tr>
<tr><td>10</td><td>Air mass flow [kg/h]</td></tr>
<tr><td>11</td><td>Cathode exhaust temperature [&deg;C]</td></tr>
<tr><td>12</td><td>Coolant temperature [&deg;C]</td></tr>
</table>
</body></html>"),
    experiment(StartTime = 0, StopTime = 3600, Tolerance = 0.0001, Interval = 1),
    __OpenModelica_commandLineOptions = "--matchingAlgorithm=PFPlusExt --indexReductionMethod=dynamicStateSelection -d=initialization,NLSanalyticJacobian -d=backenddaeinfo,bltdump",
    __OpenModelica_simulationFlags(cpu = "()", lv = "LOG_STDOUT,LOG_ASSERT,LOG_STATS", s = "dassl",variableFilter = ".*"));
end TestAirSubsystem;
