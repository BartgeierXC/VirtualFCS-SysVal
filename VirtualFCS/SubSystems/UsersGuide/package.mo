within VirtualFCS.SubSystems;

package UsersGuide "User information for the SubSystems sub-library"
  extends Modelica.Icons.Information;
  annotation(
    Documentation(info = "<html><head></head><body>
<p>Subsystem models encapsulate the balance of plant of a fuel cell system. Subsystem variants can be exchanged
(plug and play) to study their effect on overall system performance. Available classes:</p>
<ul>
<li><a href=\"modelica://VirtualFCS.SubSystems.FuelCellSubSystems\">FuelCellSubSystems</a>: container of the hydrogen, air and cooling subsystems.</li>
<li><a href=\"modelica://VirtualFCS.SubSystems.Air\">Air</a>: <a href=\"modelica://VirtualFCS.SubSystems.Air.SubSystemAirCMP\">SubSystemAirCMP</a> (compressor) and <a href=\"modelica://VirtualFCS.SubSystems.Air.SubSystemAirMFC\">SubSystemAirMFC</a> (mass-flow controlled).</li>
<li><a href=\"modelica://VirtualFCS.SubSystems.Cooling\">Cooling</a>: <a href=\"modelica://VirtualFCS.SubSystems.Cooling.SubSystemCoolingTST\">SubSystemCoolingTST</a> (heat exchanger to a test-stand house coolant circuit) and <a href=\"modelica://VirtualFCS.SubSystems.Cooling.SubSystemCoolingFix\">SubSystemCoolingFix</a> (prescribed coolant supply temperature).</li>
<li><a href=\"modelica://VirtualFCS.SubSystems.Hydrogen\">Hydrogen</a>: <a href=\"modelica://VirtualFCS.SubSystems.Hydrogen.SubSystemHydrogenTST\">SubSystemHydrogenTST</a> (pressure-controlled supply with recirculation blower).</li>
</ul>
<p>All subsystems read their set points from an <code>outer</code>
<a href=\"modelica://VirtualFCS.Utilities.SystemControl\">SystemControl</a> instance.</p>
</body></html>"));
end UsersGuide;