within VirtualFCS.Utilities;
type Volume_standard_litre_flow_rate = Real (final quantity="Volume flow", final unit="Nl/min")
  "Volume flow in standard litres per min" annotation(
  Documentation(info = "<html><head></head><body>
<p>Volume flow rate in standard litres per minute [Nl/min] (non-SI unit).
In <a href=\"modelica://VirtualFCS.Fluid.FcHumidityExchanger\">FcHumidityExchanger</a> it refers to dry air at 0 &deg;C and 1.01325 bar;
1 Nl/min corresponds to 1/60000 m3/s at standard conditions.</p>
</body></html>"));
