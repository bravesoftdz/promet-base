{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit prepair;

{$warn 5023 off : no warning about unused units}
interface

uses
  uQSPositionFrame, uRawdata, uRepairOptions, urepairimageframe, 
  urepairimages, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('prepair', @Register);
end.
