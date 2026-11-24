within VirtualFCS.Fluid;

model CompressorPoly
  extends PolyMover(useCompressionEnergy = true);

  annotation(
    Documentation(info = "<html><head></head><body>
<p><a href=\"modelica://VirtualFCS.Fluid.PolyMover\">PolyMover</a> with <code>useCompressionEnergy = true</code>: the outlet gas
is heated by isentropic compression plus the share <code>(1 - eta_el)</code> of the map power. Used as the air compressor
in <a href=\"modelica://VirtualFCS.SubSystems.Air.SubSystemAirCMP\">SubSystemAirCMP</a>.</p>
</body></html>"));
end CompressorPoly;
