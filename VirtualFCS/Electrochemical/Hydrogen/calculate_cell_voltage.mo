within VirtualFCS.Electrochemical.Hydrogen;

function calculate_cell_voltage
  "Cell voltage U_Z = U_N - U_Akt - U_Ohm - U_Dif from operating inputs."
  extends Modelica.Icons.Function;
  import Modelica.Units.SI;
  import Modelica.Constants;
  import Modelica.Math.*;
  import ModelicaServices.Machine;

  // Operating inputs (9; phi_ca and lambda_K used directly)
  input SI.Current I_Z "Cell current [A]";
  input SI.Pressure p_H2_A_ein "Anode inlet pressure [Pa]";
  input SI.Temperature T_S "Stack temperature [K]";
  input Real lambda_K(min=Modelica.Constants.eps) "Cathode stoichiometry [-]";
  input Real phi_ca(min=0) "Cathode relative humidity in voltage model [-]";
  input SI.Pressure p_ca_in "Cathode inlet pressure [Pa]";
  input SI.Pressure p_ca_out "Cathode outlet pressure [Pa]";
  input SI.Pressure p_O2 "Oxygen partial pressure at cathode inlet [Pa]";
  input SI.Temperature T_ca_in "Cathode inlet temperature [K]";

  // Parameters (defaults; d_CL, d_GDL, d_Mem differ from FuelCellStack)
  input SI.Area A_FC_surf = 0.024 "Active cell area [m^2]";
  input Real j_0_ref = 2130.8 "Reference exchange current density [A/m^3]";
  input SI.MolarEnergy E_A = 71477 "O2 reduction activation energy [J/mol]";
  input Real f_CL = 0.36693 "CL proton conductivity factor [-]";
  input Real r_el = 4.2738e-6 "Cell electrical area resistance [Ohm*m^2]";
  input SI.DiffusionCoefficient D_CL_ref = 3.3438e-8 "CL reference diffusion coefficient [m^2/s]";
  input SI.DiffusionCoefficient D_GDL_ref = 8.6266e-6 "GDL reference diffusion coefficient [m^2/s]";
  input SI.Thickness d_CL = 1e-5 "Catalyst layer thickness [m]";
  input SI.Thickness d_GDL = 2e-4 "GDL thickness [m]";
  input SI.Thickness d_Mem = 1.8e-5 "Membrane thickness [m]";
  input SI.CurrentDensity j_H2 = 13 "H2 diffusion current density [A/m^2]";
  input SI.MolarConcentration c_O2_ref = 7.36 "O2 reference concentration [mol/m^3]";
  input Real sigma_mem_material_param_a = 0.005139 "Membrane conductivity parameter a [S/cm]";
  input Real sigma_mem_material_param_b = 0.00326 "Membrane conductivity parameter b [S/cm]";

  output SI.Voltage U_Z "Total cell voltage [V]";
  output SI.Voltage U_N "Nernst voltage [V]";
  output SI.Voltage U_Akt "Activation overpotential [V]";
  output SI.Voltage U_Ohm "Ohmic overpotential [V]";
  output SI.Voltage U_Dif "Diffusion overpotential [V]";
  output SI.Voltage U_CL "CL mass-transport overpotential [V]";
  output SI.Voltage U_GDL "GDL mass-transport overpotential [V]";
  output SI.CurrentDensity j_Z "Cell current density [A/m^2]";

protected
  constant SI.Enthalpy G_0 = -237130 "Standard Gibbs free energy [J/mol]";
  constant SI.Temperature T0 = 298.15 "Standard temperature [K]";
  constant SI.MolarEntropy S_0 = -163.34 "Reaction entropy change [J/(mol*K)]";
  constant SI.Temperature T_ref = 353.15 "Reference temperature [K]";
  constant SI.Pressure p_ref = 101325 "Reference pressure [Pa]";
  constant SI.MolarEnergy D_CL_exp_coefficient = 17200 "D_CL exponent coefficient [J/mol]";
  constant Real eps = Machine.eps;
  Real alpha;
  SI.Voltage b;
  Real f_j;
  SI.CurrentDensity j_mod;
  SI.CurrentDensity j_sigma;
  Real j_0;
  Real lambda_w;
  Real sigma_30;
  Real sigma_Mem;
  Real sigma_CL;
  SI.MolarConcentration c_O2_ein;
  SI.CurrentDensity j_char;
  Real D_CL;
  Real D_GDL;
  Real beta;
  SI.CurrentDensity j_lim;
  Real cl_denom;
  Real gdl_arg;

