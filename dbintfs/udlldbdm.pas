{*******************************************************************************
  Copyright (C) Christian Ulrich info@cu-tec.de

  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or commercial alternative
  contact us for more information

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  MA 02111-1307, USA.
Created 01.06.2006
*******************************************************************************}
unit udlldbdm;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, db, uBaseDBInterface, uBaseDbClasses,
  uBaseDatasetInterfaces,syncobjs;
type
  TUnprotectedDataSet = class(TDataSet);

  { TZeosDBDM }

  { TDLLDBDM }

  TDLLDBDM = class(TBaseDBModule)
  public
    constructor Create(AOwner : TComponent;FType : string);
    destructor Destroy;override;
    function SetProperties(aProp : string;Connection : TComponent = nil) : Boolean;override;
    function CreateDBFromProperties(aProp: string): Boolean; override;
    function IsSQLDB : Boolean;override;
    function GetNewDataSet(aTable : TBaseDBDataSet;aConnection : TComponent = nil;MasterData : TDataSet = nil;aTables : string = '') : TDataSet;override;
    function GetNewDataSet(aSQL : string;aConnection : TComponent = nil;MasterData : TDataSet = nil;aOrigtable : TBaseDBDataSet = nil) : TDataSet;override;
    procedure DestroyDataSet(DataSet : TDataSet);override;
    function Ping(aConnection : TComponent) : Boolean;override;
    function DateToFilter(aValue : TDateTime) : string;override;
    function DateTimeToFilter(aValue : TDateTime) : string;override;
    function GetUniID(aConnection : TComponent = nil;Generator : string = 'GEN_SQL_ID';AutoInc : Boolean = True) : Variant;override;
    procedure StreamToBlobField(Stream : TStream;DataSet : TDataSet;Fieldname : string);override;
    procedure BlobFieldToStream(DataSet: TDataSet; Fieldname: string;
      dStream: TStream;aSize : Integer = -1); override;
    function GetErrorNum(e: EDatabaseError): Integer; override;
    procedure DeleteExpiredSessions;override;
    function GetNewConnection: TComponent;override;
    function QuoteField(aField: string): string; override;
    procedure Disconnect(aConnection : TComponent);override;
    function StartTransaction(aConnection : TComponent;ForceTransaction : Boolean = False): Boolean;override;
    function CommitTransaction(aConnection : TComponent): Boolean;override;
    function RollbackTransaction(aConnection : TComponent): Boolean;override;
    function TableExists(aTableName : string;aConnection : TComponent = nil;AllowLowercase: Boolean = False) : Boolean;override;
    function TriggerExists(aTriggerName: string; aConnection: TComponent=nil;
       AllowLowercase: Boolean=False): Boolean; override;
    function GetDBType: string; override;
    function CreateTrigger(aTriggerName: string; aTableName: string;
      aUpdateOn: string; aSQL: string;aField : string = ''; aConnection: TComponent=nil): Boolean;
      override;
    function DropTable(aTableName : string) : Boolean;override;
    function FieldToSQL(aName : string;aType : TFieldType;aSize : Integer;aRequired : Boolean) : string;
    function GetColumns(TableName : string) : TStrings;override;
  end;

implementation

{ TDLLDBDM }

constructor TDLLDBDM.Create(AOwner: TComponent; FType: string);
begin
  inherited Create(AOwner);
end;

destructor TDLLDBDM.Destroy;
begin
  inherited Destroy;
end;

function TDLLDBDM.SetProperties(aProp: string; Connection: TComponent): Boolean;
begin
  Result:=inherited SetProperties(aProp, Connection);
end;

function TDLLDBDM.CreateDBFromProperties(aProp: string): Boolean;
begin
  Result:=inherited CreateDBFromProperties(aProp);
end;

function TDLLDBDM.IsSQLDB: Boolean;
begin

end;

function TDLLDBDM.GetNewDataSet(aTable: TBaseDBDataSet;
  aConnection: TComponent; MasterData: TDataSet; aTables: string): TDataSet;
begin
end;

function TDLLDBDM.GetNewDataSet(aSQL: string; aConnection: TComponent;
  MasterData: TDataSet; aOrigtable: TBaseDBDataSet): TDataSet;
begin
end;

procedure TDLLDBDM.DestroyDataSet(DataSet: TDataSet);
begin

end;

function TDLLDBDM.Ping(aConnection: TComponent): Boolean;
begin

end;

function TDLLDBDM.DateToFilter(aValue: TDateTime): string;
begin
  Result:=inherited DateToFilter(aValue);
end;

function TDLLDBDM.DateTimeToFilter(aValue: TDateTime): string;
begin
  Result:=inherited DateTimeToFilter(aValue);
end;

function TDLLDBDM.GetUniID(aConnection: TComponent; Generator: string;
  AutoInc: Boolean): Variant;
begin

end;

procedure TDLLDBDM.StreamToBlobField(Stream: TStream; DataSet: TDataSet;
  Fieldname: string);
begin
  inherited StreamToBlobField(Stream, DataSet, Fieldname);
end;

procedure TDLLDBDM.BlobFieldToStream(DataSet: TDataSet; Fieldname: string;
  dStream: TStream; aSize: Integer);
begin
  inherited BlobFieldToStream(DataSet, Fieldname, dStream, aSize);
end;

function TDLLDBDM.GetErrorNum(e: EDatabaseError): Integer;
begin
  Result:=inherited GetErrorNum(e);
end;

procedure TDLLDBDM.DeleteExpiredSessions;
begin
  inherited DeleteExpiredSessions;
end;

function TDLLDBDM.GetNewConnection: TComponent;
begin

end;

function TDLLDBDM.QuoteField(aField: string): string;
begin
  Result:=inherited QuoteField(aField);
end;

procedure TDLLDBDM.Disconnect(aConnection: TComponent);
begin

end;

function TDLLDBDM.StartTransaction(aConnection: TComponent;
  ForceTransaction: Boolean): Boolean;
begin

end;

function TDLLDBDM.CommitTransaction(aConnection: TComponent): Boolean;
begin

end;

function TDLLDBDM.RollbackTransaction(aConnection: TComponent): Boolean;
begin

end;

function TDLLDBDM.TableExists(aTableName: string; aConnection: TComponent;
  AllowLowercase: Boolean): Boolean;
begin

end;

function TDLLDBDM.TriggerExists(aTriggerName: string; aConnection: TComponent;
  AllowLowercase: Boolean): Boolean;
begin
  Result:=inherited TriggerExists(aTriggerName, aConnection, AllowLowercase);
end;

function TDLLDBDM.GetDBType: string;
begin
  Result:=inherited GetDBType;
end;

function TDLLDBDM.CreateTrigger(aTriggerName: string; aTableName: string;
  aUpdateOn: string; aSQL: string; aField: string; aConnection: TComponent
  ): Boolean;
begin
  Result:=inherited CreateTrigger(aTriggerName, aTableName, aUpdateOn, aSQL,
    aField, aConnection);
end;

function TDLLDBDM.DropTable(aTableName: string): Boolean;
begin

end;

function TDLLDBDM.FieldToSQL(aName: string; aType: TFieldType; aSize: Integer;
  aRequired: Boolean): string;
begin

end;

function TDLLDBDM.GetColumns(TableName: string): TStrings;
begin

end;

end.


