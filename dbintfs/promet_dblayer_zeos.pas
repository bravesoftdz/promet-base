{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit promet_dblayer_zeos;

interface

uses
  uZeosDBDM, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('promet_dblayer_zeos', @Register);
end.
