within VirtualFCS.Utilities;

function ReadTextTableSize
  "Read [nrows, ncols] from a Modelica table text file (float/double name(n,m))"
  input String fileName "Table file path";
  input String tableName "Table name in file";
  output Integer dim[2] "Dimensions {nrows, ncols} including time column";
protected
  String line;
  Boolean endOfFile;
  Integer i;
  Integer idx;
  Integer nextIndex;
  String key = tableName + "(";
  Boolean found = false;
algorithm
  dim := {0, 0};
  // Header is near the top; avoid scanning huge data sections
  i := 1;
  while i <= 20 and not found loop
    (line, endOfFile) := Modelica.Utilities.Streams.readLine(fileName, i);
    if endOfFile and Modelica.Utilities.Strings.isEmpty(line) then
      i := 21;
    else
      idx := Modelica.Utilities.Strings.find(line, key);
      if idx > 0 then
        (dim[1], nextIndex) := Modelica.Utilities.Strings.scanInteger(
          line,
          startIndex=idx + Modelica.Utilities.Strings.length(key),
          unsigned=true,
          message=" while reading nrows of table \"" + tableName + "\" from \"" + fileName + "\"");
        idx := Modelica.Utilities.Strings.find(line, ",", startIndex=nextIndex);
        assert(idx > 0, "Expected comma in table size declaration: " + line);
        (dim[2], nextIndex) := Modelica.Utilities.Strings.scanInteger(
          line,
          startIndex=idx + 1,
          unsigned=true,
          message=" while reading ncols of table \"" + tableName + "\" from \"" + fileName + "\"");
        found := true;
      else
        i := i + 1;
      end if;
    end if;
  end while;
  assert(found, "Did not find table size declaration for \"" + tableName + "\" in \"" + fileName + "\" (expected float/double " + tableName + "(nrows,ncols))");
  annotation(Documentation(info="<html>
<p>Parses the Modelica text table header used by <code>CombiTimeTable</code>, e.g.</p>
<pre>float op_cons(7465,9)</pre>
<p><code>Modelica.Utilities.Streams.readMatrixSize</code> only supports MATLAB MAT files.</p>
<p>Only the first 20 lines of the file are searched for the header. The function asserts if no header is found.</p>
</html>"));
end ReadTextTableSize;
