within VirtualFCS.Electrochemical.Hydrogen;

model FuelCellStack
  // System
  outer Modelica.Fluid.System system "System properties";
  // Medium models
  replaceable package Cathode_Medium = Modelica.Media.Air.MoistAir;
  replaceable package Anode_Medium = Modelica.Media.IdealGases.SingleGases.H2 constrainedby Modelica.Media.Interfaces.PartialSimpleIdealGasMedium;
  constant Modelica.Thermal.FluidHeatFlow.Media.Medium Coolant_Medium = Modelica.Thermal.FluidHeatFlow.Media.Water();
  type VolumetricCurrentDensity = Real(final quantity = "VolumetricCurrentDensity", final unit = "A/m3");
  type ProtonConductivity = SI.ElectrolyticConductivity;
  type AreaResistance = Real(final quantity = "AreaResistance", final unit = "Ohm.m2");
  import Modelica.Math.*;
  import Modelica.Units.SI;
  import ModelicaServices.Machine.eps;
  import Modelica.Constants.pi;
  import Modelica.Constants.F;
  import Modelica.Constants.R;
  parameter Modelica.Units.SI.ThermalConductance G = 1e6 "Thermal conductance between stack mass and coolant";
  constant SI.Voltage U_LHV = 1.253 "Thermoneutral cell voltage based on the lower heating value";
  constant SI.CurrentDensity j_H2 = 13 "Hydrogen crossover current density";
  constant SI.MolarConcentration c_O2_ref = 7.36 "Reference molar concentration of O2";
  //  parameter SI.Pressure dp_nom_An = 20000 "Nominal pressure difference anode";
  //  parameter SI.Pressure dp_nom_Ca = 10000 "Nominal pressure difference cathode";
  parameter VolumetricCurrentDensity j_0_ref = 2130.8 "Reference exchange current density";
  parameter SI.MolarEnergy E_A = 71477 "Activation energy of the O2 reduction reaction";
  parameter Real f_CL = 0.36693 "Proportionality factor for the proton conductivity of the CL [-]";
  constant Real sigma_mem_material_param_a(unit = "S/cm") = 0.005139;
  constant Real sigma_mem_material_param_b(unit = "S/cm") = 0.00326;
  parameter SI.Area A_FC_surf = 0.024 "Active cell area";
  parameter SI.SpecificHeatCapacity Cp_FC_stack = 500.0 "FC stack specific heat capacity";
  parameter SI.Mass m_FC_stack = 42 "FC stack mass";
  parameter Real N_FC_stack(unit = "1") = 274 "FC stack number of cells";

  parameter SI.DiffusionCoefficient D_GDL_ref = 8.6266e-6 "Effective reference diffusion coefficient of the GDL";
  parameter SI.DiffusionCoefficient D_CL_ref = 3.3438e-8 "Effective reference diffusion coefficient of the CL";

  parameter AreaResistance r_el = 4.2738e-6 "Area-specific electrical resistance of the cell";
  //parameter Real lambda_An_min = 1.29 "Set min h2 mass flow stoichiometry at max power";
  parameter SI.Pressure pd_cool_nom(displayUnit = "Pa") = 24534 "Nominal coolant pressure drop";
  parameter SI.VolumeFlowRate vflow_cool_nom = 0.002618 "Nominal coolant volume flow rate";
  parameter SI.Volume V_Ca = 0.01 "Volume of the cathode junction";
  parameter SI.Mass m_coolant = 10 "Mass of coolant contained in the FC stack";
  parameter Modelica.Units.SI.Time tau_H2O = 20 "Time constant of the water distribution in the stack";
  //*** VALIDATION STATE VARIABLE DECLARATION*** //
  // Internal state variables
  SI.Temperature T_S "Stack temperature";
  SI.Pressure p_O2 "Oxygen partial pressure at the cathode inlet";
  SI.Current I_Z "Cell current";
  SI.Voltage U_Z "Cell voltage";
  SI.Power P_th "Heat generated in the stack";
  SI.Voltage U_N "Nernst voltage";
  SI.Voltage U_Akt "Activation overvoltage";
  SI.Voltage U_Dif "Diffusion overvoltage";
  SI.Voltage U_Ohm "Ohmic losses";
  Real lambda_K "Cathode stoichiometry";
  SI.CurrentDensity j_Z(displayUnit = "A/cm2") "Cell current density";
  Real phi_Ca "Mean relative humidity at the cathode";
  SI.MolarFlowRate nf_H2 "Molar flow rate of consumed H2";
  SI.MolarFlowRate nf_H2O_prod "Molar flow rate of produced water";
  SI.Pressure p_sat "Saturation pressure of water at stack temperature";
  SI.Voltage U_CL "Mass transport losses in the CL";
  SI.Voltage U_GDL "Mass transport losses in the GDL";
  Modelica.Units.SI.Efficiency eta_FC_LHV "Lower heating value efficiency of fuel cell stack";
  Modelica.Electrical.Analog.Interfaces.PositivePin pin_p annotation(
    Placement(transformation(origin = {60, 140}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {80, 110}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Interfaces.NegativePin pin_n annotation(
    Placement(transformation(origin = {-60, 140}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {-80, 110}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b_H2(redeclare package Medium = Anode_Medium) annotation(
    Placement(transformation(origin = {-140, 0}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {-110, -70}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_a_H2(redeclare package Medium = Anode_Medium) annotation(
    Placement(transformation(origin = {-140, 80}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {-110, 70}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_a_Air(redeclare package Medium = Cathode_Medium) annotation(
    Placement(transformation(origin = {140, 80}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {110, 70}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b_Air(redeclare package Medium = Cathode_Medium) annotation(
    Placement(visible = true, transformation(origin = {140, 20}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {110, -70}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heatPort annotation(
    Placement(transformation(origin = {-20, -120}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {0, 70}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Thermal.FluidHeatFlow.Interfaces.FlowPort_a port_a_Coolant(medium = Coolant_Medium) annotation(
    Placement(transformation(origin = {-140, -40}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {-30, -90}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Thermal.FluidHeatFlow.Interfaces.FlowPort_b port_b_Coolant(medium = Coolant_Medium) annotation(
    Placement(transformation(origin = {140, -40}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {30, -90}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Thermal.HeatTransfer.Components.ThermalConductor thermalConductor(G = G) annotation(
    Placement(visible = true, transformation(origin = {0, -70}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
  Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor temperatureHeatCapacity annotation(
    Placement(visible = true, transformation(origin = {-50, -90}, extent = {{10, -10}, {-10, 10}}, rotation = -90)));
  Modelica.Thermal.HeatTransfer.Components.HeatCapacitor heatCapacitor(C = Cp_FC_stack*m_FC_stack, T(start = system.T_ambient, fixed = true), der_T(fixed = false)) annotation(
    Placement(transformation(origin = {30, -90}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow annotation(
    Placement(transformation(origin = {90, -120}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Electrical.Analog.Sensors.CurrentSensor currentSensor annotation(
    Placement(transformation(origin = {0, 100}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Electrical.Analog.Sources.SignalVoltage potentialSource annotation(
    Placement(visible = true, transformation(origin = {-30, 110}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
  Modelica.Electrical.Analog.Basic.Ground ground annotation(
    Placement(visible = true, transformation(origin = {-106, 114}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Fluid.Sources.MassFlowSource_T H2_sink(redeclare package Medium = Anode_Medium, nPorts = 1, use_T_in = false, use_m_flow_in = true) annotation(
    Placement(visible = true, transformation(origin = {-80, 61}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
  Modelica.Fluid.Sources.MassFlowSource_T O2_sink(redeclare package Medium = Cathode_Medium, nPorts = 1, use_T_in = false, use_m_flow_in = true) annotation(
    Placement(transformation(origin = {60, 50}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Math.Gain O2_mflow(k = N_FC_stack*oxygen.MM/(F*4)) annotation(
    Placement(transformation(origin = {42, 80}, extent = {{-8, -8}, {8, 8}})));
  Modelica.Blocks.Math.Gain H2_mflow(k = N_FC_stack*hydrogen.MM/(F*2)) annotation(
    Placement(transformation(origin = {-41, 80}, extent = {{9, -9}, {-9, 9}})));
  Modelica.Fluid.Fittings.TeeJunctionVolume teeJunctionVolumeAn(redeclare package Medium = Anode_Medium, V = 0.01, p_start = system.p_start, energyDynamics = Modelica.Fluid.Types.Dynamics.SteadyState, massDynamics = Modelica.Fluid.Types.Dynamics.SteadyState) annotation(
    Placement(transformation(origin = {-120, 30}, extent = {{10, 10}, {-10, -10}}, rotation = 90)));
  Modelica.Blocks.Sources.RealExpression real_Q_flow(y = P_th) annotation(
    Placement(transformation(origin = {130, -120}, extent = {{-10, 10}, {10, -10}}, rotation = -180)));
  Modelica.Blocks.Sources.RealExpression stackVoltage(y = U_Z*N_FC_stack) annotation(
    Placement(visible = true, transformation(origin = {-75, 110}, extent = {{15, 10}, {-15, -10}}, rotation = 180)));
  Modelica.Fluid.Sensors.Temperature temperatureCathodeIn(redeclare package Medium = Cathode_Medium) annotation(
    Placement(visible = true, transformation(origin = {140, 110}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Units.SI.MoleFraction Y_i[3];
  Modelica.Units.SI.MassFraction X_dryair;
  Modelica.Units.SI.Temperature DT;
  constant Modelica.Units.SI.MassFraction X_N2 = Modelica.Media.IdealGases.MixtureGases.CombustionAir.X_default[1];
  constant Modelica.Units.SI.MassFraction X_O2 = Modelica.Media.IdealGases.MixtureGases.CombustionAir.X_default[2];
  constant Modelica.Media.IdealGases.Common.DataRecord oxygen = Modelica.Media.IdealGases.Common.SingleGasesData.O2;
  constant Modelica.Media.IdealGases.Common.DataRecord nitrogen = Modelica.Media.IdealGases.Common.SingleGasesData.N2;
  constant Modelica.Media.IdealGases.Common.DataRecord hydrogen = Modelica.Media.IdealGases.Common.SingleGasesData.H2;
  Modelica.Fluid.Sensors.Temperature temperatureCathodeOut(redeclare package Medium = Cathode_Medium) annotation(
    Placement(visible = true, transformation(origin = {140, 50}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Buildings.Fluid.Sensors.RelativeHumidityTwoPort relHumCaIn(redeclare package Medium = Cathode_Medium, m_flow_nominal = system.m_flow_nominal, tau = 1e-3, allowFlowReversal = false, initType = Modelica.Blocks.Types.Init.NoInit, m_flow_small = system.m_flow_small) annotation(
    Placement(visible = true, transformation(origin = {120, 80}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
  Buildings.Fluid.Sensors.RelativeHumidityTwoPort relHumCaOut(redeclare package Medium = Cathode_Medium, m_flow_nominal = system.m_flow_nominal, tau = 1e-3, allowFlowReversal = false, initType = Modelica.Blocks.Types.Init.NoInit, m_flow_small = system.m_flow_small) annotation(
    Placement(transformation(origin = {130, -8}, extent = {{-10, 10}, {10, -10}})));
  Modelica.Thermal.FluidHeatFlow.Components.Pipe pipeCoolant(T0 = system.T_ambient, T0fixed = true, V_flowLaminar = 0.000004, V_flowNominal = vflow_cool_nom, dpLaminar(displayUnit = "Pa") = 17.373494, dpNominal(displayUnit = "Pa") = pd_cool_nom, h_g = 0, m = m_coolant, medium = Coolant_Medium, useHeatPort = true) annotation(
    Placement(visible = true, transformation(origin = {-10, -40}, extent = {{0, -10}, {20, 10}}, rotation = 0)));
  Modelica.Thermal.FluidHeatFlow.Sensors.TemperatureSensor temperatureCoolantIn(medium = Coolant_Medium) annotation(
    Placement(visible = true, transformation(origin = {-100, -50}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Blocks.Sources.RealExpression mFlowWat(y = max(nf_H2O_prod*Cathode_Medium.steam.MM + abs(mFlowO2_sink.y*airResistance.Xw_in), 0)) annotation(
    Placement(transformation(origin = {30, 30}, extent = {{-10, -10}, {10, 10}})));
  Fluid.FlowResistanceHumPoly airResistance(redeclare package Medium = Cathode_Medium) annotation(
    Placement(transformation(origin = {90, 60}, extent = {{10, -10}, {-10, 10}}, rotation = 90)));
  Modelica.Blocks.Sources.RealExpression realT(y = temperatureCoolantOut.y) annotation(
    Placement(transformation(origin = {110, 130}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
  Modelica.Fluid.Fittings.TeeJunctionVolume teeJunctionVolumeCa(redeclare package Medium = Cathode_Medium, V = V_Ca, p_start = system.p_start, energyDynamics = Modelica.Fluid.Types.Dynamics.DynamicFreeInitial, massDynamics = Modelica.Fluid.Types.Dynamics.DynamicFreeInitial) annotation(
    Placement(transformation(origin = {90, 30}, extent = {{-10, 10}, {10, -10}}, rotation = -90)));
  Fluid.FcWaterSource waterSrcCa(redeclare package Medium = Cathode_Medium, T_b(fixed = false, displayUnit = "K"), T_a(fixed = false, displayUnit = "K"), dp(displayUnit = "Pa") = 1, dT_out = 0) annotation(
    Placement(transformation(origin = {50, 10}, extent = {{10, 10}, {-10, -10}})));
  VirtualFCS.Fluid.FlowResistanceTemp h2Resistance(redeclare package Medium = Anode_Medium, K_l = 1.28024e4, K_t = 1.24879e5, K_exp = 2.149110) annotation(
    Placement(transformation(origin = {-120, 60}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Thermal.FluidHeatFlow.Sensors.TemperatureSensor temperatureCoolantOut(medium = Coolant_Medium) annotation(
    Placement(transformation(origin = {100, -50}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Blocks.Sources.RealExpression realDT(y = DT) annotation(
    Placement(transformation(origin = {58, 120}, extent = {{10, -10}, {-10, 10}}, rotation = -180)));
  Thermal.HeatExchanger heatEx(redeclare package Medium = Cathode_Medium)  annotation(
    Placement(transformation(origin = {70, -8}, extent = {{-10, 10}, {10, -10}}, rotation = -0)));
  Modelica.Blocks.Sources.RealExpression mFlowO2_sink(y = O2_mflow.y/X_dryair) annotation(
    Placement(transformation(origin = {10, 58}, extent = {{-10, -10}, {10, 10}})));

protected
  // Published default thicknesses (Hahn 2023). The validation results of the publication were computed with confidential stack values.
  parameter SI.Thickness d_Mem = 18e-6 "Membrane thickness";
  parameter SI.Thickness d_CL = 10e-6 "CL thickness";
  parameter SI.Thickness d_GDL = 200e-6 "GDL thickness";

initial equation
  der(phi_Ca) = 0;
equation
  X_dryair = 1 - airResistance.Xw_in;
  Y_i = Cathode_Medium.massToMoleFractions({1-X_dryair, X_dryair*X_N2, X_dryair*X_O2}, {Cathode_Medium.steam.MM, nitrogen.MM, oxygen.MM});
  eta_FC_LHV = max(U_Z/U_LHV, 0);
  p_O2 = port_a_Air.p*Y_i[3];
  der(phi_Ca) = ((relHumCaIn.phi+relHumCaOut.phi)/2 - phi_Ca)/tau_H2O;
  I_Z = abs(currentSensor.i);
  T_S = temperatureHeatCapacity.T;
// Cathode stoichiometry = O2 mass supplied / O2 mass consumed.
  lambda_K = min(max(port_a_Air.m_flow*X_dryair*X_O2*oxygen.MM/((abs(O2_mflow.y) + eps)*oxygen.MM), eps), 100);

  nf_H2 = -H2_mflow.y/hydrogen.MM;
  nf_H2O_prod = nf_H2;
  
  p_sat = Cathode_Medium.saturationPressure(T_S);
  DT = Cathode_Medium.saturationTemperature(phi_Ca*p_sat);
  (U_Z, U_N, U_Akt, U_Ohm, U_Dif, U_CL, U_GDL, j_Z) = calculate_cell_voltage(I_Z = I_Z, p_H2_A_ein = port_a_H2.p, T_S = T_S, lambda_K = lambda_K, phi_ca = phi_Ca, p_ca_in = port_a_Air.p, p_ca_out = port_b_Air.p, p_O2 = p_O2, T_ca_in = temperatureCathodeIn.T, A_FC_surf = A_FC_surf, j_0_ref = j_0_ref, E_A = E_A, f_CL = f_CL, r_el = r_el, D_CL_ref = D_CL_ref, D_GDL_ref = D_GDL_ref, d_CL = d_CL, d_GDL = d_GDL, d_Mem = d_Mem, j_H2 = j_H2, c_O2_ref = c_O2_ref, sigma_mem_material_param_a = sigma_mem_material_param_a, sigma_mem_material_param_b = sigma_mem_material_param_b);
// THERMAL EQUATIONS //
  P_th = (U_LHV - U_Z)*I_Z*N_FC_stack;
// ASSERT //
  assert(U_Z > eps, "U_Z negative, FC in overload!");
  assert(lambda_K >= 1, "Stoichiometry < 1, cathode undersupply!", AssertionLevel.warning);
  connect(currentSensor.n, potentialSource.p) annotation(
    Line(points = {{-10, 100}, {-30, 100}}, color = {0, 0, 255}));
  connect(pin_n, potentialSource.n) annotation(
    Line(points = {{-60, 140}, {-30, 140}, {-30, 120}}, color = {0, 0, 255}));
  connect(pin_p, currentSensor.p) annotation(
    Line(points = {{60, 140}, {20, 140}, {20, 100}, {10, 100}}, color = {0, 0, 255}));
  connect(pin_n, ground.p) annotation(
    Line(points = {{-60, 140}, {-106, 140}, {-106, 124}}, color = {0, 0, 255}));
  connect(H2_mflow.y, H2_sink.m_flow_in) annotation(
    Line(points = {{-51, 80}, {-63, 80}, {-63, 69}, {-70, 69}}, color = {0, 0, 127}));
  connect(real_Q_flow.y, prescribedHeatFlow.Q_flow) annotation(
    Line(points = {{119, -120}, {100, -120}}, color = {0, 0, 127}));
  connect(stackVoltage.y, potentialSource.v) annotation(
    Line(points = {{-58.5, 110}, {-42, 110}}, color = {0, 0, 127}));
  connect(temperatureCathodeIn.port, port_a_Air) annotation(
    Line(points = {{140, 100}, {140, 80}}, color = {0, 127, 255}));
  connect(relHumCaIn.port_a, port_a_Air) annotation(
    Line(points = {{130, 80}, {140, 80}}, color = {0, 127, 255}));
  connect(temperatureCathodeOut.port, port_b_Air) annotation(
    Line(points = {{140, 40}, {140, 20}}, color = {0, 127, 255}));
  connect(relHumCaOut.port_b, port_b_Air) annotation(
    Line(points = {{140, -8}, {140, 20}}, color = {0, 127, 255}));
  connect(thermalConductor.port_b, pipeCoolant.heatPort) annotation(
    Line(points = {{0, -60}, {0, -50}}, color = {191, 0, 0}));
  connect(pipeCoolant.flowPort_a, port_a_Coolant) annotation(
    Line(points = {{-10, -40}, {-140, -40}}, color = {255, 0, 0}));
  connect(pipeCoolant.flowPort_b, port_b_Coolant) annotation(
    Line(points = {{10, -40}, {140, -40}}, color = {255, 0, 0}));
  connect(temperatureCoolantIn.flowPort, port_a_Coolant) annotation(
    Line(points = {{-100, -40}, {-140, -40}}, color = {255, 0, 0}));
  connect(teeJunctionVolumeAn.port_2, port_b_H2) annotation(
    Line(points = {{-120, 20}, {-120, 0}, {-140, 0}}, color = {0, 127, 255}));
  connect(teeJunctionVolumeAn.port_3, H2_sink.ports[1]) annotation(
    Line(points = {{-110, 30}, {-100, 30}, {-100, 62}, {-90, 62}}, color = {0, 127, 255}));
  connect(temperatureHeatCapacity.port, heatPort) annotation(
    Line(points = {{-50, -100}, {-50, -120}, {-20, -120}}, color = {191, 0, 0}));
  connect(thermalConductor.port_a, heatPort) annotation(
    Line(points = {{0, -80}, {0, -120}, {-20, -120}}, color = {191, 0, 0}));
  connect(heatCapacitor.port, heatPort) annotation(
    Line(points = {{30, -100}, {30, -120}, {-20, -120}}, color = {191, 0, 0}));
  connect(prescribedHeatFlow.port, heatPort) annotation(
    Line(points = {{80, -120}, {-20, -120}}, color = {191, 0, 0}));
  connect(teeJunctionVolumeCa.port_3, O2_sink.ports[1]) annotation(
    Line(points = {{80, 30}, {74, 30}, {74, 50}, {70, 50}}, color = {0, 127, 255}));
  connect(airResistance.port_b, teeJunctionVolumeCa.port_1) annotation(
    Line(points = {{90, 50}, {90, 40}}, color = {0, 127, 255}));
  connect(airResistance.port_a, relHumCaIn.port_b) annotation(
    Line(points = {{90, 70}, {90, 80}, {110, 80}}, color = {0, 127, 255}));
  connect(waterSrcCa.port_a, teeJunctionVolumeCa.port_2) annotation(
    Line(points = {{60, 10}, {90, 10}, {90, 20}}, color = {0, 127, 255}));
  connect(waterSrcCa.mFlowWat_FC, mFlowWat.y) annotation(
    Line(points = {{60, 18}, {68, 18}, {68, 30}, {42, 30}}, color = {0, 0, 127}));
  connect(h2Resistance.port_b, teeJunctionVolumeAn.port_1) annotation(
    Line(points = {{-120, 50}, {-120, 40}}, color = {0, 127, 255}));
  connect(h2Resistance.port_a, port_a_H2) annotation(
    Line(points = {{-120, 70}, {-120, 80}, {-140, 80}}, color = {0, 127, 255}));
  connect(realT.y, h2Resistance.T) annotation(
    Line(points = {{100, 130}, {-94, 130}, {-94, 80}, {-116, 80}, {-116, 72}}, color = {0, 0, 127}));
  connect(airResistance.T, realT.y) annotation(
    Line(points = {{86, 72}, {86, 130}, {100, 130}}, color = {0, 0, 127}));
  connect(temperatureCoolantOut.flowPort, port_b_Coolant) annotation(
    Line(points = {{100, -40}, {140, -40}}, color = {255, 0, 0}));
  connect(heatPort, waterSrcCa.heatport_a) annotation(
    Line(points = {{-20, -120}, {50, -120}, {50, 0}}, color = {191, 0, 0}));
  connect(realDT.y, airResistance.DT) annotation(
    Line(points = {{69, 120}, {82, 120}, {82, 72}}, color = {0, 0, 127}));
  connect(heatEx.port_b, relHumCaOut.port_a) annotation(
    Line(points = {{80, -8}, {120, -8}}, color = {0, 127, 255}));
  connect(heatEx.port_a, waterSrcCa.port_b) annotation(
    Line(points = {{60, -8}, {30, -8}, {30, 10}, {40, 10}}, color = {0, 127, 255}));
  connect(heatEx.heatport_a, heatPort) annotation(
    Line(points = {{70, -10}, {70, -120}, {-20, -120}}, color = {191, 0, 0}));
  connect(mFlowO2_sink.y, O2_sink.m_flow_in) annotation(
    Line(points = {{22, 58}, {50, 58}}, color = {0, 0, 127}));
  connect(currentSensor.i, H2_mflow.u) annotation(
    Line(points = {{0, 90}, {0, 80}, {-30, 80}}, color = {0, 0, 127}));
  connect(currentSensor.i, O2_mflow.u) annotation(
    Line(points = {{0, 90}, {0, 80}, {32, 80}}, color = {0, 0, 127}));
  annotation(
    Diagram(coordinateSystem(extent = {{-150, -150}, {150, 150}}, initialScale = 0.1)),
    Icon(coordinateSystem(extent = {{-150, -150}, {150, 150}}, initialScale = 0.1), graphics = {Line(origin = {20.1754, 1.92106}, points = {{0, 78}, {0, -80}, {0, -82}}), Rectangle(origin = {80, 0}, fillColor = {0, 178, 227}, pattern = LinePattern.None, fillPattern = FillPattern.Solid, extent = {{-20, 100}, {20, -100}}), Line(origin = {40.1315, 2}, points = {{0, 78}, {0, -80}, {0, -82}}), Line(origin = {0.219199, 1.92106}, points = {{0, 78}, {0, -80}, {0, -82}}), Line(origin = {-40.0001, 1.61404}, points = {{0, 78}, {0, -80}, {0, -82}}), Rectangle(origin = {-80, 0}, fillColor = {170, 0, 0}, pattern = LinePattern.None, fillPattern = FillPattern.Solid, extent = {{-20, 100}, {20, -100}}), Text(origin = {10, -54}, textColor = {255, 0, 0}, extent = {{-11, 6}, {11, -6}}, textString = "K"), Line(origin = {-20.0439, -0.307018}, points = {{0, 80}, {0, -80}, {0, -80}}), Rectangle(origin = {35, 54}, fillColor = {177, 177, 177}, fillPattern = FillPattern.Vertical, extent = {{-95, 26}, {25, -134}}), Text(origin = {-80, 6}, extent = {{-26, 24}, {26, -24}}, textString = "A"), Text(origin = {80, 6}, extent = {{-26, 24}, {26, -24}}, textString = "C")}),
    Documentation(info = "<html><head></head><body>
<p>Lumped (0-D) model of a proton exchange membrane (PEM) fuel cell stack with <code>N_FC_stack</code>
identical cells. The cell voltage is computed algebraically by
<a href=\"modelica://VirtualFCS.Electrochemical.Hydrogen.calculate_cell_voltage\">calculate_cell_voltage</a>
from the stack current, temperature, pressures, cathode stoichiometry and cathode relative humidity.
Gas consumption, product water, heat generation and heat removal by the coolant are computed from the
cell current.</p>

<h4>Connectors</h4>
<table>
<tr><td><code>pin_p</code>, <code>pin_n</code></td><td>Electrical terminals. The stack voltage <code>U_Z*N_FC_stack</code> [V] is imposed between them; <code>pin_n</code> is grounded inside the model.</td></tr>
<tr><td><code>port_a_H2</code>, <code>port_b_H2</code></td><td>Anode inlet and outlet (<code>Anode_Medium</code>, default H2).</td></tr>
<tr><td><code>port_a_Air</code>, <code>port_b_Air</code></td><td>Cathode inlet and outlet (<code>Cathode_Medium</code>, default moist air).</td></tr>
<tr><td><code>port_a_Coolant</code>, <code>port_b_Coolant</code></td><td>Coolant inlet and outlet (FluidHeatFlow, water).</td></tr>
<tr><td><code>heatPort</code></td><td>Thermal port of the stack mass (temperature <code>T_S</code> [K]).</td></tr>
</table>

<h4>Modelled effects</h4>
<ul>
<li>Cell voltage <code>U_Z = U_N - U_Akt - U_Ohm - U_Dif</code> (Nernst voltage minus activation, ohmic and mass-transport overpotentials) from <code>calculate_cell_voltage</code>.</li>
<li>Reactant consumption by Faraday's law: H2 molar flow <code>I_Z*N_FC_stack/(2F)</code>, O2 mass flow <code>I_Z*N_FC_stack*M_O2/(4F)</code>. Product water <code>nf_H2O_prod = nf_H2</code> [mol/s] is added to the cathode stream as vapour by <code>waterSrcCa</code>.</li>
<li>Heat generation <code>P_th = (U_LHV - U_Z)*I_Z*N_FC_stack</code> [W] with <code>U_LHV</code> = 1.253 V, applied to a lumped thermal mass <code>Cp_FC_stack*m_FC_stack</code> [J/K].</li>
<li>Heat transfer from the stack mass to the coolant (conductance <code>G</code> [W/K]), to the cathode gas (<code>heatEx</code>) and to the product water (<code>waterSrcCa</code>).</li>
<li>Anode and cathode pressure drop by <a href=\"modelica://VirtualFCS.Fluid.FlowResistanceTemp\">FlowResistanceTemp</a> and <a href=\"modelica://VirtualFCS.Fluid.FlowResistanceHumPoly\">FlowResistanceHumPoly</a>, evaluated at the coolant outlet temperature.</li>
<li>The cathode relative humidity <code>phi_Ca</code> used in the voltage model is a first-order lag (time constant <code>tau_H2O</code> [s]) of the mean of the inlet and outlet relative humidity; it is initialised in steady state.</li>
<li>Cathode stoichiometry <code>lambda_K</code> = O2 supplied / O2 consumed, limited to [eps, 100].</li>
<li>Oxygen partial pressure at the cathode inlet <code>p_O2</code> [Pa] = inlet pressure times O2 mole fraction.</li>
<li>Lower-heating-value efficiency <code>eta_FC_LHV = max(U_Z/U_LHV, 0)</code>.</li>
</ul>

<h4>Main assumptions and limitations</h4>
<ul>
<li>Uniform stack temperature <code>T_S</code>; all cells are identical.</li>
<li>Reacted H2 and O2 are removed by mass flow sinks at the composition of the adjacent junction volume. The cathode sink withdraws <code>O2_mflow/X_dryair</code>, so nitrogen is withdrawn together with oxygen (simplification). Water removed with that stream is re-added by <code>waterSrcCa</code> together with the product water.</li>
<li>The dry-air fraction <code>X_dryair</code> and the O2 mole fraction are derived from the water mass fraction of the cathode junction volume (<code>airResistance.Xw_in</code>).</li>
<li>The anode gas is not heated by the stack and remains at supply temperature.</li>
<li>Liquid water is not modelled, so the cathode relative humidity can exceed 1.</li>
<li>The coolant pressure drop model of <code>pipeCoolant</code> is only valid for water, since viscosity changes are neglected. Its nominal operating point is set by <code>pd_cool_nom</code> and <code>vflow_cool_nom</code>.</li>
<li>The simulation stops if <code>U_Z</code> &le; eps (overload); a warning is issued if <code>lambda_K</code> &lt; 1 (cathode undersupply).</li>
</ul>

<h4>Fixed internal geometry</h4>
<p>The layer thicknesses are protected parameters and cannot be modified from outside the class:
membrane <code>d_Mem</code> = 18 &mu;m, catalyst layer <code>d_CL</code> = 10 &mu;m,
gas-diffusion layer <code>d_GDL</code> = 200 &mu;m. These are published default values (Hahn 2023), not the values of the investigated stack.</p>

<h4>Default Physical Parameters</h4>
<table>
<tr><td><code>G</code></td><td>1e6 W/K</td></tr>
<tr><td><code>Cp_FC_stack</code></td><td>500 J/(kg K)</td></tr>
<tr><td><code>m_FC_stack</code></td><td>42 kg</td></tr>
<tr><td><code>m_coolant</code></td><td>10 kg</td></tr>
<tr><td><code>pd_cool_nom</code></td><td>24534 Pa</td></tr>
<tr><td><code>vflow_cool_nom</code></td><td>0.002618 m<sup>3</sup>/s</td></tr>
<tr><td><code>V_Ca</code></td><td>0.01 m<sup>3</sup></td></tr>
<tr><td><code>tau_H2O</code></td><td>20 s</td></tr>
</table>
<p>Electrochemical parameters (<code>j_0_ref</code>, <code>E_A</code>, <code>f_CL</code>, <code>r_el</code>,
<code>D_GDL_ref</code>, <code>D_CL_ref</code>, <code>A_FC_surf</code>, <code>N_FC_stack</code>) are described in
<a href=\"modelica://VirtualFCS.Electrochemical.Hydrogen.calculate_cell_voltage\">calculate_cell_voltage</a>.
The default values of this class are generic example values. A parameter set fitted to a specific stack is
used in <a href=\"modelica://VirtualFCS.Electrochemical.Hydrogen.FuelCellSystem\">FuelCellSystem</a>.</p>

<div>
<h4>References</h4>
<p>Catalyst-layer and GDL transport model after A. A. Kulikovsky, “A Physically-Based Analytical Polarization
Curve of a PEM Fuel Cell”, Journal of The Electrochemical Society 161(3) (2014), F263. DOI: 10.1149/2.028403jes</p>
<p>Model implementation based on <a href=\"https://link.springer.com/book/10.1007/978-3-658-42086-4\">Hahn, Sergei. (2023). Modellbasierte Betriebsstrategie für PEM-Brennstoffzellensysteme. 10.1007/978-3-658-42086-4</a></p>
<p>Water vapor activity modeled after <a href=\"https://iopscience.iop.org/article/10.1149/1.2085971\">T. E. Springer, T. A. Zawodzinski, and S. Gottesfeld. “Polymer Electrolyte Fuel Cell Model”. In: Journal of The Electrochemical Society 138.8 (Aug. 1991), p. 2334. DOI: 10.1149/1.2085971</a></p>
</div>

</body></html>"),
    experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.002));
end FuelCellStack;