algorithm
  j_Z := I_Z/A_FC_surf;

  alpha := 0.001678*T_S;
  b := (Constants.R*T_S)/(2*alpha*Constants.F);

  f_j := -(3*lambda_K*log(1 - min(1/lambda_K, 1 - eps)))/(2*(p_ca_in^2 + p_ca_in*p_ca_out + p_ca_out^2))*(p_ca_in^2 + p_ca_in*p_ca_out);
  j_mod := max(f_j*j_Z, 1e-3);

  j_0 := j_0_ref*exp(-(E_A/Constants.R)*(1/T_S - 1/T_ref));

  if phi_ca < 1 then
    lambda_w := 0.043 + 17.81*phi_ca - 39.85*phi_ca^2 + 36*phi_ca^3;
  else
    lambda_w := min(14 + 1.4*(phi_ca - 1), 16.8);
  end if;

  sigma_30 := (sigma_mem_material_param_a*max(lambda_w, 1) - sigma_mem_material_param_b)*100;
  sigma_Mem := max(exp(1268*(1/303 - 1/T_S))*sigma_30, sigma_30);
  sigma_CL := f_CL*sigma_Mem;

  j_sigma := max(sqrt(max(2*j_0*sigma_CL*b, eps)), eps);

  c_O2_ein := p_O2/(Constants.R*T_ca_in);
  j_char := sigma_CL*b/d_CL;

  D_CL := D_CL_ref*(T_S/T_ref)*exp(D_CL_exp_coefficient/Constants.R*(1/T_ref - 1/T_S));
  D_GDL := D_GDL_ref*(T_S/T_ref)^1.5*(p_ref/p_ca_in);

  beta := sqrt(max(2*j_mod/j_char, eps))/(1 + sqrt(max(1.12*j_mod/j_char, eps))*exp(sqrt(max(2*j_mod/j_char, eps)))) + (Constants.pi*j_mod/j_char)/(2 + j_mod/j_char);
  j_lim := (4*Constants.F*D_GDL*c_O2_ref/d_GDL);

  U_N := -G_0/(2*Constants.F) + (T_S - T0)*S_0/(2*Constants.F) + Constants.R*T_S/(2*Constants.F)*(log(p_H2_A_ein/p_ref) + 0.5*log(p_O2/p_ref));

  U_Akt := b*asinh(max(((j_mod + j_H2)/j_sigma)^2/max((2*(c_O2_ein/c_O2_ref)*(1 - exp(-(j_mod + j_H2)/(2*j_char)))), eps), eps));

  cl_denom := 1 - j_mod/(j_lim*c_O2_ein/c_O2_ref);
  gdl_arg := max(cl_denom, eps);
  U_GDL := -b*log(gdl_arg);

  U_CL := (sigma_CL*b^2)/(4*Constants.F*D_CL*c_O2_ein)*(j_mod/j_char - log(1 + (j_mod^2/(j_char^2*beta^2))))/cl_denom;

  U_Dif := U_CL + U_GDL;
  U_Ohm := (d_Mem/sigma_Mem + r_el)*j_Z;
  U_Z := U_N - U_Akt - U_Ohm - U_Dif;

  annotation(Inline=true, Documentation(info = "<html><head></head><body>
<p>Algebraic cell-voltage model of a PEM fuel cell, used by
<a href=\"modelica://VirtualFCS.Electrochemical.Hydrogen.FuelCellStack\">FuelCellStack</a> and
<a href=\"modelica://VirtualFCS.ComponentTesting.TestCellVoltageCalculation\">TestCellVoltageCalculation</a>.
Cathode stoichiometry and relative humidity are inputs; they are not computed inside the function.</p>

<h4>Operating inputs</h4>
<table>
<tr><td><code>I_Z</code></td><td>Cell current [A]</td></tr>
<tr><td><code>p_H2_A_ein</code></td><td>Anode inlet pressure [Pa]</td></tr>
<tr><td><code>T_S</code></td><td>Stack temperature [K]</td></tr>
<tr><td><code>lambda_K</code></td><td>Cathode stoichiometry [-]</td></tr>
<tr><td><code>phi_ca</code></td><td>Cathode relative humidity used for membrane hydration [-]</td></tr>
<tr><td><code>p_ca_in</code>, <code>p_ca_out</code></td><td>Cathode inlet and outlet pressure [Pa]</td></tr>
<tr><td><code>p_O2</code></td><td>Oxygen partial pressure at the cathode inlet [Pa]</td></tr>
<tr><td><code>T_ca_in</code></td><td>Cathode inlet temperature [K], used for the inlet O2 concentration</td></tr>
</table>

<h4>Equations</h4>
<p>Numerical guards (<code>max(..., eps)</code>) are omitted below.</p>
<pre>
j_Z    = I_Z/A_FC_surf                                         cell current density [A/m2]
alpha  = 0.001678*T_S ;  b = R*T_S/(2*alpha*F)                 Tafel slope [V]
f_j    = -3*lambda_K*ln(1 - 1/lambda_K)*(p_in^2 + p_in*p_out)
         / (2*(p_in^2 + p_in*p_out + p_out^2))
j_mod  = max(f_j*j_Z, 1e-3)                                    effective current density [A/m2]
j_0    = j_0_ref*exp(-E_A/R*(1/T_S - 1/T_ref)),  T_ref = 353.15 K
lambda_w = 0.043 + 17.81*phi - 39.85*phi^2 + 36*phi^3          (phi &lt; 1)
         = min(14 + 1.4*(phi - 1), 16.8)                         (phi &ge; 1)
sigma_30  = (a*max(lambda_w, 1) - b_s)*100                     [S/m], with a, b_s in S/cm
sigma_Mem = max(exp(1268*(1/303 - 1/T_S))*sigma_30, sigma_30)  membrane proton conductivity [S/m]
sigma_CL  = f_CL*sigma_Mem                                     CL proton conductivity [S/m]
j_sigma = sqrt(2*j_0*sigma_CL*b) ;  j_char = sigma_CL*b/d_CL
c_O2   = p_O2/(R*T_ca_in)                                      inlet O2 concentration [mol/m3]
D_CL   = D_CL_ref*(T_S/T_ref)*exp(17200/R*(1/T_ref - 1/T_S))
D_GDL  = D_GDL_ref*(T_S/T_ref)^1.5*(p_ref/p_ca_in),  p_ref = 101325 Pa
j_lim  = 4*F*D_GDL*c_O2_ref/d_GDL                              GDL limiting current density [A/m2]

U_N   = -G_0/(2F) + (T_S - T0)*S_0/(2F) + R*T_S/(2F)*(ln(p_H2_A_ein/p_ref) + 0.5*ln(p_O2/p_ref))
U_Akt = b*asinh( ((j_mod + j_H2)/j_sigma)^2
                 / (2*(c_O2/c_O2_ref)*(1 - exp(-(j_mod + j_H2)/(2*j_char)))) )
U_GDL = -b*ln(1 - j_mod/(j_lim*c_O2/c_O2_ref))
U_CL  = sigma_CL*b^2/(4*F*D_CL*c_O2)*(j_mod/j_char - ln(1 + j_mod^2/(j_char^2*beta^2)))
        / (1 - j_mod/(j_lim*c_O2/c_O2_ref))
U_Dif = U_CL + U_GDL
U_Ohm = (d_Mem/sigma_Mem + r_el)*j_Z
U_Z   = U_N - U_Akt - U_Ohm - U_Dif
</pre>
<p>with G_0 = -237130 J/mol, S_0 = -163.34 J/(mol K), T0 = 298.15 K and <code>beta</code> as defined in the code.
The water content <code>lambda_w</code> follows Springer et al. (1991).
The ohmic loss uses the actual current density <code>j_Z</code>; all other losses use <code>j_mod</code>.</p>

<h4>Parameters</h4>
<table>
<tr><td><code>A_FC_surf</code></td><td>Active cell area [m2]</td></tr>
<tr><td><code>j_0_ref</code></td><td>Volumetric exchange current density at T_ref [A/m3]</td></tr>
<tr><td><code>E_A</code></td><td>Activation energy of the oxygen reduction reaction [J/mol]</td></tr>
<tr><td><code>f_CL</code></td><td>Ratio of CL to membrane proton conductivity [-]</td></tr>
<tr><td><code>r_el</code></td><td>Area-specific electrical resistance of the cell [Ohm m2]</td></tr>
<tr><td><code>D_CL_ref</code>, <code>D_GDL_ref</code></td><td>Effective O2 diffusion coefficients of CL and GDL at T_ref [m2/s]</td></tr>
<tr><td><code>d_CL</code>, <code>d_GDL</code>, <code>d_Mem</code></td><td>Thickness of catalyst layer, gas-diffusion layer and membrane [m]</td></tr>
<tr><td><code>j_H2</code></td><td>Hydrogen crossover current density [A/m2]</td></tr>
<tr><td><code>c_O2_ref</code></td><td>Reference O2 concentration [mol/m3]</td></tr>
<tr><td><code>sigma_mem_material_param_a</code>, <code>_b</code></td><td>Coefficients of the linear membrane conductivity law [S/cm]</td></tr>
</table>
<p><b>Note:</b> the default values of <code>d_CL</code>, <code>d_GDL</code> and <code>d_Mem</code> differ from the
protected values in <code>FuelCellStack</code>, which always passes its own values. The defaults apply only when the
function is called without these arguments.</p>

<h4>References</h4>
<p>A. A. Kulikovsky, “A Physically-Based Analytical Polarization Curve of a PEM Fuel Cell”, Journal of The
Electrochemical Society 161(3) (2014), F263. DOI: 10.1149/2.028403jes (catalyst-layer and GDL transport, activation term).</p>
<p>S. Hahn, Modellbasierte Betriebsstrategie für PEM-Brennstoffzellensysteme (2023),
DOI: 10.1007/978-3-658-42086-4.</p>
<p>T. E. Springer, T. A. Zawodzinski, S. Gottesfeld, “Polymer Electrolyte Fuel Cell Model”, Journal of The
Electrochemical Society 138(8) (1991), 2334. DOI: 10.1149/1.2085971 (membrane water content).</p>
</body></html>"));
end calculate_cell_voltage;
