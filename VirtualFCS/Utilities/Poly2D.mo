within VirtualFCS.Utilities;

model Poly2D
  extends Modelica.Blocks.Interfaces.SI2SO;

  parameter Real c[:,:];

  function Poly2D
    input Real x;
    input Real y;
    input Real c[:, :]; // Coefficient matrix
    output Real f;
  protected
    Integer nx = size(c, 1);
    Integer ny = size(c, 2);
  algorithm
    f := 0;
    for i in 1:nx loop
      for j in 1:ny loop
        f := f + c[i, j] * x^(i-1) * y^(j-1);
      end for;
    end for;
  end Poly2D;
  
equation
  y = Poly2D(u1, u2, c);
annotation(
    Documentation(info = "<html><head></head><body>
<p>Two-input polynomial block:</p>
<pre>y = sum_{i=1..size(c,1)} sum_{j=1..size(c,2)} c[i,j]*u1^(i-1)*u2^(j-1)</pre>
<p>Rows of <code>c</code> correspond to powers of <code>u1</code>, columns to powers of <code>u2</code>.
The units of inputs, output and coefficients are defined by the calling map (see e.g.
<a href=\"modelica://VirtualFCS.Fluid.PolyMover\">PolyMover</a>).</p>
</body></html>"),
    Icon(graphics = {Line(points = {{-60, 40}, {-60, -40}, {60, -40}, {60, 40}, {30, 40}, {30, -40}, {-30, -40}, {-30, 40}, {-60, 40}, {-60, 20}, {60, 20}, {60, 0}, {-60, 0}, {-60, -20}, {60, -20}, {60, -40}, {-60, -40}, {-60, 40}, {60, 40}, {60, -40}}), Line(points = {{0, 40}, {0, -40}}), Line(points = {{-60, 40}, {-30, 20}}), Line(points = {{-30, 40}, {-60, 20}}), Rectangle(origin = {2.3077, 0}, fillColor = {255, 215, 136}, fillPattern = FillPattern.Solid, extent = {{-62.3077, 0}, {-32.3077, 20}}), Rectangle(origin = {2.3077, 0}, fillColor = {255, 215, 136}, fillPattern = FillPattern.Solid, extent = {{-62.3077, -20}, {-32.3077, 0}}), Rectangle(origin = {2.3077, 0}, fillColor = {255, 215, 136}, fillPattern = FillPattern.Solid, extent = {{-62.3077, -40}, {-32.3077, -20}}), Rectangle(fillColor = {255, 215, 136}, fillPattern = FillPattern.Solid, extent = {{-30, 20}, {0, 40}}), Rectangle(fillColor = {255, 215, 136}, fillPattern = FillPattern.Solid, extent = {{0, 20}, {30, 40}}), Rectangle(origin = {-2.3077, 0}, fillColor = {255, 215, 136}, fillPattern = FillPattern.Solid, extent = {{32.3077, 20}, {62.3077, 40}})}));
end Poly2D;
