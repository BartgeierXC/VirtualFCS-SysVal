within VirtualFCS.Fluid;

package ValveCharacteristics "Opening-to-relative-Kv functions for VirtualFCS valves"
  extends Modelica.Icons.FunctionsPackage;
  annotation(
    Documentation(info = "<html>
<p>Functions mapping normalized valve opening <code>pos</code> (0 = closed, 1 = fully open)
to a relative flow coefficient <code>rc</code>, for use as
<code>redeclare function valveCharacteristic</code> on
<a href=\"modelica://Modelica.Fluid.Valves.ValveCompressible\">ValveCompressible</a>
and the other MSL valve models.</p>
</html>"));
end ValveCharacteristics;
