LibraryName = "SampraharReturns"
ApplicationName = "SampraharReturns"
NativeDirectory = "native/"
AndroidDirectory = "android/"
Override = false

--Jkr.BuildSystem.CreateLuaLibraryEnvironment(LibraryName, NativeDirectory, Override)
Jkr.BuildSystem.CreateAndroidEnvironment(ApplicationName, "android/", LibraryName)
