within VirtualFCS.UsersGuide.ReleaseNotes;

class Version_2_1_0_sysval
  extends VirtualFCS.UsersGuide.ReleaseNotes;
  annotation(Documentation(info = "<html><head></head><body><p>VirtualFCS-SysVal 2.1.0-sysval is based on the development state 2.1.0-dev of VirtualFCS after its release v2.0.0. It is not an official VirtualFCS release. The top-level package keeps the name <code>VirtualFCS</code> and the version annotation 2.1.0-dev.</p><ul><li>Extended for the PEM fuel cell system of the accompanying publication: stack, hydrogen supply with anode recirculation, air supply with compressor or mass flow controller, membrane humidifier, cathode back-pressure valve and coolant loop with heat exchanger.</li><li>Contains the parameter set of the second iteration of the validation process. The parameter set of the first iteration is provided as the patch file VirtualFCS-SysVal_iteration1.patch in the repository.</li><li>Uses the default membrane parameters of Hahn (2023).</li><li>Developed and tested with OpenModelica 1.26.1, Modelica Standard Library 4.0.0 and Buildings 10.0.0.</li></ul></body></html>"));
end Version_2_1_0_sysval;
