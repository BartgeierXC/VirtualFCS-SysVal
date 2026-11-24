within VirtualFCS.Fluid;

model ARBPoly
  extends PolyMover(useCompressionEnergy = false);
  annotation(
    Documentation(info = "<html><head></head><body>
<p><a href=\"modelica://VirtualFCS.Fluid.PolyMover\">PolyMover</a> with <code>useCompressionEnergy = false</code>: the
enthalpy passes through unchanged. Used as the anode recirculation blower in
<a href=\"modelica://VirtualFCS.SubSystems.Hydrogen.SubSystemHydrogenTST\">SubSystemHydrogenTST</a>.</p>
</body></html>"));
end ARBPoly;
