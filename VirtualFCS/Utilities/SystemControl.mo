within VirtualFCS.Utilities;

block SystemControl
  extends Modelica.Blocks.Icons.Block;
  outer Modelica.Fluid.System system "System properties";
  parameter Modelica.Units.SI.Time tau = 1 "Cutoff time constant for lowpass filter [s]";
  parameter Boolean purge_active = false "Enable purging";
  parameter Boolean external_control = false "= true, if the control subsystems take their set points from systemControl instead of their internal control laws";
  parameter Boolean speed_control = false "= true, if (with external_control) the blower and pump speeds are taken directly from systemControl";
  
  parameter Boolean tableOnFile=true
    "= true, if table is defined on file or in function usertab"
    annotation (Dialog(group="Table data definition"));
  parameter Real table[:, :] = fill(0.0, 0, 2)
    "Table matrix (time = first column; e.g., table=[0, 0; 1, 1; 2, 4])"
    annotation (Dialog(group="Table data definition",enable=not tableOnFile));
  parameter String tableName="op_cons"
    "Table name on file or in function usertab (see docu)"
    annotation (Dialog(group="Table data definition",enable=tableOnFile));
  parameter String fileName=Modelica.Utilities.Files.loadResource("modelica://VirtualFCS.Resources.LuT/OpCons_data.txt") "File where matrix is stored"
    annotation (Dialog(
      group="Table data definition",
      enable=tableOnFile,
      loadSelector(filter="Text files (*.txt);;MATLAB MAT-files (*.mat)",
          caption="Open file in which table is present")));
  parameter Modelica.Blocks.Types.Smoothness smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments
    "Smoothness of table interpolation"
    annotation (Dialog(group="Table data interpretation"));
  parameter Integer tableSize[2] =
    if tableOnFile then
      ReadTextTableSize(fileName, tableName)
    else
      {size(table, 1), size(table, 2)}
    "Rows/columns of table including time column";

  parameter Integer nSignals = tableSize[2] - 1
    "Number of data columns (excludes time)";
  parameter Integer columns[nSignals] =
    {i + 1 for i in 1:nSignals}
    "CombiTimeTable output columns (2 .. nColumns)";

  Modelica.Blocks.Sources.CombiTimeTable loadCycle(extrapolation = Modelica.Blocks.Types.Extrapolation.HoldLastPoint, fileName = fileName, smoothness = smoothness, table = table, tableName = tableName, tableOnFile = tableOnFile, columns = columns) annotation(
    Placement(transformation(origin = {-30, 0}, extent = {{-10, -10}, {10, 10}})));

  Modelica.Units.SI.Current I(min=0, max=610);
  Modelica.Units.SI.Pressure p_An(min=0, max=2.5e5);
  Modelica.Units.SI.Pressure p_Cl(min=0, max=10e5);
  Modelica.Units.SI.Temperature T_Cl(min=273.15, max=373.15);
  Modelica.Units.SI.MassFlowRate mf_air;
  Modelica.Units.NonSI.AngularVelocity_rpm w_arb(min=0, max=6000);
  Modelica.Units.NonSI.AngularVelocity_rpm w_cmp;
  Real P_cwp(min=0, max=1);
  Real x_p_Ca(min=0.01, max=0.99);
  Real x_w_Ca(min=0, max=1);
  Real x_Cl(min=0, max=1);
  Real step_no;
  Modelica.Blocks.Continuous.FirstOrder opCons[nSignals](each T = tau)  annotation(
    Placement(transformation(origin = {30, 0}, extent = {{-10, -10}, {10, 10}})));
