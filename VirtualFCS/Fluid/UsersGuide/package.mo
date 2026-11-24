within VirtualFCS.Fluid;

package UsersGuide "User information for the Fluid sub-library"
  extends Modelica.Icons.Information;
  annotation(
    Documentation(info = "<html><head></head><body>
<p>Fluid components of the VirtualFCS library that supplement the Modelica Standard Library:</p>
<table border=\"1\">
<tr><th>Name</th><th>Description</th></tr>
<tr><td><a href=\"modelica://VirtualFCS.Fluid.FcHumidityExchanger\">FcHumidityExchanger</a></td><td>Static membrane humidifier (water and sensible heat transfer between two moist-air streams)</td></tr>
<tr><td><a href=\"modelica://VirtualFCS.Fluid.FcWaterSource\">FcWaterSource</a></td><td>Adds fuel cell product water to a moist-air stream, coupled to the stack thermal mass</td></tr>
<tr><td><a href=\"modelica://VirtualFCS.Fluid.PortHtxHandler\">PortHtxHandler</a></td><td>Auxiliary two-port with imposed pressure drop, outlet temperature and water addition</td></tr>
<tr><td><a href=\"modelica://VirtualFCS.Fluid.FlowResistanceHumPoly\">FlowResistanceHumPoly</a></td><td>Temperature- and dew-point-dependent flow resistance (stack cathode)</td></tr>
<tr><td><a href=\"modelica://VirtualFCS.Fluid.FlowResistanceTemp\">FlowResistanceTemp</a></td><td>Temperature-dependent flow resistance (stack anode)</td></tr>
<tr><td><a href=\"modelica://VirtualFCS.Fluid.PolyMover\">PolyMover</a></td><td>Map-based prescribed-flow mover with electrical power demand</td></tr>
<tr><td><a href=\"modelica://VirtualFCS.Fluid.CompressorPoly\">CompressorPoly</a></td><td>Air compressor (PolyMover with compression heating)</td></tr>
<tr><td><a href=\"modelica://VirtualFCS.Fluid.ARBPoly\">ARBPoly</a></td><td>Anode recirculation blower (PolyMover without compression heating)</td></tr>
<tr><td><a href=\"modelica://VirtualFCS.Fluid.IsentropicEnthalpyRise\">IsentropicEnthalpyRise</a></td><td>Outlet enthalpy rise from isentropic compression and mover power</td></tr>
<tr><td><a href=\"modelica://VirtualFCS.Fluid.PumpElectricDCFluidHFPoly\">PumpElectricDCFluidHFPoly</a></td><td>Electrically driven coolant pump (FluidHeatFlow)</td></tr>
<tr><td><a href=\"modelica://VirtualFCS.Fluid.ValveCharacteristics\">ValveCharacteristics</a></td><td>Opening-to-relative-Kv functions of the valves used in the subsystems</td></tr>
</table>
</body></html>"));
end UsersGuide;