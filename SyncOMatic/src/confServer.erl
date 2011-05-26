-module(confServer).
-export([getServerRootPath/0,getArchiveDir/0]).

getServerRootPath()->
    "./BB".
%the directory must exist !!!
getArchiveDir()->
    "./Archive".
