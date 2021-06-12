dotnet clean -c Release ..\..\..\Oqtane.sln 
dotnet build -c Release ..\..\..\Oqtane.sln
copy ..\..\bin\Release\net5.0\de-DE\Oqtane.Client.resources.dll ..\..\..\Oqtane.Server\net5.0\de-DE\Oqtane.Client.resources.dll
..\..\..\Oqtane.Package\nuget.exe pack Oqtane.Client.de-DE.nuspec
pause 