equation
  assert(nSignals >= 8, "SystemControl requires at least 8 data columns (nSignals >= 8) for named outputs I..P_cwp");
  I = if opCons[1].y < 1 then 0 else opCons[1].y;
  p_An = opCons[2].y;
  w_arb = opCons[3].y;
  x_p_Ca = noEvent(min(max(opCons[4].y, 0.01), 0.99));
  x_w_Ca = noEvent(min(max(opCons[5].y, 0.0), 1.0));
  w_cmp = opCons[6].y;
  mf_air = opCons[6].y;
  x_Cl = noEvent(min(max(opCons[7].y, 0.0), 1.0));
  P_cwp = noEvent(min(max(opCons[8].y, 0.0), 1.0));
  if nSignals > 8 then
    p_Cl = noEvent(max(opCons[9].y, system.p_ambient));
  else
    p_Cl = system.p_ambient;
  end if;
  if nSignals > 9 then
    T_Cl = noEvent(max(Modelica.Units.Conversions.from_degC(opCons[10].y), 283.15));
  else
    T_Cl = system.T_ambient;
  end if;
  if nSignals > 10 then
    step_no = opCons[11].y;
  else
    step_no = -1;
  end if;
  connect(loadCycle.y, opCons.u) annotation(
    Line(points = {{-18, 0}, {18, 0}}, color = {0, 0, 127}, thickness = 0.5));
  annotation(
    Documentation(info = "<html><head></head><body>
<p>Block that provides the operating point set points of the fuel cell system as named outputs. The set points are read by the subsystems via <code>outer Utilities.SystemControl systemControl</code>.</p>
<p>The set points come from a time table (<code>loadCycle</code>). With <code>tableOnFile = true</code> the table <code>tableName</code> is read from <code>fileName</code>; otherwise the matrix <code>table</code> is used. The number of data columns (<code>nSignals</code>) is derived at translation from the file via <code>ReadTextTableSize</code>, or from <code>size(table, 2)</code> when <code>tableOnFile = false</code>. At least 8 data columns are required. All columns are filtered by first-order lags with time constant <code>tau</code> (<code>opCons</code>).</p>

<h4>Outputs</h4>
<table>
<tr><td><code>I = opCons[1].y</code></td><td>Stack current set point [A]; values below 1 A are set to 0</td></tr>
<tr><td><code>p_An = opCons[2].y</code></td><td>Anode pressure set point [Pa]</td></tr>
<tr><td><code>w_arb = opCons[3].y</code></td><td>Recirculation blower speed [rpm]</td></tr>
<tr><td><code>x_p_Ca = opCons[4].y</code></td><td>Closing fraction of the cathode back-pressure valve [-] (valve opening = <code>1 - x_p_Ca</code>), limited to 0.01..0.99</td></tr>
<tr><td><code>x_w_Ca = opCons[5].y</code></td><td>Opening of the humidifier valve [-], limited to 0..1; the bypass valve opens by <code>1 - x_w_Ca</code></td></tr>
<tr><td><code>w_cmp = opCons[6].y</code></td><td>Compressor speed [rpm]</td></tr>
<tr><td><code>mf_air = opCons[6].y</code></td><td>Air mass flow set point [kg/s] for mass-flow-controlled air subsystems; shares the column with <code>w_cmp</code></td></tr>
<tr><td><code>x_Cl = opCons[7].y</code></td><td>Closing fraction of the house coolant valve [-] (valve opening = <code>1 - x_Cl</code>), limited to 0..1</td></tr>
<tr><td><code>P_cwp = opCons[8].y</code></td><td>Coolant pump command [-], limited to 0..1</td></tr>
<tr><td><code>p_Cl = opCons[9].y</code></td><td>Coolant boundary pressure [Pa], at least <code>system.p_ambient</code>; <code>system.p_ambient</code> if the column is missing</td></tr>
<tr><td><code>T_Cl = opCons[10].y</code></td><td>Coolant boundary temperature, given in &deg;C and converted to K, at least 283.15 K; <code>system.T_ambient</code> if the column is missing</td></tr>
<tr><td><code>step_no = opCons[11].y</code></td><td>Operating point number; -1 if the column is missing</td></tr>
</table>
<p>The declared <code>min</code>/<code>max</code> attributes of the outputs are: <code>I</code> 0&ndash;610 A, <code>p_An</code> 0&ndash;2.5e5 Pa, <code>p_Cl</code> 0&ndash;10e5 Pa, <code>T_Cl</code> 273.15&ndash;373.15 K, <code>w_arb</code> 0&ndash;6000 rpm. They are not physical limits of the hardware.</p>

<h4>Operating-point input (OpCons)</h4>
<p>Operating points are supplied as a Modelica text table named <code>op_cons</code>
(<code>float op_cons(nrows, ncols)</code>, first column = time [s]). By default the file
<code>modelica://VirtualFCS/Resources/LuT/OpCons_data.txt</code> is used. This file is an interface: external
software overwrites it, so its content and column layout change with the use case. The column layout must
match the structure of the simulated model. For example, a compressor-based air subsystem needs a compressor
speed, while a mass-flow-controlled one needs an air mass flow. A model can instead reference a dedicated file
with the same table format (e.g. <code>OpCons_data_TestFuelCell.txt</code>) via <code>fileName</code>.</p>

<h4>Control switches</h4>
<p><code>purge_active</code>, <code>external_control</code> and <code>speed_control</code> are currently not read by any class of the library. To be completed: intended use of these switches.</p>
</body></html>"), Icon(
    coordinateSystem(preserveAspectRatio=true,
      extent={{-100.0,-100.0},{100.0,100.0}}),
      graphics={
    Polygon(lineColor={192,192,192},
      fillColor={192,192,192},
      fillPattern=FillPattern.Solid,
      points={{-80.0,90.0},{-88.0,68.0},{-72.0,68.0},{-80.0,90.0}}),
    Line(points={{-80.0,68.0},{-80.0,-80.0}},
      color={192,192,192}),
    Line(points={{-90.0,-70.0},{82.0,-70.0}},
      color={192,192,192}),
    Polygon(lineColor={192,192,192},
      fillColor={192,192,192},
      fillPattern=FillPattern.Solid,
      points={{90.0,-70.0},{68.0,-62.0},{68.0,-78.0},{90.0,-70.0}}),
    Rectangle(lineColor={255,255,255},
      fillColor={255,215,136},
      fillPattern=FillPattern.Solid,
      extent={{-48.0,-50.0},{2.0,70.0}}),
    Line(points={{-48.0,-50.0},{-48.0,70.0},{52.0,70.0},{52.0,-50.0},{-48.0,-50.0},{-48.0,-20.0},{52.0,-20.0},{52.0,10.0},{-48.0,10.0},{-48.0,40.0},{52.0,40.0},{52.0,70.0},{2.0,70.0},{2.0,-51.0}})}));
end SystemControl;
