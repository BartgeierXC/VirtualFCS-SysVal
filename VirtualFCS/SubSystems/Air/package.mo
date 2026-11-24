within VirtualFCS.SubSystems;

package Air "Subsystems related to the air line."
  extends Modelica.Icons.VariantsPackage;
  annotation(
    Documentation(info = "<html><head></head><body>
<p>Air supply subsystems: <a href=\"modelica://VirtualFCS.SubSystems.Air.SubSystemAirCMP\">SubSystemAirCMP</a> with an electrically driven compressor and <a href=\"modelica://VirtualFCS.SubSystems.Air.SubSystemAirMFC\">SubSystemAirMFC</a> with a prescribed air mass flow. Both include a charge-air cooler, a membrane humidifier with bypass and a back-pressure valve.</p>
</body></html>"));
end Air;
