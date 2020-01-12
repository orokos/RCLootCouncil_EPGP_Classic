local MAJOR, MINOR = "LibGroupInSpecT-1.1", 0

if not LibStub then error(MAJOR.." requires LibStub") end
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end
