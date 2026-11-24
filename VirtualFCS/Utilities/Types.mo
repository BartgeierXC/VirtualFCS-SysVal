within VirtualFCS.Utilities;

package Types
  type opModeFC = enumeration(
    LHV
      "Energy balance based on Lower Heating Value",
    HHV
      "Energy balance based on Higher Heating Value")
  "Enumeration defining calculation of energy balance" annotation (Evaluate=true,
  Documentation(info="<html>
  <p>The following calculation alternatives are available:</p>
  <dl>
  <dt><code><strong>LHV</strong></code></dt>
    <dd>Water produced by the electrochemical reaction is steam and hence its enthalpy is neglected in the energy balance</dd>
  <dt><code><strong>HHV</strong></code></dt>
    <dd>Water produced by the electrochemical reaction is liquid which means the enthalpy of steam needs to be added to the energy balance</dd>
  </dl>
  </html>"));
  
  type opModeHTX = enumeration(fumatech_H50N "Effectiveness of water transfer from data sheet", fumatech_H100N "Effectiveness of water transfer from data sheet", fumatech_H100N_meas "Effectiveness of water transfer from measurements sheet", User_Parameter "Effectiveness of water transfer given by an user parameter") "Calculation mode of water transfer efficiency"
  annotation(
      Evaluate = true,
      Documentation(info = "<html>
    <p>The following calculation alternatives are available:</p>
    <dl>
    <dt><code><strong>fumatech_H50N</strong></code></dt>
      <dd>Water transfer effectiveness from a fit to data-sheet values; inputs are the dry-side standard volume flow and the dry-side inlet temperature.</dd>
    <dt><code><strong>fumatech_H100N</strong></code></dt>
      <dd>Water transfer effectiveness from a fit to data-sheet values; input is the dry-side standard volume flow.</dd>
    <dt><code><strong>fumatech_H100N_meas</strong></code></dt>
      <dd>Water transfer effectiveness from a fit to measurements; input is the dry-side standard volume flow.</dd>
    <dt><code><strong>User_Parameter</strong></code></dt>
      <dd>Constant water transfer effectiveness given by a user parameter.</dd>
    </dl>
    </html>"));
  annotation(
    Icon(graphics = {Rectangle(lineColor = {200, 200, 200}, fillColor = {248, 248, 248}, fillPattern = FillPattern.HorizontalCylinder, extent = {{-100, -100}, {100, 100}}, radius = 25), Polygon(origin = {-12.17, -23}, fillColor = {85, 255, 255}, pattern = LinePattern.None, fillPattern = FillPattern.Sphere, points = {{12.167, 65}, {14.167, 93}, {36.167, 89}, {24.167, 20}, {4.167, -30}, {14.167, -30}, {24.167, -30}, {24.167, -40}, {-5.833, -50}, {-15.833, -30}, {4.167, 20}, {12.167, 65}}, smooth = Smooth.Bezier), Polygon(origin = {2.74, 1.67}, fillColor = {0, 255, 255}, pattern = LinePattern.None, fillPattern = FillPattern.Sphere, points = {{49.2597, 22.3327}, {31.2597, 24.3327}, {7.2597, 18.3327}, {-26.7403, 10.3327}, {-46.7403, 14.3327}, {-48.7403, 6.3327}, {-32.7403, 0.3327}, {-6.7403, 4.3327}, {33.2597, 14.3327}, {49.2597, 14.3327}, {49.2597, 22.3327}}, smooth = Smooth.Bezier)}));
end Types;
