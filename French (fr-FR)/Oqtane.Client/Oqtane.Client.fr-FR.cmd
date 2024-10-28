dotnet build -c Release ..\Oqtane.sln
mkdir ..\Oqtane.Server\bin\Debug\net8.0\fr-FR
copy ..\Oqtane.Server\bin\Release\net8.0\fr-FR\Oqtane.Client.resources.dll ..\Oqtane.Server\bin\Debug\net8.0\fr-FR\Oqtane.Client.resources.dll
..\Oqtane.Package\nuget.exe pack Oqtane.Client.fr-FR.nuspec
pause
