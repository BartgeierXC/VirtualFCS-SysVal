within VirtualFCS;

package ComponentTesting
  extends Modelica.Icons.Package;
  annotation(
    Documentation(info = "<html><head></head><body>
<p>Test and verification models for individual components and subsystems. <a href=\"modelica://VirtualFCS.ComponentTesting.TestFuelCellSystem\">TestFuelCellSystem</a> is the reference system simulation used for regression checks. Most tests read their operating points from the interface file <code>OpCons_data.txt</code>; the expected column layout is given in the documentation of each test (see also <a href=\"modelica://VirtualFCS.Utilities.SystemControl\">SystemControl</a>).</p>
</body></html>"));
end ComponentTesting;
