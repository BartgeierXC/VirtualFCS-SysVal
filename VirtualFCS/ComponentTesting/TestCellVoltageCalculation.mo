within VirtualFCS.ComponentTesting;

model TestCellVoltageCalculation
  "Algebraic unit test of calculate_cell_voltage that mirrors the Python FCSStackModel.simulate_model input derivation."
  extends Modelica.Icons.Example;
  import Modelica.Constants.F;
  import ModelicaServices.Machine.eps;

  // ------------------------------------------------------------------
  // Stack calibration parameters (identical to BaPParameterSet / TestFuelCell)
  // ------------------------------------------------------------------
  parameter Real N_FC_stack = 275 "Number of cells in stack";
  parameter Modelica.Units.SI.Area A_FC_surf = 0.0305 "Active cell area [m^2]";
  parameter Real j_0_ref = 2.721837e2 "Reference exchange current density [A/m^3]";
  parameter Modelica.Units.SI.MolarEnergy E_A = 4.417500e4 "Activation energy [J/mol]";
  parameter Real f_CL = 9.672601e-1 "CL conductivity factor [-]";
  parameter Real r_el = 6.606254e-6 "Area resistance [Ohm*m^2]";
  parameter Modelica.Units.SI.DiffusionCoefficient D_GDL_ref = 5.388195e-5 "GDL reference D [m^2/s]";
  parameter Modelica.Units.SI.DiffusionCoefficient D_CL_ref = 4.970848e-6 "CL reference D [m^2/s]";
  // Published default thicknesses (Hahn 2023). The validation results of the publication were computed with confidential stack values.
  parameter Modelica.Units.SI.Thickness d_CL(displayUnit = "um") = 10e-6 "CL thickness [m]";
  parameter Modelica.Units.SI.Thickness d_GDL(displayUnit = "um") = 200e-6 "GDL thickness [m]";
  parameter Modelica.Units.SI.Thickness d_Mem(displayUnit = "um") = 18e-6 "Membrane thickness [m]";

  // ------------------------------------------------------------------
  // Constants matching FuelCellStackModel (Python)
  // ------------------------------------------------------------------
  constant Real X_O2 = 0.21 "Oxygen mole fraction in dry air [-]";
  constant Modelica.Units.SI.Pressure p_amb = 95000 "Ambient pressure [Pa]";

  // ------------------------------------------------------------------
  // Operating-condition schedule (same OpCons_data.txt pipeline as TestFuelCell).
  // Column order MUST match data_source.input_variables in the validation config:
  //   1 I.S [A]                    -> current
  //   2 p.Si.A [barg]              -> anode inlet pressure
  //   3 p.Si.C [barg]              -> cathode inlet pressure
  //   4 p.So.C [barg]              -> cathode outlet pressure
  //   5 cathode_inlet_rel_hum [%]  -> cathode inlet relative humidity
  //   6 T.So.CL [degC]             -> coolant outlet temperature
  //   7 T.Si.CL [degC]             -> coolant inlet temperature
  //   8 Stoic.S.C                  -> measured cathode stoichiometry
  // ------------------------------------------------------------------
  Modelica.Blocks.Sources.CombiTimeTable opCons(
    extrapolation = Modelica.Blocks.Types.Extrapolation.HoldLastPoint,
    fileName = Modelica.Utilities.Files.loadResource("modelica://VirtualFCS.Resources.LuT/OpCons_data.txt"),
    smoothness = Modelica.Blocks.Types.Smoothness.ConstantSegments,
    tableName = "op_cons", verboseRead = false, tableOnFile = true,
    table = [0, 0, 0, 0, 0, 0, 0, 0, 0; 1, 0, 0, 0, 0, 0, 0, 0, 0]) annotation(
    Placement(transformation(origin = {-70, 0}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Continuous.FirstOrder OpCons[8](each T = 10, each y_start = eps) annotation(
    Placement(transformation(origin = {-30, 0}, extent = {{-8, -8}, {8, 8}})));

  // ------------------------------------------------------------------
  // Decoded operating conditions (mirrors notebook 13 preprocessing)
  // ------------------------------------------------------------------
  Modelica.Units.SI.Current I = OpCons[1].y "Stack current [A]";
  Modelica.Units.SI.Pressure p_An_in = Modelica.Units.Conversions.from_bar(OpCons[2].y) + p_amb "Anode inlet pressure [Pa]";
  Modelica.Units.SI.Pressure p_Ca_in = Modelica.Units.Conversions.from_bar(OpCons[3].y) + p_amb "Cathode inlet pressure [Pa]";
  Modelica.Units.SI.Pressure p_Ca_out = Modelica.Units.Conversions.from_bar(OpCons[4].y) + p_amb "Cathode outlet pressure [Pa]";
  Real RH_in = OpCons[5].y/100 "Cathode inlet relative humidity [-]";
  Modelica.Units.SI.Temperature T_S = Modelica.Units.Conversions.from_degC((OpCons[6].y + OpCons[7].y)/2) "Stack temperature = coolant in/out average [K]";
  Real lambda_K = max(OpCons[8].y, eps) "Measured cathode stoichiometry [-]";

  // ------------------------------------------------------------------
  // Water / humidity balance (identical to FCSStackModel.simulate_model)
  // ------------------------------------------------------------------
  Modelica.Units.SI.MolarFlowRate n_o2_con = abs(I)*N_FC_stack/(4*F) "O2 consumed [mol/s]";
  Modelica.Units.SI.MolarFlowRate n_o2_in = n_o2_con*lambda_K "O2 supplied [mol/s]";
  Modelica.Units.SI.MolarFlowRate n_air_in = n_o2_in/X_O2 "Dry air supplied [mol/s]";
  Modelica.Units.SI.MolarFlowRate n_H2O_prod = n_o2_con*2 "Product water [mol/s]";
  Modelica.Units.SI.MolarFlowRate n_air_out = n_air_in - n_o2_con "Dry air out [mol/s]";
  Real log10_p_sat = 10.20389 - 1733.926/(T_S - 273.15 + 233.665) "Antoine correlation (log10 of p_sat in Pa)";
  Modelica.Units.SI.Pressure p_sat = 10.0^log10_p_sat "Saturation pressure at T_S [Pa]";
  Modelica.Units.SI.MolarFlowRate n_H2O_in = RH_in*n_air_in/(p_Ca_in/p_sat - RH_in) "Inlet water [mol/s]";
  Modelica.Units.SI.MolarFlowRate n_H2O_out = n_H2O_in + n_H2O_prod "Outlet water [mol/s]";
  Real RH_out = n_H2O_out/(n_H2O_out + n_air_out)*p_Ca_out/p_sat "Cathode outlet relative humidity [-]";
  Modelica.Units.SI.Pressure p_O2 = (p_Ca_in - RH_in*p_sat)*X_O2 "Oxygen partial pressure at cathode inlet [Pa]";

  // ------------------------------------------------------------------
  // Voltage results (per cell)
  // ------------------------------------------------------------------
  Modelica.Units.SI.Voltage U_Z "Cell voltage [V]";
  Modelica.Units.SI.Voltage U_N "Nernst voltage [V]";
  Modelica.Units.SI.Voltage U_Akt "Activation overpotential [V]";
  Modelica.Units.SI.Voltage U_Ohm "Ohmic overpotential [V]";
  Modelica.Units.SI.Voltage U_Dif "Diffusion overpotential [V]";
  Modelica.Units.SI.Voltage U_CL "CL mass-transport overpotential [V]";
  Modelica.Units.SI.Voltage U_GDL "GDL mass-transport overpotential [V]";
  Modelica.Units.SI.CurrentDensity j_Z "Cell current density [A/m^2]";
equation
  connect(opCons.y, OpCons.u) annotation(
    Line(points = {{-59, 0}, {-39, 0}}, color = {0, 0, 127}, thickness = 0.5));
  (U_Z, U_N, U_Akt, U_Ohm, U_Dif, U_CL, U_GDL, j_Z) = Electrochemical.Hydrogen.calculate_cell_voltage(
    I_Z = abs(I),
    p_H2_A_ein = p_An_in,
    T_S = T_S,
    lambda_K = lambda_K,
    phi_ca = RH_out,
    p_ca_in = p_Ca_in,
    p_ca_out = p_Ca_out,
    p_O2 = p_O2,
    T_ca_in = T_S,
    A_FC_surf = A_FC_surf,
    j_0_ref = j_0_ref,
    E_A = E_A,
    f_CL = f_CL,
    r_el = r_el,
    D_CL_ref = D_CL_ref,
    D_GDL_ref = D_GDL_ref,
    d_CL = d_CL,
    d_GDL = d_GDL,
    d_Mem = d_Mem);
  annotation(
    Documentation(info = "<html><head></head><body>
<p>Pure algebraic unit test of
<a href=\"modelica://VirtualFCS.Electrochemical.Hydrogen.calculate_cell_voltage\">calculate_cell_voltage</a>.
Unlike <a href=\"modelica://VirtualFCS.ComponentTesting.TestFuelCell\">TestFuelCell</a>, this model contains
<b>no fluid, thermal or electrical balance-of-plant</b>. The operating inputs to the cell-voltage function are
derived exactly as in the Python reference model <code>FCSStackModel.simulate_model</code>:</p>
<ul>
<li>cathode stoichiometry <code>lambda_K</code> is taken directly from the measured <code>Stoic.S.C</code> column
(not back-calculated from air mass flow);</li>
<li>stack temperature <code>T_S</code> is the coolant in/out average, and the cathode-inlet temperature used for the
oxygen concentration is set equal to <code>T_S</code>;</li>
<li>the saturation pressure uses the same Antoine correlation as Python;</li>
<li>the cathode-outlet relative humidity <code>RH_out</code> (which drives membrane conductivity) is obtained from the
same analytic molar water balance as Python;</li>
<li>the oxygen partial pressure uses <code>(p_ca_in - RH_in*p_sat)*X_O2</code> with a constant dry-air O2 fraction.</li>
</ul>
<p>Purpose: isolate the cell-voltage equations from the balance-of-plant input conditioning so that, when driven by the
same operating points, this harness should reproduce the ~1% cell-voltage error of the Python validation. Any residual
difference is attributable to the electrochemical equations themselves rather than the surrounding fluid/thermal system.</p>
<p>Operating points are read from the interface file <code>OpCons_data.txt</code> (see
<a href=\"modelica://VirtualFCS.Utilities.SystemControl\">SystemControl</a>, &quot;Operating-point input&quot;), which must
then contain the 8 data columns listed in the declaration of <code>opCons</code>: current [A], anode inlet, cathode inlet
and cathode outlet pressure [bar(g)], cathode inlet relative humidity [%], coolant outlet and inlet temperature [&deg;C],
and the measured cathode stoichiometry [-].</p>
</body></html>"),
    experiment(StartTime = 0, StopTime = 3000, Tolerance = 0.0001, Interval = 1),
    __OpenModelica_commandLineOptions = "--matchingAlgorithm=PFPlusExt --indexReductionMethod=dynamicStateSelection -d=initialization,NLSanalyticJacobian",
    __OpenModelica_simulationFlags(s = "dassl", lv = "LOG_STDOUT,LOG_ASSERT,LOG_STATS", variableFilter = ".*"));
end TestCellVoltageCalculation;
