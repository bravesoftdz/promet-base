{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit pmessaging;

{$warn 5023 off : no warning about unused units}
interface

uses
  pmimemessages, uMessageEdit, uMessageFrame, uMimeMessages, uViewMessage, 
  uMessageRoute, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('pmessaging', @Register);
end.
