within VirtualFCS.Fluid.ValveCharacteristics;

function coolantMixValveTST
  "Relative Kv of the TST house-coolant mixing valve (11 segments, 1.25 turns)"
  extends Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.baseFun;
protected
  constant Real pos_table[:] = {0.006, 0.109, 0.212, 0.310, 0.405, 0.509, 0.613, 0.710, 0.806, 0.917, 1.0}
    "Normalized stem opening (fr_Mix_CL / 100)";
  constant Real Kv_table[size(pos_table, 1)] = {0.01, 0.722, 1.056, 2.263, 3.177, 4.162, 5.048, 5.644, 6.155, 6.613, 6.627}
    "Measured Kv [m3/h]";
  constant Real Kv_full = 6.627 "Fully open Kv; keep Valve.Kv1 = 6.627/3600 m3/s";
algorithm
  rc := Modelica.Math.Vectors.interpolate(pos_table, Kv_table, pos)/Kv_full;
  annotation(
    Documentation(info = "<html>
<p>Linear interpolation of the measured house-coolant mixing-valve Kv curve
(11 segments, 1.25 turns). Input <code>pos</code> is the normalized stem opening
(0 = closed, 1 = fully open), matching <code>fr_Mix_CL</code>/100.
Output <code>rc = Kv(pos)/6.627</code>.</p>
<p>The FluidHeatFlow valve has no replaceable characteristic. Feed <code>rc</code>
as <code>valve.y</code> with <code>LinearCharacteristic = true</code> and
<code>Kv1 = 6.627/3600</code> m<sup>3</sup>/s so that
<code>Kv &approx; rc&nbsp;Kv1</code>.</p>
</html>"));
end coolantMixValveTST;
