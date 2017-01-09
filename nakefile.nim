import os
import nake

const
  NimCache = "nimcache/"

  MainModuleName = "random_art"
  BinaryName = "random_art"
  BinaryOption = "-o:" & BinaryName


task "debug", "Build in Debug mode":
  if direShell(nimExe, "c", "-d:debug", BinaryOption, MainModuleName):
    echo("Debug built!")


task "release", "Build in Rlease mode":
  if direShell(nimExe, "c", "-d:release", BinaryOption, MainModuleName):
    echo("Release built!")


task "clean", "Cleans up compiled output":
  removeDir(NimCache)
  removeFile(BinaryName)


task defaultTask, "[debug task]":
  runTask("debug")

