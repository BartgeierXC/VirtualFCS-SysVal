within VirtualFCS.ComponentTesting;

model TestFuelCell "Fuel cell stack operated with boundary conditions from a time table"
  extends Modelica.Icons.Example;
  import Modelica.Constants.F;
  import ModelicaServices.Machine.eps;
  replaceable package Anode_Medium = Modelica.Media.IdealGases.SingleGases.H2;
  replaceable package Cathode_Medium = Modelica.Media.Air.MoistAir;
  parameter Modelica.Thermal.FluidHeatFlow.Media.Medium Coolant_Medium = Modelica.Thermal.FluidHeatFlow.Media.Water();
  constant Modelica.Media.IdealGases.Common.DataRecord oxygen = Modelica.Media.IdealGases.Common.SingleGasesData.O2;
  constant Modelica.Media.IdealGases.Common.DataRecord nitrogen = Modelica.Media.IdealGases.Common.SingleGasesData.N2;
  constant Modelica.Media.IdealGases.Common.DataRecord hydrogen = Modelica.Media.IdealGases.Common.SingleGasesData.H2;
  constant Modelica.Media.IdealGases.Common.DataRecord steam = Modelica.Media.IdealGases.Common.SingleGasesData.H2O;
  constant Modelica.Media.IdealGases.Common.DataRecord dryair = Modelica.Media.IdealGases.Common.SingleGasesData.Air;
  constant Modelica.Units.SI.MassFraction X_N2 = Modelica.Media.IdealGases.MixtureGases.CombustionAir.X_default[1];
  constant Modelica.Units.SI.MassFraction X_O2 = Modelica.Media.IdealGases.MixtureGases.CombustionAir.X_default[2];
  inner Modelica.Fluid.System system(m_flow_start = system.m_flow_small, dp_small(displayUnit = "Pa") = 10, m_flow_small = 1e-3, p_ambient(displayUnit = "Pa") = 95000, T_ambient = 298.15) annotation(
    Placement(visible = true, transformation(origin = {-90, -90}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Electrochemical.Hydrogen.FuelCellStack fuelCellStack(A_FC_surf = 0.0305, N_FC_stack = 275, j_0_ref = 2.721837e2, E_A = 4.417500e4, f_CL = 9.672601e-1, D_GDL_ref = 5.388195e-5, D_CL_ref = 4.970848e-6, r_el = 6.606254e-6) annotation(
    Placement(visible = true, transformation(origin = {1.77636e-15, -1.77636e-15}, extent = {{-19, -19}, {19, 19}}, rotation = 0)));
  Modelica.Fluid.Sources.MassFlowSource_T H2Source(redeclare package Medium = Anode_Medium, nPorts = 1, use_T_in = true, use_m_flow_in = true) annotation(
    Placement(transformation(origin = {-70, 50}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Sensors.CurrentSensor currentSensor annotation(
    Placement(visible = true, transformation(origin = {-10, 40}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Blocks.Sources.RealExpression setMassflowH2(y = max(mf_An, 0.0001)) annotation(
    Placement(transformation(origin = {-140, 58}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Thermal.FluidHeatFlow.Sources.VolumeFlow volumeFlowCoolant(T0 = 343.15, T0fixed = true, medium = Coolant_Medium, useVolumeFlowInput = true, m = 1) annotation(
    Placement(transformation(origin = {-20, -50}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
  Modelica.Thermal.FluidHeatFlow.Sources.Ambient CoolantSource(medium = Coolant_Medium, useTemperatureInput = true, usePressureInput = false, constantAmbientPressure = system.p_ambient) annotation(
    Placement(visible = true, transformation(origin = {-40, -80}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
  Modelica.Thermal.FluidHeatFlow.Sensors.RelTemperatureSensor tempDT(medium = Coolant_Medium) annotation(
    Placement(visible = true, transformation(origin = {-1.77636e-15, -20}, extent = {{4, -4}, {-4, 4}}, rotation = 0)));
  Modelica.Thermal.FluidHeatFlow.Sources.Ambient CoolantSink(constantAmbientTemperature = system.T_ambient, medium = Coolant_Medium, constantAmbientPressure = system.p_ambient) annotation(
    Placement(visible = true, transformation(origin = {70, -80}, extent = {{10, -10}, {-10, 10}}, rotation = -180)));
  Modelica.Blocks.Sources.RealExpression setVflow(y = Vf_Cl) annotation(
    Placement(transformation(origin = {-50, -50}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Thermal.FluidHeatFlow.Sensors.TemperatureSensor tempCoolOut(medium = Coolant_Medium) annotation(
    Placement(visible = true, transformation(origin = {36, -60}, extent = {{-6, -6}, {6, 6}}, rotation = 0)));
  Modelica.Blocks.Sources.CombiTimeTable opCons(extrapolation = Modelica.Blocks.Types.Extrapolation.HoldLastPoint, fileName = Modelica.Utilities.Files.loadResource("modelica://VirtualFCS.Resources.LuT/OpCons_data.txt"), smoothness = Modelica.Blocks.Types.Smoothness.ConstantSegments, table = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 500, 2000, 2000, 2000, 100, 20, 20, 20; 0, 0, 20, 0, 100, 0.5, 0.1, 0.3, 0.4, 0, 0.2, 0.1, 500, 2000, 2000, 2000, 100, 70, 70, 70], tableName = "op_cons", verboseRead = false, tableOnFile = true) annotation(
    Placement(visible = true, transformation(origin = {-90, 90}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Electrical.Analog.Sources.SignalCurrent signalCurrent annotation(
    Placement(visible = true, transformation(origin = {0, 60}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.RealExpression setCurrent(y = I) annotation(
    Placement(visible = true, transformation(origin = {42, 90}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.RealExpression setPressureCathode(y = p_Ca_out) annotation(
    Placement(transformation(origin = {110, -24}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Blocks.Sources.RealExpression setTemperatureCoolant(y = T_Cl_in) annotation(
    Placement(visible = true, transformation(origin = {-120, -74}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.RealExpression setPressureAnode(y = p_An_out) annotation(
    Placement(transformation(origin = {-110, -24}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Fluid.Sources.MassFlowSource_T AirSource(redeclare package Medium = Cathode_Medium, nPorts = 2, use_T_in = true, use_X_in = true, use_m_flow_in = true) annotation(
    Placement(transformation(origin = {70, 50}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Fluid.Sources.Boundary_pT H2Sink(redeclare package Medium = Anode_Medium, nPorts = 1, use_T_in = false, use_X_in = false, use_p_in = true) annotation(
    Placement(transformation(origin = {-70, -32}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Fluid.Sources.Boundary_pT AirSink(redeclare package Medium = Cathode_Medium, nPorts = 1, use_T_in = false, use_X_in = false, use_p_in = true) annotation(
    Placement(transformation(origin = {70, -32}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Blocks.Continuous.FirstOrder OpCons[19](each T = 10, each y_start = eps) annotation(
    Placement(visible = true, transformation(origin = {-60, 90}, extent = {{-6, -6}, {6, 6}}, rotation = 0)));
  Modelica.Fluid.Sensors.MassFlowRate massFlowRateCathodeIn(redeclare package Medium = Cathode_Medium) annotation(
    Placement(transformation(origin = {40, 20}, extent = {{-6, -6}, {6, 6}}, rotation = -90)));
  Modelica.Fluid.Sensors.RelativePressure relativePressureAnode(redeclare package Medium = Anode_Medium) annotation(
    Placement(transformation(origin = {-40, -2}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Fluid.Sensors.RelativePressure relativePressureCathode(redeclare package Medium = Cathode_Medium) annotation(
    Placement(transformation(origin = {39.5, -0.5}, extent = {{-5.5, 5.5}, {5.5, -5.5}}, rotation = -90)));
  Modelica.Fluid.Sensors.MassFractions massFractionWaterOut(redeclare package Medium = Cathode_Medium) annotation(
    Placement(transformation(origin = {44, -18}, extent = {{-4, 4}, {4, -4}}, rotation = 90)));
  Modelica.Fluid.Sensors.MassFractions massFractionWaterIn(redeclare package Medium = Cathode_Medium) annotation(
    Placement(transformation(origin = {50, 56}, extent = {{-6, 6}, {6, -6}}, rotation = -180)));
  Modelica.Fluid.Sensors.MassFlowRate massFlowRateCathodeOut(redeclare package Medium = Cathode_Medium) annotation(
    Placement(transformation(origin = {40, -26}, extent = {{-6, -6}, {6, 6}}, rotation = -90)));
  Modelica.Blocks.Sources.RealExpression setMassflowAir(y = max(mf_Air, system.m_flow_small)) annotation(
    Placement(transformation(origin = {110, 72}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Units.SI.Current I = OpCons[1].y;
  Modelica.Units.SI.Pressure p_An_in = Modelica.Units.Conversions.from_bar(OpCons[2].y) + system.p_ambient;
  Modelica.Units.SI.Pressure p_An_out = Modelica.Units.Conversions.from_bar(OpCons[3].y) + system.p_ambient;
  Real phi_An = OpCons[4].y/100;
  Modelica.Units.SI.Pressure p_Ca_in = Modelica.Units.Conversions.from_bar(OpCons[5].y) + system.p_ambient;
  Modelica.Units.SI.Pressure p_Ca_out = Modelica.Units.Conversions.from_bar(OpCons[6].y) + system.p_ambient;
  Real phi_Ca = OpCons[7].y/100;
  Real T_Cl_out = tempCoolOut.y - 273.15;
  Real T_Ca_out = fuelCellStack.temperatureCathodeOut.T - 273.15;
  Modelica.Units.SI.VolumeFlowRate Vf_An = OpCons[8].y/60000;
  Modelica.Units.SI.VolumeFlowRate Vf_H2 = OpCons[9].y/60000;
  Modelica.Units.SI.VolumeFlowRate Vf_N2 = OpCons[10].y/60000;
  Modelica.Units.SI.MassFlowRate mf_An = OpCons[18].y;
  Modelica.Units.SI.MassFlowRate mf_An_calc = mf_H2_An + mf_N2_An + mf_H2O_An;
  Modelica.Units.SI.MassFlowRate mf_H2_An = Vf_H2*p_An_in/T_An_in/hydrogen.R_s;
  Modelica.Units.SI.MassFlowRate mf_N2_An = Vf_N2*p_An_in/T_An_in/nitrogen.R_s;
  Modelica.Units.SI.MassFlowRate mf_H2O_An = Vf_An*X_w_An*p_An_in/T_An_in/steam.R_s;
  Modelica.Units.SI.VolumeFlowRate Vf_Air = OpCons[11].y/60000;
  Real R_s = Cathode_Medium.gasConstant_X({X_w_Ca, 1 - X_w_Ca});
  Real R_air = dryair.R_s;
  Real R_steam = steam.R_s;
  //  Modelica.Units.SI.MassFlowRate mf_Air = Vf_Air*((1-X_w_Ca)*fuelCellStack.port_a_Air.p/T_Ca_in/dryair.R_s + X_w_Ca*fuelCellStack.port_a_Air.p/T_Ca_in/steam.R_s);
  Modelica.Units.SI.MassFlowRate mf_Air_calc = Vf_Air*fuelCellStack.port_a_Air.p/T_Ca_in/R_s;
  Modelica.Units.SI.MassFlowRate mf_Air = OpCons[19].y;
  Modelica.Units.SI.VolumeFlowRate Vf_Cl = OpCons[12].y/60000;
  Modelica.Units.SI.Temperature T_Cl_in = max(Modelica.Units.Conversions.from_degC(OpCons[13].y), Cathode_Medium.T_default);
  Modelica.Units.SI.Temperature T_An_in = max(Modelica.Units.Conversions.from_degC(OpCons[15].y), Anode_Medium.T_default);
  Modelica.Units.SI.Temperature T_Ca_in = max(Modelica.Units.Conversions.from_degC(OpCons[16].y), Cathode_Medium.T_default);
  Modelica.Units.SI.MassFraction X_w_Ca = Cathode_Medium.massFraction_pTphi(p_Ca_in, T_Ca_in, phi_Ca);
  Modelica.Units.SI.MassFraction X_w_An = Cathode_Medium.massFraction_pTphi(p_An_in, T_An_in, phi_An) annotation(
    Placement(visible = false, transformation(extent = {{0, 0}, {0, 0}})));
  Modelica.Thermal.FluidHeatFlow.Sensors.RelPressureSensor relPressureCoolant(medium = Coolant_Medium) annotation(
    Placement(transformation(origin = {10, -30}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.RealExpression setX2(y = 1 - X_w_Ca) annotation(
    Placement(transformation(origin = {110, 30}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Blocks.Sources.RealExpression setX1(y = X_w_Ca) annotation(
    Placement(transformation(origin = {110, 44}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRateH2(redeclare package Medium = Anode_Medium) annotation(
    Placement(transformation(origin = {-40, 40}, extent = {{6, -6}, {-6, 6}}, rotation = 90)));
  Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRateAir(redeclare package Medium = Cathode_Medium) annotation(
    Placement(transformation(origin = {40, 40}, extent = {{-6, -6}, {6, 6}}, rotation = -90)));
  Modelica.Blocks.Sources.RealExpression setTemperatureAnIn(y = T_An_in) annotation(
    Placement(transformation(origin = {-140, 44}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.RealExpression setTemperatureCaIn(y = T_Ca_in) annotation(
    Placement(transformation(origin = {110, 58}, extent = {{10, -10}, {-10, 10}}, rotation = -0)));
equation
  connect(currentSensor.n, fuelCellStack.pin_n) annotation(
    Line(points = {{-10, 30}, {-10, 14}}, color = {0, 0, 255}));
  connect(volumeFlowCoolant.flowPort_b, fuelCellStack.port_a_Coolant) annotation(
    Line(points = {{-20, -40}, {-20, -20}, {-4, -20}, {-4, -12}}, color = {255, 0, 0}));
  connect(CoolantSource.flowPort, volumeFlowCoolant.flowPort_a) annotation(
    Line(points = {{-30, -80}, {-20, -80}, {-20, -60}}, color = {255, 0, 0}));
  connect(fuelCellStack.port_b_Coolant, CoolantSink.flowPort) annotation(
    Line(points = {{4, -12}, {4, -20}, {30, -20}, {30, -80}, {60, -80}}, color = {255, 0, 0}));
  connect(tempDT.flowPort_a, fuelCellStack.port_b_Coolant) annotation(
    Line(points = {{4, -20}, {4, -12}}, color = {255, 0, 0}));
  connect(tempDT.flowPort_b, fuelCellStack.port_a_Coolant) annotation(
    Line(points = {{-4, -20}, {-4, -12}}, color = {255, 0, 0}));
  connect(tempCoolOut.flowPort, tempDT.flowPort_a) annotation(
    Line(points = {{30, -60}, {30, -20}, {4, -20}}, color = {255, 0, 0}));
  connect(currentSensor.p, signalCurrent.n) annotation(
    Line(points = {{-10, 50}, {-10, 60}}, color = {0, 0, 255}));
  connect(signalCurrent.p, fuelCellStack.pin_p) annotation(
    Line(points = {{10, 60}, {10, 14}}, color = {0, 0, 255}));
  connect(setTemperatureCoolant.y, CoolantSource.ambientTemperature) annotation(
    Line(points = {{-109, -74}, {-50, -74}}, color = {0, 0, 127}));
  connect(setPressureAnode.y, H2Sink.p_in) annotation(
    Line(points = {{-99, -24}, {-83, -24}}, color = {0, 0, 127}));
  connect(setPressureCathode.y, AirSink.p_in) annotation(
    Line(points = {{99, -24}, {82, -24}}, color = {0, 0, 127}));
  connect(setMassflowH2.y, H2Source.m_flow_in) annotation(
    Line(points = {{-129, 58}, {-81, 58}}, color = {0, 0, 127}));
  connect(setCurrent.y, signalCurrent.i) annotation(
    Line(points = {{32, 90}, {0, 90}, {0, 72}}, color = {0, 0, 127}));
  connect(relativePressureAnode.port_a, fuelCellStack.port_a_H2) annotation(
    Line(points = {{-40, 8}, {-14, 8}}, color = {0, 127, 255}));
  connect(relativePressureAnode.port_b, fuelCellStack.port_b_H2) annotation(
    Line(points = {{-40, -12}, {-40, -8}, {-14, -8}}, color = {0, 127, 255}));
  connect(relativePressureCathode.port_b, fuelCellStack.port_b_Air) annotation(
    Line(points = {{40, -6}, {40, -8}, {14, -8}}, color = {0, 127, 255}));
  connect(relativePressureCathode.port_a, fuelCellStack.port_a_Air) annotation(
    Line(points = {{40, 6}, {40, 8}, {14, 8}}, color = {0, 127, 255}));
  connect(massFractionWaterOut.port, fuelCellStack.port_b_Air) annotation(
    Line(points = {{40, -18}, {40, -8}, {14, -8}}, color = {0, 127, 255}));
  connect(massFlowRateCathodeIn.port_b, fuelCellStack.port_a_Air) annotation(
    Line(points = {{40, 14}, {40, 8}, {14, 8}}, color = {0, 127, 255}));
  connect(massFlowRateCathodeOut.port_a, fuelCellStack.port_b_Air) annotation(
    Line(points = {{40, -20}, {40, -8}, {14, -8}}, color = {0, 127, 255}));
  connect(setVflow.y, volumeFlowCoolant.volumeFlow) annotation(
    Line(points = {{-38, -50}, {-30, -50}}, color = {0, 0, 127}));
  connect(massFlowRateCathodeOut.port_b, AirSink.ports[1]) annotation(
    Line(points = {{40, -32}, {60, -32}}, color = {0, 127, 255}));
  connect(relativePressureAnode.port_b, H2Sink.ports[1]) annotation(
    Line(points = {{-40, -12}, {-40, -32}, {-60, -32}}, color = {0, 127, 255}));
  connect(massFractionWaterIn.port, AirSource.ports[1]) annotation(
    Line(points = {{50, 50}, {60, 50}}, color = {0, 127, 255}));
  connect(setMassflowAir.y, AirSource.m_flow_in) annotation(
    Line(points = {{99, 72}, {90, 72}, {90, 58}, {80, 58}}, color = {0, 0, 127}));
  connect(relPressureCoolant.flowPort_a, fuelCellStack.port_a_Coolant) annotation(
    Line(points = {{0, -30}, {-4, -30}, {-4, -12}}, color = {255, 0, 0}));
  connect(relPressureCoolant.flowPort_b, fuelCellStack.port_b_Coolant) annotation(
    Line(points = {{20, -30}, {22, -30}, {22, -20}, {4, -20}, {4, -12}}, color = {255, 0, 0}));
  connect(setX1.y, AirSource.X_in[1]) annotation(
    Line(points = {{100, 44}, {90, 44}, {90, 46}, {82, 46}}, color = {0, 0, 127}));
  connect(setX2.y, AirSource.X_in[2]) annotation(
    Line(points = {{100, 30}, {90, 30}, {90, 46}, {82, 46}}, color = {0, 0, 127}));
  connect(H2Source.ports[1], volumeFlowRateH2.port_a) annotation(
    Line(points = {{-60, 50}, {-40, 50}, {-40, 46}}, color = {0, 127, 255}));
  connect(volumeFlowRateH2.port_b, fuelCellStack.port_a_H2) annotation(
    Line(points = {{-40, 34}, {-40, 8}, {-14, 8}}, color = {0, 127, 255}));
  connect(volumeFlowRateAir.port_b, massFlowRateCathodeIn.port_a) annotation(
    Line(points = {{40, 34}, {40, 26}}, color = {0, 127, 255}));
  connect(AirSource.ports[2], volumeFlowRateAir.port_a) annotation(
    Line(points = {{60, 50}, {40, 50}, {40, 46}}, color = {0, 127, 255}));
  connect(setTemperatureAnIn.y, H2Source.T_in) annotation(
    Line(points = {{-128, 44}, {-100, 44}, {-100, 54}, {-82, 54}}, color = {0, 0, 127}));
  connect(setTemperatureCaIn.y, AirSource.T_in) annotation(
    Line(points = {{100, 58}, {94, 58}, {94, 54}, {82, 54}}, color = {0, 0, 127}));
  connect(opCons.y, OpCons.u) annotation(
    Line(points = {{-78, 90}, {-68, 90}}, color = {0, 0, 127}, thickness = 0.5));
  annotation(
    Diagram,
    Icon,
    Documentation(info = "<html><head></head><body>
<p>This example operates a single <a href=\"modelica://VirtualFCS.Electrochemical.Hydrogen.FuelCellStack\">FuelCellStack</a> without subsystems. All boundary conditions are prescribed from the time table <code>opCons</code>:</p>
<ul>
<li>The stack load is a <code>SignalCurrent</code> source that follows the current set point.</li>
<li>Hydrogen is supplied by a mass flow source with prescribed mass flow and temperature, air by a mass flow source with prescribed mass flow, temperature and humidity. The outlet pressures are set by pressure boundaries.</li>
<li>The coolant is supplied by a volume flow source with prescribed volume flow and inlet temperature.</li></ul>
<h4>Operating-point input</h4>
<p>Operating points are read from the text table <code>op_cons</code> in <code>OpCons_data.txt</code>, which is a variable interface file (see <a href=\"modelica://VirtualFCS.Utilities.SystemControl\">SystemControl</a>, \"Operating-point input\"). Its column layout must match this model (19 data columns, as in <code>OpCons_data_TestFuelCell.txt</code>); a dedicated file can be set via <code>fileName</code>. Columns used:</p>
<table>
<tbody><tr><td>1</td><td>Stack current [A]</td></tr>
<tr><td>2, 3</td><td>Anode inlet and outlet pressure [bar(g)]</td></tr>
<tr><td>4</td><td>Anode relative humidity [%]</td></tr>
<tr><td>5, 6</td><td>Cathode inlet and outlet pressure [bar(g)]</td></tr>
<tr><td>7</td><td>Cathode inlet relative humidity [%]</td></tr>
<tr><td>8, 9, 10</td><td>Anode, hydrogen and nitrogen volume flow [l/min]</td></tr>
<tr><td>11</td><td>Air volume flow [l/min]</td></tr>
<tr><td>12</td><td>Coolant volume flow [l/min]</td></tr>
<tr><td>13</td><td>Coolant inlet temperature [°C]</td></tr>
<tr><td>15, 16</td><td>Anode and cathode inlet temperature [°C]</td></tr>
<tr><td>18</td><td>Anode inlet mass flow [kg/s]</td></tr>
<tr><td>19</td><td>Air inlet mass flow [kg/s]</td></tr>
</tbody></table>
<p>Columns 14 and 17 are not used.</p>
</body></html>"),
    experiment(StartTime = 1000, StopTime = 1200, Tolerance = 0.0001, Interval = 1),
    __OpenModelica_commandLineOptions = "--matchingAlgorithm=PFPlusExt --indexReductionMethod=dynamicStateSelection -d=initialization,NLSanalyticJacobian -d=bltdump -d=bltdump -d=bltdump -d=bltdump -d=bltdump -d=bltdump -d=bltdump,infoXmlOperations,dumpFunctions",
    __OpenModelica_simulationFlags(cpu = "()", lv = "LOG_STDOUT,LOG_ASSERT,LOG_STATS", s = "dassl", variableFilter = ".*"));
end TestFuelCell;
