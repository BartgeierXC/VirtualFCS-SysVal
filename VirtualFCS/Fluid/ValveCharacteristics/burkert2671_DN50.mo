within VirtualFCS.Fluid.ValveCharacteristics;

function burkert2671_DN50
  "Relative Kv of Bürkert Type 2671 DN50 centric butterfly valve"
  extends Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.baseFun;
protected
  constant Real pos_table[:] = {0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0}
    "Normalized disc opening (fraction of 90 deg)";
  constant Real Kv_table[size(pos_table, 1)] = {0, 1, 3.4, 9.2, 19.9, 34.3, 54.2, 63.2, 103.1, 134, 193.5}
    "Kv from DS2671 section 5.3 [m3/h]";
  constant Real Kv_full = 193.5 "Fully open Kv; set the same value on ValveCompressible.Kv";
algorithm
  rc := Modelica.Math.Vectors.interpolate(pos_table, Kv_table, pos)/Kv_full;
  annotation(
    Documentation(info = "<html>
<p>Linear interpolation of the Bürkert Type 2671 DN50 (2\") Kv curve from datasheet DS2671,
section 5.3. Input <code>pos</code> is the normalized disc opening
(0 = closed, 1 = 90&deg; fully open). Output <code>rc = Kv(pos)/193.5</code>.</p>
<p>Use with <a href=\"modelica://Modelica.Fluid.Valves.ValveCompressible\">ValveCompressible</a>:</p>
<pre>
Modelica.Fluid.Valves.ValveCompressible valve(
  CvData = Modelica.Fluid.Types.CvTypes.Kv,
  Kv = 193.5,
  redeclare function valveCharacteristic =
    VirtualFCS.Fluid.ValveCharacteristics.burkert2671_DN50);
</pre>
<p>Keep <code>Kv = 193.5</code> on the valve instance. A different <code>Kv</code> scales the
whole curve; it does not select another nominal diameter (other DNs have a different shape).</p>
<p>The datasheet recommends control use between 30&deg; and 90&deg; (<code>pos</code> 0.3&hellip;1.0).
Kv values are for water; compressible mass flow is still computed by ValveCompressible (Y, Fxt).</p>
</html>"));
end burkert2671_DN50;
