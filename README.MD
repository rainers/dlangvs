dlangvs is a Visual Studio solution for building the reference D compiler and its runtime library.
See https://github.com/dlang.

- integrates dmd, druntime and phobos into one solution

- uses dmd.vcxproj from the dmd source tree, but adds new project files for druntime and phobos.
  These provide source file navigation, but still build through the win64.mak makefiles.
  
  One known issue: the zlib library built with phobos does not rebuild correctly when
  switching between platforms Win32 and x64. You have to manually delete the object files in
  phobos/etc/c/zlib.

- the projects use wildcards to populate the project tree, but that doesn't place them in folders
  automatically. Rebuild project rebuild_vcxfilters to regenerate the vcxproj.filters files and
  reload the solution.

- project dmd_test runs the dmd testsuite. This includes bash scripts that need an appropriate
  environment to work. "Git for Windows" comes with such an environment, so its default installation
  path ("C:\Program Files\git\bin") is searched to enable running these tests. If it is not found
  shell script tests are skipped.

- to run druntime and phobos unittests, select the "Unittest Debug" configuration.

- little attempt was made to also support OMF libraries, they are only built for dmd models
  -m64 and -m32mscoff.
