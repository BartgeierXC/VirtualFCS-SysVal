within VirtualFCS.ComponentTesting;

model TestHumidifier
  extends Modelica.Icons.Example;
  //replaceable package MediumDry = Modelica.Media.Air.MoistAir;
  replaceable package MediumWet = Modelica.Media.Air.MoistAir;
  //Real hr_wet, hr_dry;
  inner Modelica.Fluid.System system(T_start(displayUnit = "K") = 288.15, energyDynamics = Modelica.Fluid.Types.Dynamics.DynamicFreeInitial, m_flow_start = 0.005, massDynamics = Modelica.Fluid.Types.Dynamics.DynamicFreeInitial, momentumDynamics = Modelica.Fluid.Types.Dynamics.SteadyStateInitial, p_ambient = 101350, p_start(displayUnit = "Pa") = 101350, m_flow_small = 1e-6) annotation(
    Placement(visible = true, transformation(origin = {-90, -90}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  parameter Real N_FC_stack = 275;
  parameter Real phi_ambient = 0.20;
  parameter Modelica.Units.SI.Thickness d_Mem = 1.8e-5 "Membrane thickness [m]";
  parameter Modelica.Units.SI.Pressure dp_nominal = 1e5;
  parameter Modelica.Units.SI.MassFlowRate mflow_nominal = 0.1;
  parameter Real dc_H2O(unit = "mol/m") = 0.03 "Lumped water-transport calibration constant (Delta_c*A) [mol/m]";
  // Section definition of operating conditions
  Modelica.Blocks.Sources.CombiTimeTable opCons(extrapolation = Modelica.Blocks.Types.Extrapolation.HoldLastPoint, smoothness = Modelica.Blocks.Types.Smoothness.LinearSegments, table = [0, 5120, 83.1, 2.561, 0.001, 4428.6, 88.9, 2.308, 0.251, 0.5], tableOnFile = true, tableName = "op_cons", fileName = Modelica.Utilities.Files.loadResource("modelica://VirtualFCS.Resources.LuT/OpCons_data.txt")) annotation(
    Placement(transformation(origin = {-90, 90}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.RealExpression setMassflowDryIn(y = max(mf_Ca_in, system.m_flow_small)) annotation(
    Placement(transformation(origin = {110, 108}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Blocks.Sources.RealExpression setTempDryIn(y = T_Hu_in) annotation(
    Placement(transformation(origin = {110, 94}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Blocks.Sources.RealExpression setPressureDryOut(y = p_Ca_in) annotation(
    Placement(transformation(origin = {120, -30}, extent = {{-10, 10}, {10, -10}}, rotation = 180)));
  Modelica.Blocks.Sources.RealExpression setPressureWetOut(y = p_Ca_out) annotation(
    Placement(transformation(origin = {-120, 60}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.RealExpression setTWetIn(y = T_Ca_out) annotation(
    Placement(transformation(origin = {-120, 14}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.RealExpression setX1WetIn(y = max(x_w_Ca_out, 1e-3)) annotation(
    Placement(transformation(origin = {-120, -6}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.RealExpression setMfWetIn(y = max(mf_Ca_out, system.m_flow_small)) annotation(
    Placement(transformation(origin = {-120, 30}, extent = {{10, 10}, {-10, -10}}, rotation = -180)));
  Modelica.Fluid.Sources.Boundary_pT WetAirOut(redeclare package Medium = MediumWet, use_p_in = true, use_T_in = false, use_X_in = false, nPorts = 2) annotation(
    Placement(transformation(origin = {58, 24}, extent = {{10, -10}, {-10, 10}}, rotation = -0)));
  Modelica.Fluid.Sources.MassFlowSource_T WetAirIn(redeclare package Medium = MediumWet, use_m_flow_in = true, nPorts = 1, use_T_in = true, use_X_in = true) annotation(
    Placement(transformation(origin = {-78, 10}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Fluid.Sources.MassFlowSource_T DryAirIn(redeclare package Medium = MediumWet, nPorts = 1, use_T_in = true, use_X_in = true, use_m_flow_in = true) annotation(
    Placement(transformation(origin = {70, 90}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Fluid.Sources.Boundary_pT DryAirOut(redeclare package Medium = MediumWet, nPorts = 1, use_T_in = false, use_X_in = false, use_p_in = true, p = 101350, T (displayUnit = "K")) annotation(
    Placement(transformation(origin = {76, -38}, extent = {{10, -10}, {-10, 10}})));
  Fluid.FcHumidityExchanger fcHumidityExchanger(redeclare package Medium = MediumWet, opModeEffL = VirtualFCS.Utilities.Types.opModeHTX.fumatech_H50N) annotation(
    Placement(transformation(origin = {8, 24}, extent = {{-14, -14}, {14, 14}})));
  Modelica.Blocks.Math.Feedback feedbackWetOut annotation(
    Placement(transformation(origin = {-50, 60}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Fluid.Sensors.RelativePressure relativePressureWet(redeclare package Medium = MediumWet) annotation(
    Placement(transformation(origin = {-18.7151, 37.0785}, extent = {{7.64996, -7.61826}, {-7.64996, 7.61826}}, rotation = -90)));
  Modelica.Blocks.Sources.RealExpression setX2WetIn(y = 1 - setX1WetIn.y) annotation(
    Placement(transformation(origin = {-120, -20}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Units.SI.Current I = opCons.y[1];
  Modelica.Units.SI.MassFlowRate mf_Ca_in = opCons.y[2];
  Modelica.Units.SI.MassFlowRate mf_Ca_out = mf_Ca_in - I*N_FC_stack*Modelica.Media.IdealGases.Common.SingleGasesData.O2.MM/(Modelica.Constants.F*4) + mf_H2O_prod;
  Modelica.Units.SI.Pressure p_Ca_in = Modelica.Units.Conversions.from_bar(opCons.y[3]);
  Modelica.Units.SI.Pressure p_Ca_out = Modelica.Units.Conversions.from_bar(opCons.y[4]);
  Modelica.Units.SI.Temperature T_Hu_in = Modelica.Units.Conversions.from_degC(opCons.y[5]);
  Modelica.Units.SI.Temperature T_Ca_out = Modelica.Units.Conversions.from_degC(opCons.y[6]);
  Modelica.Units.SI.Temperature T_Ca_in = Modelica.Units.Conversions.from_degC(opCons.y[7]);
  Real phi_Ca_in = opCons.y[8];
  Real x_valve = opCons.y[9];
  Real x_w_Hum_in = MediumWet.massFraction_pTphi(p_Ca_in, T_Hu_in, phi_ambient);
  Real x_w_Ca_in = MediumWet.massFraction_pTphi(system.p_ambient, system.T_ambient, phi_Ca_in);
  Real x_w_Ca_out = (x_w_Ca_in*mf_Ca_in + mf_H2O_prod)/mf_Ca_out;
  Real lambda_w = if senRelHumFCOut.phi < 1 then 0.043 + 17.81*senRelHumFCOut.phi - 39.85*senRelHumFCOut.phi^2 + 36*senRelHumFCOut.phi^3 else min(14 + 1.4*(senRelHumFCOut.phi - 1), 16.8);
  // has to be 0.634 or larger
  //(Springer et al. Eq.16,17)
  Modelica.Units.SI.DiffusionCoefficient D_w = D_l*exp(2416*(1/303 - 1/T_Hu_in));
  Modelica.Units.SI.DiffusionCoefficient D_l = 1e-5 * smooth(0,
             if lambda_w < 2 then 1
             elseif lambda_w < 3 then 1 + 2*(lambda_w - 2)
             elseif lambda_w < 4.5 then 3 - 1.67*(lambda_w - 3)
             else 0.495);

  Modelica.Units.SI.MolarFlowRate nf_dif = D_w*dc_H2O/d_Mem;

  Modelica.Units.SI.MolarFlowRate nf_H2O_prod = max(I*N_FC_stack/(Modelica.Constants.F*2),0);
  Modelica.Units.SI.MassFlowRate mf_H2O_prod = nf_H2O_prod*MediumWet.steam.MM;
  Modelica.Fluid.Sensors.Temperature temperatureCaIn(redeclare package Medium = MediumWet)  annotation(
    Placement(transformation(origin = {-20, -28}, extent = {{10, -10}, {-10, 10}}, rotation = -0)));

//*** VALIDATION STATE VARIABLE DECLARATION*** //
  Buildings.Fluid.Sensors.RelativeHumidityTwoPort senRelHumFCIn(redeclare package Medium = MediumWet, initType = Modelica.Blocks.Types.Init.InitialOutput, m_flow_nominal = 1, tau = 0.2) annotation(
    Placement(transformation(origin = {26, -38}, extent = {{6, -6}, {-6, 6}}, rotation = -0)));
  Modelica.Fluid.Valves.ValveCompressible valveCompressible(dp_nominal= dp_nominal, m_flow_nominal = mflow_nominal, filteredOpening = true, p_nominal= dp_nominal, riseTime = 1, leakageOpening = 0.01, m_flow(start = system.m_flow_start), dp(start = system.dp_small), CvData = Modelica.Fluid.Types.CvTypes.Kv, Kv = 193.5, redeclare package Medium = MediumWet, redeclare function valveCharacteristic = VirtualFCS.Fluid.ValveCharacteristics.burkert2671_DN50) annotation(
    Placement(transformation(origin = {-50, 10}, extent = {{10, -10}, {-10, 10}}, rotation = -180)));
  Modelica.Fluid.Valves.ValveCompressible valveCompressibleBp(CvData = Modelica.Fluid.Types.CvTypes.Kv, Kv = 193.5, redeclare package Medium = MediumWet, dp(start = system.dp_small), dp_nominal= dp_nominal, filteredOpening = true, leakageOpening = 0.01, m_flow(start = system.m_flow_start), m_flow_nominal = mflow_nominal, p_nominal= dp_nominal, riseTime = 1, redeclare function valveCharacteristic = VirtualFCS.Fluid.ValveCharacteristics.burkert2671_DN50) annotation(
    Placement(transformation(origin = {30, -10}, extent = {{-10, 10}, {10, -10}}, rotation = -0)));
  Modelica.Blocks.Sources.RealExpression setXValveIn(y = x_valve) annotation(
    Placement(transformation(origin = {-120, -36}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.RealExpression setXValveBp(y = 1 -x_valve) annotation(
    Placement(transformation(origin = {70, -10}, extent = {{10, -10}, {-10, 10}}, rotation = -0)));
  Buildings.Fluid.Sensors.RelativeHumidityTwoPort senRelHumFCOut(redeclare package Medium = MediumWet, initType = Modelica.Blocks.Types.Init.InitialOutput, m_flow_nominal = 1, tau = 0.2) annotation(
    Placement(transformation(origin = {-26, 10}, extent = {{6, -6}, {-6, 6}})));
  Buildings.Fluid.Sensors.RelativeHumidityTwoPort senRelHumFCDryIn(redeclare package Medium = MediumWet, initType = Modelica.Blocks.Types.Init.InitialOutput, m_flow_nominal = 1, tau = 0.2) annotation(
    Placement(transformation(origin = {8, 76}, extent = {{-6, -6}, {6, 6}}, rotation = -90)));
  Modelica.Blocks.Sources.RealExpression setX1DryIn(y = x_w_Hum_in) annotation(
    Placement(transformation(origin = {110, 80}, extent = {{10, -10}, {-10, 10}}, rotation = -0)));
  Modelica.Blocks.Sources.RealExpression setX2DryIn(y = 1 - x_w_Hum_in) annotation(
    Placement(transformation(origin = {110, 64}, extent = {{10, -10}, {-10, 10}}, rotation = -0)));
equation
// Section connections
  connect(setPressureDryOut.y, DryAirOut.p_in) annotation(
    Line(points = {{109, -30}, {88, -30}}, color = {0, 0, 127}));
  connect(setPressureWetOut.y, feedbackWetOut.u1) annotation(
    Line(points = {{-109, 60}, {-59, 60}}, color = {0, 0, 127}));
  connect(relativePressureWet.port_a, fcHumidityExchanger.port_a1) annotation(
    Line(points = {{-19, 29}, {-19, 24}, {-6, 24}}, color = {0, 127, 255}));
  connect(relativePressureWet.p_rel, feedbackWetOut.u2) annotation(
    Line(points = {{-26, 37}, {-50, 37}, {-50, 52}}, color = {0, 0, 127}));
  connect(feedbackWetOut.y, WetAirOut.p_in) annotation(
    Line(points = {{-41, 60}, {80, 60}, {80, 32}, {70, 32}}, color = {0, 0, 127}));
  connect(fcHumidityExchanger.port_b2, senRelHumFCIn.port_b) annotation(
    Line(points = {{8, 10}, {8, -38}, {20, -38}}, color = {0, 127, 255}));
  connect(senRelHumFCIn.port_a, DryAirOut.ports[1]) annotation(
    Line(points = {{32, -38}, {66, -38}}, color = {0, 127, 255}));
  connect(fcHumidityExchanger.port_b1, WetAirOut.ports[1]) annotation(
    Line(points = {{22, 24}, {48, 24}}, color = {0, 127, 255}));
  connect(relativePressureWet.port_b, fcHumidityExchanger.port_b1) annotation(
    Line(points = {{-19, 45}, {-19, 50}, {30, 50}, {30, 24}, {22, 24}}, color = {0, 127, 255}));
  connect(setTWetIn.y, WetAirIn.T_in) annotation(
    Line(points = {{-109, 14}, {-91, 14}}, color = {0, 0, 127}));
  connect(setX1WetIn.y, WetAirIn.X_in[1]) annotation(
    Line(points = {{-109, -6}, {-101, -6}, {-101, 6}, {-91, 6}}, color = {0, 0, 127}));
  connect(setX2WetIn.y, WetAirIn.X_in[2]) annotation(
    Line(points = {{-109, -20}, {-101, -20}, {-101, 6}, {-91, 6}}, color = {0, 0, 127}));
  connect(setMfWetIn.y, WetAirIn.m_flow_in) annotation(
    Line(points = {{-109, 30}, {-101, 30}, {-101, 18}, {-89, 18}}, color = {0, 0, 127}));
  connect(setTempDryIn.y, DryAirIn.T_in) annotation(
    Line(points = {{99, 94}, {82, 94}}, color = {0, 0, 127}));
  connect(setMassflowDryIn.y, DryAirIn.m_flow_in) annotation(
    Line(points = {{99, 108}, {91, 108}, {91, 98}, {79, 98}}, color = {0, 0, 127}));
  connect(temperatureCaIn.port, fcHumidityExchanger.port_b2) annotation(
    Line(points = {{-20, -38}, {8, -38}, {8, 10}}, color = {0, 127, 255}));
  connect(WetAirIn.ports[1], valveCompressible.port_a) annotation(
    Line(points = {{-68, 10}, {-60, 10}}, color = {0, 127, 255}));
  connect(valveCompressibleBp.port_b, WetAirOut.ports[2]) annotation(
    Line(points = {{40, -10}, {44, -10}, {44, 24}, {48, 24}}, color = {0, 127, 255}));
  connect(setXValveIn.y, valveCompressible.opening) annotation(
    Line(points = {{-108, -36}, {-50, -36}, {-50, 2}}, color = {0, 0, 127}));
  connect(setXValveBp.y, valveCompressibleBp.opening) annotation(
    Line(points = {{60, -10}, {50, -10}, {50, -28}, {30, -28}, {30, -18}}, color = {0, 0, 127}));
  connect(valveCompressibleBp.port_a, valveCompressible.port_a) annotation(
    Line(points = {{20, -10}, {-64, -10}, {-64, 10}, {-60, 10}}, color = {0, 127, 255}));
  connect(valveCompressible.port_b, senRelHumFCOut.port_b) annotation(
    Line(points = {{-40, 10}, {-32, 10}}, color = {0, 127, 255}));
  connect(senRelHumFCOut.port_a, fcHumidityExchanger.port_a1) annotation(
    Line(points = {{-20, 10}, {-14, 10}, {-14, 24}, {-6, 24}}, color = {0, 127, 255}));
  connect(senRelHumFCDryIn.port_b, fcHumidityExchanger.port_a2) annotation(
    Line(points = {{8, 70}, {8, 38}}, color = {0, 127, 255}));
  connect(DryAirIn.ports[1], senRelHumFCDryIn.port_a) annotation(
    Line(points = {{60, 90}, {8, 90}, {8, 82}}, color = {0, 127, 255}));
  connect(setX1DryIn.y, DryAirIn.X_in[1]) annotation(
    Line(points = {{100, 80}, {90, 80}, {90, 86}, {82, 86}}, color = {0, 0, 127}));
  connect(setX2DryIn.y, DryAirIn.X_in[2]) annotation(
    Line(points = {{100, 64}, {90, 64}, {90, 86}, {82, 86}}, color = {0, 0, 127}));
  annotation(
    experiment(Tolerance = 1e-06, StopTime = 3000, StartTime = 2000, Interval = 1),
    __Dymola_Commands(file = "modelica://Buildings/Resources/Scripts/Dymola/Fluid/MassExchangers/Examples/ConstantEffectiveness.mos" "Simulate and plot"),
    Documentation(info = "<html><head></head><body>
<p>Test of <a href=\"modelica://VirtualFCS.Fluid.FcHumidityExchanger\">FcHumidityExchanger</a> (<code>fumatech_H50N</code>) with humidifier and bypass valves (<code>burkert2671_DN50</code>). The dry side is fed with ambient-humidity air at the compressor outlet temperature. The wet-side inflow is computed from the dry inflow, the current and the product water by a molar balance. The model also computes an estimate of membrane water diffusion (water content after Springer et al., diffusion coefficient <code>D_w</code>, molar flow <code>nf_dif</code>) for comparison; it does not act on the humidifier.</p>
<h4>Operating-point input</h4>
<p>Operating points are read from the text table <code>op_cons</code> in <code>OpCons_data.txt</code>, which is a variable interface file (see <a href=\"modelica://VirtualFCS.Utilities.SystemControl\">SystemControl</a>, &quot;Operating-point input&quot;). Its column layout must match this model; a dedicated file can be set via <code>fileName</code>. Expected data columns (after the time column):</p>
<table>
<tr><td>1</td><td>Stack current [A]</td></tr>
<tr><td>2</td><td>Cathode inlet mass flow [kg/s]</td></tr>
<tr><td>3</td><td>Cathode inlet pressure [bar]</td></tr>
<tr><td>4</td><td>Cathode outlet pressure [bar]</td></tr>
<tr><td>5</td><td>Humidifier dry-side inlet temperature [&deg;C]</td></tr>
<tr><td>6</td><td>Cathode outlet temperature [&deg;C]</td></tr>
<tr><td>7</td><td>Cathode inlet temperature [&deg;C]</td></tr>
<tr><td>8</td><td>Cathode inlet relative humidity [-]</td></tr>
<tr><td>9</td><td>Humidifier valve opening [-]</td></tr>
</table>
<p>This layout corresponds to <code>OpCons_data_TestHumidifier.txt</code>.</p>
</body></html>"),
    __OpenModelica_commandLineOptions = "--matchingAlgorithm=PFPlusExt --indexReductionMethod=dynamicStateSelection -d=initialization,NLSanalyticJacobian",
    __OpenModelica_simulationFlags(lv = "LOG_STDOUT,LOG_ASSERT,LOG_STATS", s = "dassl", variableFilter = ".*"),
    Diagram(graphics = {Text(origin = {24, 16}, extent = {{-8, 8}, {8, -8}}, textString = "SYS OUT", fontSize = 8, textStyle = {TextStyle.Bold}), Text(origin = {21, 40}, extent = {{-9, 8}, {9, -8}}, textString = "CMP OUT", fontSize = 8, textStyle = {TextStyle.Bold}), Text(origin = {-2, 6}, extent = {{-8, 8}, {8, -8}}, textString = "FC IN", fontSize = 8, textStyle = {TextStyle.Bold}), Text(origin = {-14, 18}, extent = {{-8, 8}, {8, -8}}, textString = "FC OUT", fontSize = 8, textStyle = {TextStyle.Bold})}));
end TestHumidifier;
