within VirtualFCS.Utilities;

block CalcPulsedMean
  Modelica.Blocks.Interfaces.RealInput u annotation(
    Placement(visible = true, transformation(origin = {-120, 0}, extent = {{-20, -20}, {20, 20}}, rotation = 0), iconTransformation(origin = {-120, 0}, extent = {{-20, -20}, {20, 20}}, rotation = 0)));
  Modelica.Blocks.Interfaces.RealOutput y annotation(
    Placement(visible = true, transformation(origin = {110, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {110, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Logical.Hysteresis hysteresis(uHigh = 2*threshold, uLow = threshold)  annotation(
    Placement(visible = true, transformation(origin = {-70, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Logical.Switch switch annotation(
    Placement(visible = true, transformation(origin = {0, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));

  parameter Real threshold = 0.001;
  Modelica.Blocks.Sources.Constant constant1(k = 1)  annotation(
    Placement(visible = true, transformation(origin = {-50, 50}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.Constant constant0(k = 0) annotation(
    Placement(visible = true, transformation(origin = {-50, -50}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));

  Real time_inc;
  Real pulse_inc;
equation
// In order to calculate mean only over time periods where u > threshold, use time_inc.
  der(time_inc) = switch.y;
  der(pulse_inc) = u;
  y = pulse_inc / (time_inc + 1);

  connect(u, hysteresis.u) annotation(
    Line(points = {{-120, 0}, {-82, 0}}, color = {0, 0, 127}));
  connect(hysteresis.y, switch.u2) annotation(
    Line(points = {{-58, 0}, {-12, 0}}, color = {255, 0, 255}));
  connect(constant0.y, switch.u3) annotation(
    Line(points = {{-38, -50}, {-30, -50}, {-30, -8}, {-12, -8}}, color = {0, 0, 127}));
  connect(constant1.y, switch.u1) annotation(
    Line(points = {{-38, 50}, {-30, 50}, {-30, 8}, {-12, 8}}, color = {0, 0, 127}));
  annotation(
    Icon(graphics = {Rectangle(fillColor = {50, 50, 50}, fillPattern = FillPattern.Solid, extent = {{-100, 100}, {100, -100}}), Text(origin = {-8, 121}, textColor = {0, 0, 255}, extent = {{-54, 17}, {54, -17}}, textString = "%name")}, coordinateSystem(initialScale = 0.1)),
    Documentation(info = "<html><head></head><body>
<p>Approximate mean of the input <code>u</code> over the periods in which <code>u</code> is active:</p>
<pre>y = integral(u dt) / (integral(s dt) + 1 s)</pre>
<p><code>s</code> is 1 while a hysteresis on <code>u</code> is on and 0 otherwise. The hysteresis switches on above
<code>2*threshold</code> and off below <code>threshold</code>. Note that <code>u</code> itself is integrated over the
whole simulation time. The 1 s added to the denominator avoids a division by zero at the start; it biases the result
towards 0 for short active periods.</p>
</body></html>"));
end CalcPulsedMean;
