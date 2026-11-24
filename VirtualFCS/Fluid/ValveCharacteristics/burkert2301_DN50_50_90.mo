within VirtualFCS.Fluid.ValveCharacteristics;

function burkert2301_DN50_50_90
  "Relative Kv of Bürkert Type 2301 DN50 globe control valve (seat 50 mm, actuator 90 mm)"
  extends Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.baseFun;
protected
  constant Real pos_table[:] = {0, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0}
    "Normalized stroke (fraction of full stroke)";
  constant Real Kv_table[size(pos_table, 1)] = {0, 0.85, 1.1, 1.7, 2.6, 3.8, 5.4, 7.7, 11.4, 16.0, 21.5, 28.0}
    "Kv for water from DS2301 section 7.1 [m3/h]";
  constant Real Kv_full = 28.0 "Kvs; set the same value on ValveCompressible.Kv";
algorithm
  rc := Modelica.Math.Vectors.interpolate(pos_table, Kv_table, pos)/Kv_full;
  annotation(
    Documentation(info = "<html>
<p>Relative flow coefficient of a B&uuml;rkert Type 2301 pneumatically actuated 2/2-way globe control valve,
DN50, seat size 50 mm, actuator size &Oslash;90 mm (the &quot;50_90&quot; in the class name). Linear interpolation
of the Kv values of datasheet DS2301, section 7.1 (Kv for water at 5&hellip;100 % stroke, flow under the seat,
measured according to DIN EN 60534-2-4). The datasheet characteristic is equal-percentage.</p>
<p>Input <code>pos</code> is the normalised stroke (0 = closed, 1 = full stroke). Output
<code>rc = Kv(pos)/28</code>, with K<sub>vs</sub> = 28 m3/h. Between 0 and 5 % stroke the table is extended
linearly to <code>Kv = 0</code> at <code>pos = 0</code> (not a datasheet value).</p>
<p>Use with <a href=\"modelica://Modelica.Fluid.Valves.ValveCompressible\">ValveCompressible</a> and keep
<code>Kv = 28</code> on the instance (as <code>Kv_p_valve</code> in SubSystemAirCMP/MFC):</p>
<pre>
Modelica.Fluid.Valves.ValveCompressible valve(
  CvData = Modelica.Fluid.Types.CvTypes.Kv,
  Kv = 28,
  redeclare function valveCharacteristic =
    VirtualFCS.Fluid.ValveCharacteristics.burkert2301_DN50_50_90);
</pre>
<p>Kv values are for water. The compressible mass flow is computed by ValveCompressible (Y, Fxt).
Datasheet limit: maximum operating pressure 7 bar(g) for this seat/actuator combination.</p>
<p>Reference: B&uuml;rkert, Datasheet Type 2301 (DS2301), DTS 1000112932, version AK.</p>
</html>"));
end burkert2301_DN50_50_90;
