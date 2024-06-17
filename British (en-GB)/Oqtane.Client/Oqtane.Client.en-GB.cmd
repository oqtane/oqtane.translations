dotnet build -c Release ..\Oqtane.sln
mkdir ..\Oqtane.Server\bin\Debug\net7.0\en-GB
copy ..\Oqtane.Server\bin\Release\net7.0\en-GB\Oqtane.Client.resources.dll ..\Oqtane.Server\bin\Debug\net7.0\en-GB\Oqtane.Client.resources.dll
..\Oqtane.Package\nuget.exe pack Oqtane.Client.en-GB.nuspec
pause 