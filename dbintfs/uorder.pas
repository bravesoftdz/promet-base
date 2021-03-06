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
unit uOrder;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, uBaseDbClasses, db, uBaseApplication,
  uBaseERPDBClasses, uMasterdata, uPerson, Variants, uAccounting
  ,uBaseDatasetInterfaces;
type
  TOrderTyp = class(TBaseDBDataSet)
  public
    procedure DefineFields(aDataSet : TDataSet);override;
  end;

  { TOrderList }

  TOrderList = class(TBaseERPList,IBaseHistory)
  private
    FHistory : TBaseHistory;
    FOrderTyp: TOrdertyp;
    FOrigID: String;
    function GetHistory: TBaseHistory;
    function GetOrderTyp: TOrdertyp;
  protected
    function GetTextFieldName: string;override;
    function GetNumberFieldName : string;override;
    function GetBookNumberFieldName : string;override;
    function GetStatusFieldName : string;override;
    function GetCommissionFieldName: string;override;
  public
    constructor CreateEx(aOwner: TComponent; DM: TComponent; aConnection: TComponent=nil;
      aMasterdata: TDataSet=nil); override;
    destructor Destroy; override;
    function CreateTable: Boolean; override;
    function GetStatusIcon: Integer; override;
    procedure Open; override;
    procedure Select(aID : string);overload;
    function SelectFromCommission(aNumber : string) : Boolean;
    procedure OpenItem(AccHistory: Boolean=True); override;
    procedure DefineFields(aDataSet : TDataSet);override;
    property History : TBaseHistory read FHistory;
    property OrderType : TOrdertyp read GetOrderTyp;
    function SelectOrderType : Boolean;
  end;
  TOrderQMTestDetails = class(TBaseDBDataSet)
  public
    procedure DefineFields(aDataSet : TDataSet);override;
  end;
  TOrderQMTest = class(TBaseDBDataSet)
  private
    FDetails: TOrderQMtestDetails;
  public
    constructor CreateEx(aOwner : TComponent;DM : TComponent=nil;aConnection : TComponent = nil;aMasterdata : TDataSet = nil);override;
    destructor Destroy;override;
    function CreateTable : Boolean;override;
    procedure DefineFields(aDataSet : TDataSet);override;
    property Details : TOrderQMtestDetails read FDetails;
  end;
  TOrder = class;
  TRepairProblems = class(TBaseDBDataSet)
    procedure DefineFields(aDataSet : TDataSet);override;
  end;
  TOrderRepairDetail = class(TBaseDbDataSet)
    procedure DefineFields(aDataSet : TDataSet);override;
  end;
  TRepairImageLinks = class(TLinks)
  public
    procedure FillDefaults(aDataSet : TDataSet);override;
  end;
  TOrderRepairImages = class(TBaseDbDataSet)
    procedure DefineFields(aDataSet : TDataSet);override;
    procedure FDSDataChange(Sender: TObject; Field: TField);
  private
    FDetail: TOrderRepairDetail;
    FHistory: TBaseHistory;
    FStatus : string;
    FImages: TImages;
    FLinks: TRepairImageLinks;
    FDS : TDataSource;
  public
    constructor CreateEx(aOwner: TComponent; DM: TComponent;
      aConnection: TComponent=nil; aMasterdata: TDataSet=nil); override;
    destructor Destroy; override;
    procedure Open; override;
    function CreateTable: Boolean; override;
    property RepairDetail : TOrderRepairDetail read FDetail;
    property History : TBaseHistory read FHistory;
    property Images : TImages read FImages;
    property Links : TRepairImageLinks read FLinks;
  end;
  TOrderRepair = class(TBaseDBDataSet)
  private
    FDetails: TOrderRepairDetail;
  public
    procedure DefineFields(aDataSet : TDataSet);override;
    procedure FillDefaults(aDataSet : TDataSet);override;
    constructor CreateEx(aOwner : TComponent;DM : TComponent=nil;aConnection : TComponent = nil;aMasterdata : TDataSet = nil);override;
    destructor Destroy;override;
    function CreateTable : Boolean;override;
    property Details : TOrderRepairDetail read FDetails;
  end;
  TOrderPos = class(TBaseDBPosition)
  private
    FOrder: TOrder;
    FOrderRepair: TOrderRepair;
    FQMTest: TOrderQMTest;
  protected
    function GetAccountNo : string;override;
    procedure PosPriceChanged(aPosDiff,aGrossDiff :Extended);override;
    procedure PosWeightChanged(aPosDiff : Extended);override;
    function Round(aValue: Extended): Extended; override;
    function RoundPos(aValue : Extended) : Extended;override;
    function GetCurrency : string;override;
    function GetOrderTyp : Integer;override;
  public
    constructor CreateEx(aOwner : TComponent;DM : TComponent=nil;aConnection : TComponent = nil;aMasterdata : TDataSet = nil);override;
    destructor Destroy;override;
    function CreateTable : Boolean;override;
    procedure Open; override;
    procedure Assign(aSource : TPersistent);override;
    procedure DefineFields(aDataSet : TDataSet);override;
    procedure FillDefaults(aDataSet : TDataSet);override;
    property QMTest : TOrderQMTest read FQMTest;
    property Order : TOrder read FOrder write FOrder;
    property Repair : TOrderRepair read FOrderRepair;
  end;
  TOrderAddress = class(TBaseDBAddress)
  private
    FOrder: TOrder;
  public
    constructor CreateEx(aOwner: TComponent; DM: TComponent;
       aConnection: TComponent=nil; aMasterdata: TDataSet=nil); override;
    procedure DefineFields(aDataSet : TDataSet);override;
    procedure CascadicPost; override;
    procedure Assign(Source: TPersistent); override;
    procedure Post; override;
    property Order : TOrder read FOrder write FOrder;
  end;
  TOrderPosTyp = class(TBaseDBDataSet)
  public
    procedure DefineFields(aDataSet : TDataSet);override;
  end;
  TDispatchTypes = class(TBaseDBDataSet)
  public
    procedure DefineFields(aDataSet : TDataSet);override;
    procedure SelectByCountryAndWeight(aCountry : string;aWeight : real);
  end;
  TPaymentTargets = class(TBaseDBDataSet)
    procedure DefineFields(aDataSet : TDataSet);override;
  end;
  TOrderLinks = class(TLinks)
  public
    procedure FillDefaults(aDataSet : TDataSet);override;
  end;
  TOnGetStorageEvent = function(Sender : TOrder;aStorage : TStorage) : Boolean of object;
  TOnGetSerialEvent = function(Sender : TOrder;aMasterdata : TMasterdata;aQuantity : Integer) : Boolean of object;
  TOrder = class(TOrderList,IPostableDataSet,IShipableDataSet)
  private
    FCurrency: TCurrency;
    FFailMessage: string;
    FLinks: TOrderLinks;
    FOnGetSerial: TOnGetSerialEvent;
    FOnGetStorage: TOnGetStorageEvent;
    FOrderAddress: TOrderAddress;
    FOrderPos: TOrderPos;
    function GetCommission: TField;
    procedure ReplaceParentFields(aField: TField; aOldValue: string;
      var aNewValue: string);
    function Round(Value: Extended): Extended;
  public
    constructor CreateEx(aOwner : TComponent;DM : TComponent=nil;aConnection : TComponent = nil;aMasterdata : TDataSet = nil);override;
    destructor Destroy;override;
    function CreateTable : Boolean;override;
    procedure FillDefaults(aDataSet : TDataSet);override;
    procedure Open;override;
    procedure RefreshActive;
    procedure CascadicPost;override;
    procedure CascadicCancel;override;
    property Commission : TField read GetCommission;
    property Address : TOrderAddress read FOrderAddress;
    property Positions : TOrderPos read FOrderPos;
    property Links : TOrderLinks read FLinks;
    property OnGetStorage : TOnGetStorageEvent read FOnGetStorage write FOnGetStorage;
    property OnGetSerial : TOnGetSerialEvent read FOnGetSerial write FOnGetSerial;
    property Currency : TCurrency read FCurrency;
    function SelectCurrency : Boolean;
    procedure Recalculate;
    function ChangeStatus(aNewStatus : string) : Boolean;override;
    procedure ShippingOutput;
    function DoPost: TPostResult;
    function PostArticle(aTyp, aID, aVersion, aLanguage: variant; Quantity: real; QuantityUnit, PosNo: string; var aStorage: string; var OrderDelivered: boolean) : Boolean;
    function DoBookPositionCalc(AccountingJournal : TAccountingJournal) : Boolean;
    function FailMessage : string;
    function FormatCurrency(Value : real) : string;
    function CalcDispatchType : Boolean;
    function GetOrderTyp: Integer;
    function SelectFromLink(aLink: string): Boolean; override;
    function Duplicate : Boolean;override;
  end;
implementation
uses uBaseDBInterface, uBaseSearch, uData, Process,uRTFtoTXT,
  uIntfStrConsts,Utils;
resourcestring
  strStatusnotfound             = 'Statustyp nicht gefunden, bitte wenden Sie sich an Ihren Administrator';
  strMainOrdernotfound          = 'Hauptvorgang nicht gefunden !';
  strNumbersetnotfound          = 'Nummernkreis nicht gefunden, bitte wenden Sie sich an Ihren Administrator';
  strBookingAborted             = 'Buchung abgebrochen';
  strOrderActionPost            = 'Vorgang als %s gebucht';
  strOrderPosted                = 'Vorgang gebucht';
  strOrders                     = 'Aufträge';
  strAlreadyPosted              = 'Der Vorgang ist bereits gebucht !';
  strDispatchTypenotfound       = 'Die gewählte Versandart existiert nicht !';

{ TRepairImageLinks }

procedure Torder.ReplaceParentFields(aField: TField; aOldValue: string;
  var aNewValue: string);
var
  aRec: Variant;
begin
  if (aField.FieldName='PARENT') and (aOldValue<>'') then
    begin
      aField.DataSet.Post;
      aRec := aField.DataSet.FieldByName('SQL_ID').AsVariant;
      if aField.DataSet.Locate('OLD_ID',aOldValue,[]) then
        aNewValue:=aField.DataSet.FieldByName('SQL_ID').AsString;
      aField.DataSet.Locate('SQL_ID',aRec,[]);
      if (aField.DataSet.State=dsBrowse) then
        aField.DataSet.Edit;
    end;
end;

procedure TRepairImageLinks.FillDefaults(aDataSet: TDataSet);
begin
  inherited FillDefaults(aDataSet);
  aDataSet.FieldByName('RREF_ID').AsVariant:=(Parent as TOrderRepairImages).Id.AsVariant;
end;

{ TOrderRepairImages }

procedure TOrderRepairImages.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'ORDERREPAIRIMAGE';
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('NAME',ftString,100,True);
            Add('STATUS',ftString,4,false);
            Add('SYMTOMS',ftString,800,False);
            Add('DESC',ftMemo,0,False);
            Add('SOLVE',ftMemo,0,False);
            Add('NOTES',ftMemo,0,False);
            Add('INTNOTES',ftMemo,0,False);
            Add('COUNTER',ftInteger,0,False);
          end;
    end;
end;

procedure TOrderRepairImages.FDSDataChange(Sender: TObject; Field: TField);
begin
  if not Assigned(Field) then exit;
  if DataSet.ControlsDisabled then exit;
  if Field.FieldName = 'STATUS' then
    begin
      History.Open;
      History.AddItem(Self.DataSet,Format(strStatusChanged,[FStatus,Field.AsString]),'','',nil,ACICON_STATUSCH);
      FStatus := Field.AsString;
    end;
end;

constructor TOrderRepairImages.CreateEx(aOwner: TComponent; DM: TComponent;
  aConnection: TComponent; aMasterdata: TDataSet);
begin
  inherited CreateEx(aOwner, DM, aConnection, aMasterdata);
  FHistory := TBaseHistory.CreateEx(Self,DM,aConnection,DataSet);
  FImages := TImages.CreateEx(Self,DM,aConnection,DataSet);
  FLinks := TRepairImageLinks.CreateEx(Self,DM,aConnection);
  FDetail := TOrderRepairDetail.CreateExIntegrity(Self,DM,False,aConnection,DataSet);
  FDS := TDataSource.Create(Self);
  FDS.DataSet := DataSet;
  FDS.OnDataChange:=@FDSDataChange;
end;

destructor TOrderRepairImages.Destroy;
begin
  FDS.Free;
  FDetail.Free;
  FLinks.Free;
  FImages.Free;
  FHistory.Free;
  inherited Destroy;
end;

procedure TOrderRepairImages.Open;
begin
  inherited Open;
  FStatus := FieldByName('STATUS').AsString;
end;

function TOrderRepairImages.CreateTable: Boolean;
begin
  Result:=inherited CreateTable;
  FImages.CreateTable;
  FHistory.CreateTable;
end;

procedure TOrderRepairDetail.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'ORDERREPAIRDETAIL';
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('ASSEMBLY',ftString,60,False);
            Add('PART',ftString,60,False);
            Add('ERROR',ftString,120,False);
          end;
    end;
end;
procedure TOrderRepair.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'ORDERREPAIR';
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('ID',ftInteger,0,False);
            Add('OPERATION',ftString,20,False);
            Add('ERRDESC',ftMemo,0,False);
            Add('NOTES',ftMemo,0,False);
            Add('INTNOTES',ftMemo,0,False);
            Add('WARRENTY',ftString,1,True);
            Add('ERRIMAGE',ftLargeint,0,False);
            Add('IMAGENAME',ftString,100,False);
          end;
    end;
end;
procedure TOrderRepair.FillDefaults(aDataSet: TDataSet);
begin
  with aDataSet,BaseApplication as IBaseDbInterface do
    begin
      FieldByName('WARRENTY').AsString := 'U';
      FieldByName('ID').AsInteger:=Self.Count+1;
    end;
  inherited FillDefaults(aDataSet);
end;
constructor TOrderRepair.CreateEx(aOwner: TComponent; DM: TComponent;
  aConnection: TComponent; aMasterdata: TDataSet);
begin
  inherited CreateEx(aOwner, DM, aConnection, aMasterdata);
  FDetails := TOrderRepairDetail.CreateEx(Owner,DM,aConnection,DataSet);
end;
destructor TOrderRepair.Destroy;
begin
  FDetails.Free;
  inherited Destroy;
end;
function TOrderRepair.CreateTable : Boolean;
begin
  Result := inherited CreateTable;
  FDetails.CreateTable;
end;
procedure TOrderPosTyp.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'ORDERPOSTYP';
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('NAME',ftString,3,True);
            Add('TYPE',ftString,1,True);
          end;
    end;
end;
procedure TOrderLinks.FillDefaults(aDataSet: TDataSet);
begin
  inherited FillDefaults(aDataSet);
  aDataSet.FieldByName('RREF_ID').AsVariant:=(Parent as TOrder).Id.AsVariant;
end;

constructor TOrderAddress.CreateEx(aOwner: TComponent; DM: TComponent;
  aConnection: TComponent; aMasterdata: TDataSet);
begin
  inherited CreateEx(aOwner, DM, aConnection, aMasterdata);
end;

procedure TOrderAddress.DefineFields(aDataSet: TDataSet);
begin
  inherited DefineFields(aDataSet);
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'ORDERADDR';
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('ACCOUNTNO',ftString,20,False);
          end;
    end;
end;

procedure TOrderAddress.CascadicPost;
begin
  Order.DataSet.DisableControls;
  if Order.Address.DataSet.Active and (Order.Address.Count>0) then
    begin
      if Order.FieldByName('CUSTNO').AsString<>FieldByName('ACCOUNTNO').AsString then
        begin
          if not Order.CanEdit then
            Order.DataSet.Edit;
          Order.FieldByName('CUSTNO').AsString := FieldByName('ACCOUNTNO').AsString;
        end;
      if Order.FieldByName('CUSTNAME').AsString<>FieldByName('NAME').AsString then
        begin
          if not Order.CanEdit then
            Order.DataSet.Edit;
          Order.FieldByName('CUSTNAME').AsString := FieldByName('NAME').AsString;
        end;
    end;
  Order.DataSet.EnableControls;
  inherited CascadicPost;
end;

procedure TOrderAddress.Assign(Source: TPersistent);
var
  aAddress: TBaseDbAddress;
  Person: TPerson;
begin
  if not Active then Open;
  if not Order.CanEdit then
    Order.DataSet.Edit;
  inherited Assign(Source);
  if Source is TBaseDBAddress then
    begin
      aAddress := Source as TBaseDbAddress;
      Order.FieldByName('CUSTNAME').AsString := aAddress.FieldByName('NAME').AsString;
    end
  else if Source is TPerson then
    begin
      Person := Source as TPerson;
      if not Order.CanEdit then
        Order.DataSet.Edit;
      Order.FieldByName('CUSTNO').AsString := Person.FieldByName('ACCOUNTNO').AsString;
    end;
end;

procedure TOrderAddress.Post;
begin
  inherited Post;
end;

procedure TRepairProblems.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'REPAIRPROBLEMS';
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('PROBLEM',ftString,60,True);
          end;
    end;
end;
procedure TPaymentTargets.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'PAYMENTTARGETS';
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('ID',ftString,2,True);
            Add('NAME',ftString,10,True);
            Add('TEXT',ftString,30,True);
            Add('FACCOUNTS',ftMemo,0,false);
            Add('CASHDISC',ftFloat,0,True);               //Skonto
            Add('CASHDISCD',ftInteger,0,True);            //Skonto Tage
            Add('DAYS',ftInteger,0,True);                 //Tage
            Add('DEFAULTPT',ftString,1,True);
          end;
    end;
end;
procedure TDispatchTypes.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'DISPATCHTYPES';
      UpdateFloatFields:=True;
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('ID',ftString,3,True);
            Add('COUNTRY',ftString,3,True);
            Add('NAME',ftString,20,false);
            Add('OUTPUTDRV',ftString,60,false);
            Add('WEIGHT',ftFloat,0,false);
            Add('ARTICLE',ftString,40,false);
          end;
    end;
end;
procedure TDispatchTypes.SelectByCountryAndWeight(aCountry: string;aWeight : real);
var
  aFilter: String;
begin
  with  DataSet as IBaseDBFilter, BaseApplication as IBaseDBInterface, DataSet as IBaseManageDB do
    begin
      Filter := '('+QuoteField('COUNTRY')+'='+QuoteValue(aCountry)+') AND ('+QuoteField('WEIGHT')+'>='+QuoteValue(FloatToStr(aWeight))+')';
      SortFields:='WEIGHT';
    end;
end;
procedure TOrderTyp.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'ORDERTYPE';
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('STATUS',ftString,4,True);
            Add('STATUSNAME',ftString,30,True);
            Add('TYPE',ftString,1,false);
            Add('ICON',ftInteger,0,false);
            Add('ISDERIVATE',ftString,1,false);
            Add('DERIVATIVE',ftString,30,false);
            Add('DOCOPY',ftString,1,false);    //Auftrag kopieren ? (Nur bei N wird nicth kopiert)
            Add('NUMBERSET',ftString,30,false);
            Add('DEFPOSTYP',ftString,3,False); //welcher positionstyp wird nach insert gesetzt?
            Add('TEXTTYP',ftInteger,0,False);  //welcher text ist standardtext
            Add('CHANGEABLE',ftString,1,false);//nach Buchen änderbar

            Add('ROUNDPOS',ftString,1,False);  //Positionen werden gerundet

            Add('SI_ORDER',ftString,1,false);  //im Auftrag anzeigen
            Add('SI_POS',ftString,1,false);    //in der Kasse anzeigen (Point of Sale)
            Add('SI_PROD',ftString,1,false);   //in der Produktion anzeigen
            Add('SI_ACC',ftString,1,false);    //in der Fibu anzeigen (Accounting)
            Add('SI_INVR',ftString,1,false);   //im Rechnungseingang anzeigen (Invoice Receipt)
            Add('SI_INVO',ftString,1,false);   //im Rechnungsausgang anzeigen (Outgoing Invoice)

            Add('B_STORAGE',ftString,1,false); //Lagerbuchung                 (+ 0 -)
            Add('B_RESERVED',ftString,1,false);//Lagerbuchung Reserviert      (+ 0 -)
            Add('B_STORDER',ftString,1,false); //Lagereintrag im Hauptvorgang (+ 0 -)
            Add('B_JOURNAL',ftString,1,false); //Kassenbuch                   (+ 0 -)
            Add('B_SERIALS',ftString,1,false); //Serienummerverwaltung        (+ 0 -)
            Add('B_INVR',ftString,1,false);    //Rechnungseingang             (+ 0 -)
            Add('B_INVO',ftString,1,false);    //Rechnungsausgang             (+ 0 -)
            Add('B_DUNNING',ftString,1,false); //Mahnwesen                    (+ 0 -)
            Add('B_CHIST',ftString,1,false);   //Kundenhistorie               (+ 0)
          end;
    end;
end;
procedure TOrderQMTestDetails.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'ORDERQMTESTDETAIL';
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('MODUL',ftString,60,False);
            Add('STEP',ftInteger,0,False);
            Add('NAME',ftString,60,False);
            Add('TYPE',ftString,10,False);
            Add('UNIT',ftString,20,False);
            Add('EXPECTED',ftMemo,0,False);
            Add('RESULT',ftMemo,0,False);
            Add('RESULTSHORT',ftString,1,False);
          end;
    end;
end;
constructor TOrderQMTest.CreateEx(aOwner: TComponent; DM : TComponent;aConnection: TComponent;
  aMasterdata: TDataSet);
begin
  inherited CreateEx(aOwner, DM, aConnection, aMasterdata);
  with DataSet as IBaseDBFilter do
    begin
      BaseSortFields := 'TESTTIME';
      SortFields := 'TESTTIME';
      SortDirection := sdDescending;
    end;
  FDetails := TOrderQMTestDetails.CreateEx(aOwner,DM,aConnection,DataSet);
end;
destructor TOrderQMTest.Destroy;
begin
  FDetails.Free;
  inherited Destroy;
end;
function TOrderQMTest.CreateTable : Boolean;
begin
  Result := inherited CreateTable;
  FDetails.CreateTable;
end;
procedure TOrderQMTest.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'ORDERQMTEST';
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('ID',ftLargeint,0,False);
            Add('NAME',ftString,20,False);
            Add('RESULT',ftString,1,False);
            Add('SERIAL',ftString,30,False);
            Add('NOTES',ftMemo,0,False);
            Add('RAWDATA',ftMemo,0,False);
            Add('TESTTIME',ftDateTime,0,False);
            Add('TESTEND',ftDateTime,0,False);
          end;
    end;
end;

function TOrder.GetCommission: TField;
begin
  result := FieldByName('COMMISSION');
end;

function TOrder.Round(Value: Extended): Extended;
  function RoundToGranularity(aValue, aGranularity: Double): Double;
  begin
    Result := Trunc(aValue / aGranularity + 0.5 + 1E-10) * aGranularity
  end;
var
  nk: Integer = 2;
begin
  if SelectCurrency and (Currency.FieldByName('DECIMALPL').AsInteger>0) then
    nk := Currency.FieldByName('DECIMALPL').AsInteger;
  if SelectCurrency and (Currency.FieldByName('ROUNDGRAN').AsFloat>0) then
    Result := InternalRound(RoundToGranularity(Value,Currency.FieldByName('ROUNDGRAN').AsFloat),nk)
  else Result := InternalRound(Value,nk);
end;

constructor TOrder.CreateEx(aOwner: TComponent; DM : TComponent;aConnection: TComponent;
  aMasterdata: TDataSet);
begin
  inherited CreateEx(aOwner,DM, aConnection, aMasterdata);
  UpdateFloatFields:=True;
  with BaseApplication as IBaseDbInterface do
    begin
      with DataSet as IBaseDBFilter do
        begin
          BaseSortFields := 'ORDERNO';
          SortFields := 'ORDERNO';
          SortDirection := sdAscending;
          UsePermissions:=False;
        end;
    end;
  FOrderAddress := TOrderAddress.CreateEx(Self,DM,aConnection,DataSet);
  FOrderAddress.Order := Self;
  FOrderPos := TOrderPos.CreateEx(Self,DM,aConnection,DataSet);
  FOrderPos.Order:=Self;
  FLinks := TOrderLinks.CreateEx(Self,DM,aConnection);
  FCurrency := TCurrency.CreateEx(Self,DM,aConnection);
end;
destructor TOrder.Destroy;
begin
  FCurrency.Free;
  FOrderAddress.Free;
  FOrderPos.Free;
  FreeAndnil(FLinks);
  inherited Destroy;
end;
function TOrder.CreateTable : Boolean;
begin
  Result := inherited CreateTable;
  FOrderAddress.CreateTable;
  FOrderPos.CreateTable;
  FOrderTyp.CreateTable;
  FHistory.CreateTable;
end;
procedure TOrder.FillDefaults(aDataSet: TDataSet);
begin
  with aDataSet,BaseApplication as IBaseDBInterface do
    begin
      FieldByName('ORDERNO').AsString := Data.Numbers.GetNewNumber('ORDERS') + '00';
      FieldByName('STATUS').AsString  := OrderType.FieldByName('STATUS').AsString;
      Data.SetFilter(Data.Currency,Data.QuoteField('DEFAULTCUR')+'='+Data.QuoteValue('Y'));
      if Data.Currency.Count > 0 then
        FieldByName('CURRENCY').AsString := Data.Currency.FieldByName('SYMBOL').AsString;
      Data.PaymentTargets.Open;
      if Data.PaymentTargets.DataSet.Locate('DEFAULTPT', 'Y', []) then
        FieldByName('PAYMENTTAR').AsString := Data.PaymentTargets.FieldByName('ID').AsString;
      FieldByName('ACTIVE').AsString := 'Y';
      FieldByName('DOAFQ').AsDateTime := Now();
      FieldByName('VATH').AsFloat     := 0;
      FieldByName('VATF').AsFloat     := 0;
      FieldByName('NETPRICE').AsFloat := 0;
      FieldByName('DISCOUNT').AsFloat := 0;
      FieldByName('GROSSPRICE').AsFloat := 0;
      FieldByName('DONE').AsString    := 'N';
      FieldByName('DELIVERED').AsString := 'N';
      FieldByName('CREATEDBY').AsString := Data.Users.IDCode.AsString;
    end;
end;
procedure TOrderList.Select(aID : string);
var
  aFilter: String;
begin
  with  DataSet as IBaseDBFilter, BaseApplication as IBaseDBInterface, DataSet as IBaseManageDB do
    begin
      if length(aID) > 4 then
        begin
          aFilter :=         '('+QuoteField('ORDERNO')+'>='+QuoteValue(copy(aID,0,length(aID)-2)+'00')+') and ';
          aFilter := aFilter+'('+QuoteField('ORDERNO')+'<='+QuoteValue(copy(aID,0,length(aID)-2)+'99')+')';
        end
      else
        aFilter :=  QuoteField('ORDERNO')+'='+QuoteValue(aID);
      Filter := aFilter;
      FOrigID := aID;
      Limit := 99;
    end;
end;

function TOrderList.SelectFromCommission(aNumber: string): Boolean;
var
  aFilter: String;
begin
  with  DataSet as IBaseDBFilter, BaseApplication as IBaseDBInterface, DataSet as IBaseManageDB do
    begin
      aFilter :=  QuoteField('COMMISSION')+'='+QuoteValue(aNumber);
      Filter := aFilter;
      Limit := 99;
    end;
end;

procedure TOrder.Open;
begin
  if not Assigned(DataSet) then exit;
  if DataSet.Active then exit;
  inherited Open;
  DataSet.Locate('ORDERNO',FOrigID,[]);
  OrderType.Open;
  OrderType.DataSet.Locate('STATUS',DataSet.FieldByName('STATUS').AsString,[]);
  if FieldByName('ACTIVE').IsNull then
    RefreshActive;
  SelectCurrency;
end;

procedure TOrder.RefreshActive;
var
  aRec: TBookmark;
  Found: Boolean = False;
begin
  if not DataSet.Active then exit;
  aRec := DataSet.GetBookmark;
  DataSet.Last;
  OrderType.Open;
  while not DataSet.BOF do
    begin
      OrderType.DataSet.Locate('STATUS',DataSet.FieldByName('STATUS').AsString,[]);
      if (OrderType.FieldByName('ISDERIVATE').AsString<>'Y')
      and not Found then
        begin
          if DataSet.FieldByName('ACTIVE').AsString<>'Y' then
            begin
              if not CanEdit then DataSet.Edit;
              DataSet.FieldByName('ACTIVE').AsString := 'Y';
              DataSet.Post;
            end;
          Found := True;
        end
      else
        begin
          if DataSet.FieldByName('ACTIVE').AsString<>'N' then
            begin
              if not CanEdit then DataSet.Edit;
              DataSet.FieldByName('ACTIVE').AsString := 'N';
              DataSet.Post;
            end;
        end;
      DataSet.Prior;
    end;
  DataSet.GotoBookmark(aRec);
  DataSet.FreeBookmark(aRec);
  OrderType.DataSet.Locate('STATUS',DataSet.FieldByName('STATUS').AsString,[]);
end;

procedure TOrder.CascadicPost;
begin
  Recalculate;
  FOrderAddress.CascadicPost;
  FHistory.CascadicPost;
  FOrderPos.CascadicPost;
  FLinks.CascadicPost;
  inherited CascadicPost;
end;
procedure TOrder.CascadicCancel;
begin
  FHistory.CascadicCancel;
  FOrderAddress.CascadicCancel;
  FOrderPos.CascadicCancel;
  FLinks.CascadicCancel;
  inherited CascadicCancel;
end;

function TOrder.SelectCurrency: Boolean;
begin
  if not FCurrency.Locate('SYMBOL',FieldByName('CURRENCY').AsString,[]) then
    begin
      FCurrency.Filter(Data.QuoteField('SYMBOL')+'='+Data.QuoteValue(FieldByName('CURRENCY').AsString));
      result := FCurrency.Locate('SYMBOL',FieldByName('CURRENCY').AsString,[]);
    end
  else Result := True;
end;

procedure TOrder.Recalculate;
var
  aPos: Double = 0;
  aGrossPos: Double = 0;
  aVatH : Double = 0;
  aVatV : Double = 0;
  Vat: TVat;
begin
  Vat := TVat.Create(nil);
  Positions.Open;
  Positions.First;
  while not Positions.EOF do
    begin
      if  (Positions.PosTypDec<>4)  //Only Positions that should calculated
      and (Positions.PosTypDec<>1)
      and (Positions.PosTypDec<>2)
      and (Positions.PosTypDec<>3)
      and (Positions.PosTypDec<>5)
      then
        begin
          aPos += Positions.FieldByName('POSPRICE').AsFloat;
          aGrossPos += Positions.FieldByName('GROSSPRICE').AsFloat;
          with BaseApplication as IBaseDbInterface do
            begin
              if not Vat.DataSet.Active then
                Vat.Open;
              Vat.DataSet.Locate('ID',VarArrayof([Positions.FieldByName('VAT').AsString]),[]);
              if Vat.FieldByName('ID').AsInteger=1 then
                aVatV += Positions.FieldByName('GROSSPRICE').AsFloat-Positions.FieldByName('POSPRICE').AsFloat
              else
                aVatH += Positions.FieldByName('GROSSPRICE').AsFloat-Positions.FieldByName('POSPRICE').AsFloat;
            end;
        end;
          if Positions.PosTypDec=4 then //Subtotal
            begin
              Positions.Edit;
              Positions.FieldByName('POSPRICE').AsFloat := aPos;
              Positions.FieldByName('GROSSPRICE').AsFloat := Round(aGrossPos);
              Positions.Post;
            end;
      Positions.Next;
    end;
  if not CanEdit then DataSet.Edit;
  FieldByName('VATH').AsFloat:=Round(aVatH);
  FieldByName('VATF').AsFloat:=Round(aVatV);
  FieldByName('NETPRICE').AsFloat:=Round(aPos);
  FieldByName('GROSSPRICE').AsFloat:=Round(aGrossPos);
  if CanEdit then DataSet.Post;
  Vat.Free;
end;

function TOrder.DoPost: TPostResult;
var
  Orders: TOrderList;
  Accountingjournal: TAccountingJournal = nil;
  MasterdataList: TMasterdataList = nil;
  Person: TPerson = nil;
  MainOrder: TOrder = nil;

  MainOrderId: LargeInt = 0;
  OrderTyp: Integer;
  OrderDone: Boolean;
  OrderDelivered: Boolean;
  aStorage: String;
  F_Date: Double;
  F_POSNO: String;
  F_QUANTITY: Double;
  aState: TDataSetState;
  aNumbers: TNumbersets = nil;
  aMainOrder: TOrder;
begin
  FFailMessage:='';
  Result := prFailed;
  CascadicPost;
  Recalculate;
  Orders := TOrderList.CreateEx(Owner,DataModule,Connection);
  MasterdataList := TMasterdataList.CreateEx(Owner,DataModule,Connection);
  MainOrder := TOrder.CreateEx(Owner,DataModule,Connection);
  MainOrder.Select(Self.FieldByName('ORDERNO').AsString);
  MainOrder.Open;
  Data.StorageType.Open;
  while ((MainOrder.OrderType.FieldByName('ISDERIVATE').AsString = 'Y') or (MainOrder.FieldByName('NUMBER').IsNull)) and (not MainOrder.DataSet.BOF) do
    begin
      MainOrder.DataSet.Prior;
      if not MainOrder.OrderType.Dataset.Locate('STATUS',MainOrder.FieldByName('STATUS').AsString, [loCaseInsensitive]) then
        break;
    end;
  if (MainOrder.OrderType.FieldByName('ISDERIVATE').AsString <> 'Y') and (not MainOrder.FieldByName('NUMBER').IsNull) then
    begin
      MainOrderId := MainOrder.GetBookmark;
      MainOrder.Positions.Open;
    end
  else
    FreeAndNil(MainOrder);
  if not OrderType.DataSet.Locate('STATUS', DataSet.FieldByName('STATUS').AsString, [loCaseInsensitive]) then
    raise Exception.Create(strStatusnotfound);
  OrderTyp := StrToIntDef(trim(copy(OrderType.FieldByName('TYPE').AsString, 0, 2)), 0);
  Address.Open;
  if OrderTyp = 2 then
    Address.DataSet.Locate('TYPE', 'DAD', [])
  else
    Address.DataSet.Locate('TYPE', 'IAD', []);
  //Prüfung bereits gebucht ?
  if not (DataSet.FieldByName('NUMBER').IsNull) then
    begin
      Result := pralreadyPosted;
    end;
  if (result <> pralreadyPosted) or BaseApplication.HasOption('e','editall') then
    begin
      //Überprüfen ob Nummernkreis existent
      with Data.Numbers.DataSet as IBaseDBFilter do
        Filter := Data.QuoteField('TABLENAME')+'='+Data.QuoteValue(OrderType.FieldByName('NUMBERSET').AsString);
      Data.Numbers.Open;
      if Data.Numbers.Count = 0 then
        raise Exception.Create(strNumbersetnotfound);
      Accountingjournal := TAccountingjournal.CreateEx(Owner,DataModule,Connection);
      Accountingjournal.CreateTable;
      with Accountingjournal.DataSet as IBaseDBFilter do
        begin
          Data.SetFilter(Accountingjournal,
          Data.ProcessTerm(Data.QuoteField('ORDERNO')+'='+Data.QuoteValue(DataSet.FieldByName('ORDERNO').AsString))
          );
        end;
      Data.StartTransaction(Connection,True);
      try
        OrderDone      := True;
        OrderDelivered := True;
        while Accountingjournal.Count > 1 do
          begin
            Accountingjournal.DataSet.Last;
            Accountingjournal.Delete;
          end;
        //Belegnummer und Datum vergeben
        DataSet.Edit;
        aNumbers := TNumberSets.CreateEx(Owner,Data,Connection);
        with aNumbers.DataSet as IBaseDBFilter do
          Filter := Data.QuoteField('TABLENAME')+'='+Data.QuoteValue(OrderType.FieldByName('NUMBERSET').AsString);
        aNumbers.Open;
        if Result <> pralreadyPosted then
          begin
            DataSet.FieldByName('NUMBER').AsString := aNumbers.GetNewNumber(OrderType.FieldByName('NUMBERSET').AsString);
            DataSet.FieldByName('DATE').AsDateTime := Now();
          end;
        if DataSet.FieldByName('ODATE').IsNull then
          DataSet.FieldByName('ODATE').AsDateTime := Now();
        DataSet.Post;
        OpenItem(False);
        //Alle Positionen durchgehen
        Positions.DataSet.First;
        while not Positions.DataSet.EOF do
          begin
            //Auftragsmenge setzen falls Auftrag
            if OrderTyp = 1 then
              begin
                Positions.DataSet.Edit;
                Positions.FieldByName('QUANTITYO').AsFloat := Positions.FieldByName('QUANTITY').AsFloat;
                if Positions.CanEdit then
                  Positions.DataSet.Post;
              end;
            //Lager buchen
            //Ist aktuelle Position ein Artikel ?
            MasterdataList.Select(Positions.Ident.AsString,Positions.FieldByName('VERSION').AsVariant,Positions.FieldByName('LANGUAGE').AsVariant);
            MasterdataList.Open;
            if MasterdataList.Count > 0 then
              begin
                if ((MasterdataList.FieldByName('TYPE').AsString = 'A') or (MasterdataList.FieldByName('TYPE').AsString = 'P')) then
                  if Positions.FieldByName('QUANTITY').AsFloat <> 0 then
                    begin
                      if Positions.FieldByName('STORAGE').IsNull then
                        aStorage := trim(DataSet.FieldByName('STORAGE').AsString)
                      else
                        aStorage := trim(Positions.FieldByName('STORAGE').AsString);
                      if (MasterdataList.FieldByName('NOSTORAGE').AsString <> 'Y') then
                        if not  PostArticle(MasterdataList.FieldByName('TYPE').AsString,
                                            MasterdataList.FieldByName('ID').AsString,
                                            MasterdataList.FieldByName('VERSION').AsVariant,
                                            MasterdataList.FieldByName('LANGUAGE').AsVariant,
                                            Positions.FieldByName('QUANTITY').AsFloat,
                                            MasterdataList.FieldByName('QUANTITYU').AsString,
                                            Positions.FieldByName('POSNO').AsString,
                                            aStorage,
                                            OrderDelivered) then
                          begin
                            raise(Exception.Create(strBookingAborted));
                          end;
                      if aStorage <> Positions.FieldByName('STORAGE').AsString then
                        begin
                          Positions.DataSet.Edit;
                          Positions.FieldByName('STORAGE').AsString := aStorage;
                          if Positions.CanEdit then
                            Positions.DataSet.Post;
                        end;
                      //Bei Bestellungseingang Lieferzeit setzen
    //TODO:
    {
                      if (OrderTyp = 2) and
                        (OrderType.FieldByName('B_STORAGE').AsString = '+') then
                        if Data.Supplier.FieldByName('ACCOUNTNO').AsString = Data.OrderAddress.FieldByName('ACCOUNTNO').AsString then
                          begin
                            OldDeliverTime :=
                              Data.Supplier.FieldByName('DELIVERTM').AsInteger;
                            if F_Date <> 0 then
                              begin
                                Data.Supplier.DataSet.Edit;
                                Data.Supplier.FieldByName('DELIVERTM').AsInteger := (OldDeliverTime + trunc(Now() - F_Date)) div 2;
                                Data.Supplier.DataSet.Post;
                              end;
                          end;
    }
                    end;
                end;
            //Menge geliefert setzen
            F_Date := 0;
            F_POSNO := Positions.FieldByName('POSNO').AsString;
            if (not OrderType.FieldByName('B_STORDER').IsNull)
            and (OrderType.FieldByName('B_STORDER').AsString <> '0')
            and Assigned(MainOrder)then
              begin
                //Im Hauptvorgang menge geliefert buchen
                F_QUANTITY := Positions.FieldByName('QUANTITY').AsFloat;
                if (OrderType.FieldByName('B_STORDER').AsString = '-') then
                  F_QUANTITY := -F_QUANTITY
                else if (OrderType.FieldByName('B_STORDER').AsString <> '+') then
                  F_QUANTITY := 0;
                F_Date := DataSet.FieldByName('DATE').AsDateTime;
                if MainOrder.Positions.DataSet.Locate('POSNO', F_POSNO, [loCaseInsensitive]) then
                  with Mainorder.Positions.DataSet do
                    begin
                      Edit;
                      FieldByName('QUANTITYD').AsFloat := FieldByName('QUANTITYD').AsFloat + F_QUANTITY;
                      Post;
                      if FieldByName('QUANTITYD').AsFloat <
                         FieldByName('QUANTITY').AsFloat then
                        OrderDelivered := False;
                    end;
              end;
            //Wenn Rechnung, dann QUANTITYC im Hauptvorgang setzen
            if (OrderTyp = 3) and (OrderType.FieldByName('B_INVO').AsString <> '0') then
              begin
                F_QUANTITY := Positions.FieldByName('QUANTITY').AsFloat;
                if Assigned(MainOrder) then
                  begin
                    if MainOrder.Positions.DataSet.Locate('POSNO',F_POSNO, [loCaseInsensitive]) then
                      with MainOrder.Positions.DataSet do
                      begin
                        Edit;
                        FieldByName('QUANTITYC').AsFloat :=  FieldByName('QUANTITYC').AsFloat + F_QUANTITY;
                        Post;
                        if FieldByName('QUANTITYC').AsFloat < FieldByName('QUANTITY').AsFloat then
                          OrderDone := False;
                      end;
                  end;
              end
            else
              OrderDone := False;
            //Feld "Bestellt" buchen
            //Fibukonten buchen bzw splittbeträge für verschiedenen konten zusammenrechnen
            //und im Kassenbuch mit buchen

            DoBookPositionCalc(AccountingJournal);
            Positions.DataSet.Next;
          end;
        //Auftrag Fertig Flag setzen
        if OrderDone or OrderDelivered then
          begin
            if Assigned(MainOrder) then
              begin
                MainOrder.DataSet.Edit;
                if OrderDone then
                  MainOrder.FieldByName('DONE').AsString := 'Y';
                if OrderDelivered then
                begin
                  MainOrder.FieldByName('DELIVERED').AsString := 'Y';
                  MainOrder.FieldByName('DELIVEREDON').AsDateTime := Now();
                end;
                if MainOrder.CanEdit then
                  Mainorder.DataSet.Post;
              end;
          end;
        //Kundenhistorie buchen
        Person := TPerson.CreateEx(Owner,DataModule,Connection);
        with Person.DataSet as IBaseDBFilter do
          Filter := Data.QuoteField('ACCOUNTNO')+'='+Data.QuoteValue(Address.FieldByName('ACCOUNTNO').AsString);
        Person.Open;
        if Person.Count > 0 then
          begin
            Person.History.Open;
            Person.History.AddItem(Person.DataSet,
                                   Format(strOrderActionPost, [DataSet.FieldByName('STATUS').AsString]),
                                   Data.BuildLink(Self.DataSet),
                                   DataSet.FieldByName('ORDERNO').AsString,
                                   DataSet,
                                   ACICON_ORDERPOSTED,
                                   DataSet.FieldByName('COMMISSION').AsString);
          end;
        //Vorgangsgeschichte Buchen
        if Self.CanEdit then DataSet.Post;
        History.Open;
        History.AddItem(Self.DataSet,strOrderPosted,'',DataSet.FieldByName('STATUS').AsString+' '+DataSet.FieldByName('NUMBER').AsString,nil,ACICON_ORDERPOSTED);
        //Auftragsansicht Neuprüfen
        Data.CommitTransaction(Connection);
        Positions.First;
        Result := prSuccess;
      except
        on e : Exception do
          begin
            Result := prFailed;
            Data.RollbackTransaction(Connection);
            FFailMessage := e.Message;
            //debugln(e.Message);
            DataSet.Refresh;
          end;
      end;
    end;
  FreeAndnil(Orders);
  FreeAndNil(MasterdataList);
  FreeAndNil(AccountingJournal);
  FreeAndNil(MainOrder);
  FreeAndNil(Person);
  FreeAndNil(aNumbers);
end;

function TOrder.FailMessage: string;
begin
  Result := FFailMessage;
end;

function TOrder.ChangeStatus(aNewStatus: string): Boolean;
var
  aOrderType: LongInt;
  Copied: String;
  newnumber: String;
  BM: LongInt;
  OldFilter: String;
  OldRec: Variant;
begin
  Result := False;
  OrderType.Open;
  if not OrderType.DataSet.Locate('STATUS',aNewStatus,[loCaseInsensitive]) then
    Data.SetFilter(OrderType,'');
  if OrderType.DataSet.Locate('STATUS',aNewStatus,[loCaseInsensitive]) then
    begin
      aOrderType := StrToIntDef(trim(copy(OrderType.FieldByName('TYPE').AsString,0,2)),0);
      if trim(OrderType.FieldByName('TYPE').AsString) = '' then
        exit;
      History.Open;
      History.AddItem(Self.DataSet,Format(strStatusChanged,[Status.AsString,aNewStatus]),'','',nil,ACICON_STATUSCH);
      if not (OrderType.FieldByName('ISDERIVATE').AsString = 'Y') then
        begin
          DataSet.Edit;
          DataSet.FieldByName('DONE').AsString := 'Y';
          DataSet.Post;
        end;
      if (not Assigned(OrderType.FieldByName('DOCOPY'))) or (OrderType.FieldByName('DOCOPY').AsString <> 'N') then
        begin //Copy Order
          with DataSet as IBaseDBFilter do
            OldFilter := Filter;
          OldRec := GetBookmark;
          with DataSet as IBaseDBFilter do
            Filter := Data.QuoteField('ORDERNO')+'='+Data.QuoteValue(DataSet.FieldByName('ORDERNO').AsString);
          DataSet.Open;
          Copied := ExportToXML;
          Select(DataSet.FieldByName('ORDERNO').AsString);
          Open;
          if not GotoBookmark(OldRec) then
            begin
              raise Exception.Create('OldRec not found');
              exit;
            end;
          Positions.DisableCalculation;
          BM := GetBookmark;
          DataSet.Last;
          newnumber := copy(DataSet.FieldByName('ORDERNO').AsString,  length(DataSet.FieldByName('ORDERNO').AsString)-1,2);
          if NewNumber = '' then
            begin
              raise Exception.Create('NewNumber is NULL');
              exit;
            end;
          newnumber := copy(DataSet.FieldByName('ORDERNO').AsString,0,length(DataSet.FieldByName('ORDERNO').AsString)-2)+Format('%.2d',[StrToIntDef(newnumber,0)+1]);
          GotoBookmark(BM);
          with DataSet do
            begin
              Append;
              FieldByName('ORDERNO').AsString := newnumber;
              FieldByName('STATUS').AsString := aNewStatus;
              FieldByName('DOAFQ').Clear;
              FieldByName('DWISH').Clear;
              FieldByName('VATH').Clear;
              FieldByName('VATF').Clear;
              FieldByName('NETPRICE').Clear;
              FieldByName('DISCOUNT').Clear;
              FieldByName('GROSSPRICE').Clear;
            end;
          ImportFromXML(Copied,False,@ReplaceParentFields);
          with DataSet do
            begin
              Edit;
              FieldByName('NUMBER').Clear;
              FieldByName('DATE').Clear;
              if aOrderType <> 3 then
                FieldByName('ODATE').Clear;
              Post;
            end;
          Positions.EnableCalculation;
          with Positions.DataSet do
            begin
              First;
              while not EOF do
                begin
                  Edit;
                  if aOrderType = 3 then
                    begin
                      if FieldByName('QUANTITYO').IsNull then
                        FieldByName('QUANTITYO').AsFloat := FieldByName('QUANTITY').AsFloat;
                      if FieldByName('QUANTITYD').IsNull then
                        FieldByName('QUANTITY').AsFloat := FieldByName('QUANTITY').AsFloat-FieldByName('QUANTITYC').AsFloat
                      else
                        FieldByName('QUANTITY').AsFloat := FieldByName('QUANTITYD').AsFloat-FieldByName('QUANTITYC').AsFloat
                    end
                  else
                    FieldByName('QUANTITY').AsFloat := FieldByName('QUANTITY').AsFloat-FieldByName('QUANTITYD').AsFloat;
                  Post;
                  Next;
                end;
            end;
          Result:=True;
        end
      else
        begin
          with DataSet do
            begin
              Edit;
              FieldByName('STATUS').AsString := aNewStatus;
              FieldByName('DOAFQ').Clear;
              FieldByName('DWISH').Clear;
              FieldByName('VATH').Clear;
              FieldByName('VATF').Clear;
              FieldByName('NETPRICE').Clear;
              FieldByName('DISCOUNT').Clear;
              FieldByName('GROSSPRICE').Clear;
              FieldByName('NUMBER').Clear;
              FieldByName('DATE').Clear;
              if aOrderType <> 3 then
                FieldByName('ODATE').Clear;
              Post;
            end;
          Result:=True;
        end;
      if not (OrderType.FieldByName('ISDERIVATE').AsString = 'Y') then
        begin //Auftrag geändert
          DataSet.Edit;
          DataSet.FieldByName('DONE').AsString := 'N';
          DataSet.Post;
        end;
      RefreshActive;
    end;
  OpenItem(False);
end;
procedure TOrder.ShippingOutput;
var
  OrderTyp: Integer;
  aProcess: TProcess;
  CommaCount: Integer;
  tmp: String;
  Dispatchtypes: TDispatchTypes;
begin
  Dispatchtypes := TDispatchTypes.Create(nil);
  if not OrderType.DataSet.Locate('STATUS', DataSet.FieldByName('STATUS').AsString, [loCaseInsensitive]) then
    raise Exception.Create(strStatusnotfound);
  OrderTyp := StrToIntDef(trim(copy(OrderType.FieldByName('TYPE').AsString, 0, 2)), 0);
  //Prüfung ob Versandart existiert
  if ((OrderTyp = 2) //Lieferschein
  or  (OrderTyp = 3)) //Rechnung
  then
    begin
      Data.SetFilter(Dispatchtypes,Data.QuoteField('ID')+'='+Data.QuoteValue(trim(copy(DataSet.FieldByName('SHIPPING').AsString,0,3))));
      if not Dispatchtypes.Locate('ID',copy(DataSet.FieldByName('SHIPPING').AsString,0,3),[loPartialKey]) then
        begin
          raise Exception.Create(strDispatchTypenotfound);
          exit;
        end;
    end;
  //Versandausgabe
  if  ((OrderTyp = 2) //Lieferschein
  or   (OrderTyp = 3)) //Rechnung
  then
    begin
      aProcess := TProcess.Create(Self);
      aProcess.ShowWindow := swoHide;
      aProcess.Options:= [poNoConsole,poWaitOnExit];
      aProcess.CommandLine := '"'+ExtractFileDir(ParamStr(0))+DirectorySeparator+'plugins'+DirectorySeparator;
      if pos(' ',Dispatchtypes.FieldByName('OUTPUTDRV').AsString) > 0 then
        begin
          aProcess.CommandLine := aProcess.Commandline+copy(Dispatchtypes.FieldByName('OUTPUTDRV').AsString,0,pos(' ',Dispatchtypes.FieldByName('OUTPUTDRV').AsString)-1)+ExtractFileExt(Paramstr(0))+'"';
          aProcess.Commandline := aProcess.Commandline+copy(Dispatchtypes.FieldByName('OUTPUTDRV').AsString,pos(' ',Dispatchtypes.FieldByName('OUTPUTDRV').AsString)+1,length(Dispatchtypes.FieldByName('OUTPUTDRV').AsString));
        end
      else aProcess.CommandLine := aProcess.Commandline+Dispatchtypes.FieldByName('OUTPUTDRV').AsString+ExtractFileExt(Paramstr(0))+'"';
      CommaCount := 0;
      Address.Open;
      with Address.DataSet do
        begin
          tmp :=  ' --address="';
          if trim(FieldbyName('TITLE').AsString) <>'' then
            tmp := tmp+FieldbyName('TITLE').AsString+',';
          tmp := tmp+FieldbyName('NAME').AsString+',';
          if trim(FieldbyName('ADDITIONAL').AsString) <>'' then
            tmp := tmp+FieldbyName('ADDITIONAL').AsString+',';
          tmp := tmp+FieldbyName('ADDRESS').AsString+',';
          tmp := tmp+FieldbyName('COUNTRY').AsString+' '+FieldbyName('ZIP').AsString+' '+FieldbyName('CITY').AsString+'"';
        end;
      aProcess.Commandline := aProcess.Commandline+tmp;
      aProcess.Execute;
      aProcess.Free;
    end;
  Dispatchtypes.Free;
end;

function TOrder.PostArticle(aTyp, aID, aVersion, aLanguage: variant;
  Quantity: real; QuantityUnit, PosNo: string; var aStorage: string;
  var OrderDelivered: boolean): Boolean;
var
  OrderTyp: LongInt;
  Masterdata: TMasterdata;
  aQuantity : real = 0;
  aReserved : real = 0;
  aBooked: Real;
  aFirstStorage: Boolean;
begin
  with BaseApplication as IBaseDbInterface do
    begin
      try
      try
        Result := True;
        OrderTyp := StrToIntDef(trim(copy(OrderType.FieldByName('TYPE').AsString, 0, 2)), 0);
        Masterdata := TMasterdata.CreateEx(Owner,DataModule,Connection);
        Masterdata.CreateTable;
        Masterdata.Select(aID,aVersion,aLanguage);
        Masterdata.Open;
        if Masterdata.DataSet.Locate('ID;VERSION;LANGUAGE', VarArrayOf([aID, aVersion, aLanguage]), []) then
          if (Masterdata.FieldByName('NOSTORAGE').AsString <> 'Y') then
            begin
              if (Masterdata.FieldByName('TYPE').AsString = 'P') and
                (Masterdata.FieldByName('PTYPE').AsString = 'L') then
                begin //BoM List we must book every Position
                  Masterdata.Positions.Open;
                  Masterdata.Positions.DataSet.First;
                  while not Masterdata.Positions.DataSet.EOF do
                    begin
                      PostArticle(aTyp, //TODO: Maybe an problem ???
                        Masterdata.Positions.FieldByName('IDENT').AsVariant,
                        Masterdata.Positions.FieldByName('VERSION').AsVariant,
                        Masterdata.Positions.FieldByName('LANGUAGE').AsVariant,
                        Masterdata.Positions.FieldByName('QUANTITY').AsFloat * Quantity,
                        Masterdata.Positions.FieldByName('QUANTITYU').AsString,
                        PosNo,
                        aStorage,
                        OrderDelivered);//or so ????  aNone);
                      Masterdata.Positions.DataSet.Next;
                    end;
                end
              else
                begin
                  if (OrderType.FieldByName('B_STORAGE').AsString = '+')
                  or (OrderType.FieldByName('B_STORAGE').AsString = '-')
                  or (OrderType.FieldByName('B_RESERVED').AsString ='+')
                  or (OrderType.FieldByName('B_RESERVED').AsString = '-')
                  then
                    begin
                      Masterdata.Storage.Open;
                      if OrderType.FieldByName('B_STORAGE').AsString = '+' then
                        begin
                          aQuantity:=Quantity;
                        end
                      else if OrderType.FieldByName('B_STORAGE').AsString = '-' then
                        begin
                          aQuantity:=-Quantity;
                        end;
                      if (OrderType.FieldByName('B_RESERVED').AsString = '+') and
                        (not ((OrderTyp = 7) and (Quantity > 0))) then
                        begin
                          aReserved:=Quantity;
                          OrderDelivered := False;
                        end
                      else if (OrderType.FieldByName('B_RESERVED').AsString = '-') and
                        (not ((OrderTyp = 7) and (Quantity > 0))) then
                      begin
                        aReserved:=-Quantity;
                      end;
                      aFirstStorage := True;
                      while aQuantity <> 0 do
                        begin
                          //Ist Lagerdatensatz gleich zu buchendes Lager
                          if (not Masterdata.Storage.Locate('STORAGEID', trim(copy(aStorage, 0, 3)), [loCaseInsensitive])) or (not aFirstStorage) or (Masterdata.FieldByName('USEBATCH').AsString='Y') then
                            if (not Data.StorageType.Locate('ID',trim(copy(aStorage, 0, 3)),[loCaseInsensitive])) or (not aFirstStorage) or (Masterdata.FieldByName('USEBATCH').AsString='Y') then
                              begin
                                if Masterdata.Storage.FieldByName('STORAGEID').AsString<>trim(copy(aStorage, 0, 3)) then
                                  Masterdata.Storage.Locate('STORAGEID', trim(copy(aStorage, 0, 3)), [loCaseInsensitive]);
                                if Assigned(FOnGetStorage) then
                                  if FOnGetStorage(Self,Masterdata.Storage) then
                                    aStorage := Masterdata.Storage.FieldByName('STORAGEID').AsString
                                  else raise Exception.Create('User aborted');
                              end;
                          aBooked := Masterdata.Storage.DoPost(OrderType,Self,aStorage,aQuantity,aReserved,QuantityUnit,PosNo);
                          if aBooked = 0 then
                            raise Exception.Create('Post Article failed');
                          aQuantity := aQuantity-aBooked;
                          aFirstStorage:=False;
                        end;

                    end
                  else
                    OrderDelivered := False;
                end;
            end;
      except
        on e : Exception do
          begin
            //debugln('Postarticle:'+e.Message);
            Result := False;
          end;
      end;
      finally
        Masterdata.Free;
      end;
    end;
end;
function TOrder.DoBookPositionCalc(AccountingJournal : TAccountingJournal): Boolean;
var
  aType : string;
  aOrderNo: String;
  Invert: Boolean;
begin
  Result := True;
  Invert := False;
  if (OrderType.FieldByName('B_JOURNAL').AsString = '-') then
    begin
      aType := 'KJ';
    end
  else if (OrderType.FieldByName('B_JOURNAL').AsString = '+') then
    begin
      aType := 'KS';
      Invert := True;
    end
  else if OrderType.FieldByName('B_INVR').AsString = '-' then
    begin
      aType := 'IR';
    end
  else if OrderType.FieldByName('B_INVR').AsString = '+' then
    begin
      aType := 'BR';
      Invert := True;
    end
  else if OrderType.FieldByName('B_INVO').AsString = '-' then
    begin
      aType   := 'IO';
    end
  else if OrderType.FieldByName('B_INVO').AsString = '+' then
    begin
      aType   := 'BO';
      Invert := True;
    end
  else exit;
  aOrderNo := DataSet.FieldByName('ORDERNO').AsString;
  with Accountingjournal.DataSet do
    begin
      if AccountingJournal.DataSet.Locate('VATT', VarArrayOf([Positions.FieldByName('VAT').AsString]),[loCaseInsensitive,loPartialKey]) then
        Accountingjournal.DataSet.Edit
      else
        begin
          Insert;
          FieldByName('CURRENCY').AsString := DataSet.FieldByName('CURRENCY').AsString;
          FieldByName('PAYMENTTAR').AsString := DataSet.FieldByName('PAYMENTTAR').AsString;
          FieldByName('PAYMENT').AsString  := 'N';
          FieldByName('VATT').AsInteger    := Positions.FieldByName('VAT').AsInteger;
          FieldByName('NETPRICE').AsFloat  := 0;
          FieldByName('GROSSPRICE').AsFloat:= 0;
        end;
      FieldByName('TYPE').AsString     := aType;
      FieldByName('ORDERNO').AsString  := aOrderNo;
      FieldByName('CUSTNO').AsString   := DataSet.FieldByName('CUSTNO').AsString;
      FieldByName('CUSTNAME').AsString := DataSet.FieldByName('CUSTNAME').AsString;
      FieldByName('STATUS').AsString := DataSet.FieldByName('STATUS').AsString;
      FieldByName('DATE').AsDateTime   := DataSet.FieldByName('DATE').AsDateTime;
      FieldByName('NUMBER').AsString   := DataSet.FieldByName('NUMBER').AsString;
      FieldByName('ODATE').AsDateTime   := DataSet.FieldByName('ODATE').AsDateTime;
      if FieldDefs.IndexOf('VATH') > -1 then
        begin
          FieldByName('VATH').AsString     := DataSet.FieldByName('VATH').AsString;
          FieldByName('VATF').AsString     := DataSet.FieldByName('VATF').AsString;
        end;
      if Invert then
        begin
          FieldByName('NETPRICE').AsFloat   := Round(FieldByName('NETPRICE').AsFloat-Positions.FieldByName('POSPRICE').AsFloat);
          FieldByName('GROSSPRICE').AsFloat := Round(FieldByName('GROSSPRICE').AsFloat-Positions.FieldByName('GROSSPRICE').AsFloat);
        end
      else
        begin
          FieldByName('NETPRICE').AsFloat   := Round(FieldByName('NETPRICE').AsFloat+Positions.FieldByName('POSPRICE').AsFloat);
          FieldByName('GROSSPRICE').AsFloat := Round(FieldByName('GROSSPRICE').AsFloat+Positions.FieldByName('GROSSPRICE').AsFloat);
        end;
      Post;
    end;
end;
function TOrder.FormatCurrency(Value: real): string;
begin
  Result := FormatFloat('0.00',Value)+' '+DataSet.FieldByName('CURRENCY').AsString;
end;
function TOrder.CalcDispatchType: Boolean;
var
  aDisp: TDispatchTypes;
  aMasterdata: TMasterdata;
  aPosTyp: TPositionTyp;
begin
  aPosTyp := TPositionTyp.CreateEx(Self,DataModule,Connection);
  aPosTyp.Open;
  if aPosTyp.DataSet.Locate('TYPE',6,[loCaseInsensitive]) then
    begin
      //Find new Dispatchtype
      aDisp := TDispatchTypes.CreateEx(Self,DataModule,Connection);
      if not Address.DataSet.Active then Address.Open;
      if Address.Count > 0 then
        begin
          aDisp.SelectByCountryAndWeight(Address.FieldByName('COUNTRY').AsString,DataSet.FieldByName('WEIGHT').AsFloat);
          aDisp.Open;
        end;
      //Delete old Dispatchtypes
      while Positions.DataSet.Locate('POSTYP',aPosTyp.FieldByName('NAME').AsString,[loCaseInsensitive]) do
        Positions.DataSet.Delete;
      if (aDisp.Count > 0) then
        begin
          while (not aDisp.DataSet.EOF) and (aDisp.FieldByName('ARTICLE').AsString = '') do
            aDisp.DataSet.Next;
          aMasterdata := TMasterdata.CreateEx(Self,DataModule,Connection);
          aMasterdata.Select(aDisp.FieldByName('ARTICLE').AsString);
          aMasterdata.Open;
          if aMasterdata.Count > 0 then
            begin
              Positions.Append;
              Positions.Assign(aMasterdata);
              Positions.FieldByName('POSTYP').AsString:=aPosTyp.FieldByName('NAME').AsString;
              Positions.DataSet.Post;
            end;
          aMasterdata.Free;
        end;
      aDisp.Free;
    end;
  aPosTyp.Free;
end;

function TOrder.GetOrderTyp: Integer;
begin
  Result := -1;
  if OrderType.DataSet.Locate('STATUS', DataSet.FieldByName('STATUS').AsString, [loCaseInsensitive]) then
    Result := StrToIntDef(trim(copy(OrderType.FieldByName('TYPE').AsString, 0, 2)), -1);
end;

function TOrder.SelectFromLink(aLink: string): Boolean;
begin
  if pos('{',aLink) > 0 then
    aLink := copy(aLink,0,pos('{',aLink)-1)
  else if rpos('(',aLink) > 0 then
    aLink := copy(aLink,0,rpos('(',aLink)-1);
  with DataSet as IBaseManageDB do
    begin
      if copy(aLink,0,pos('@',aLink)-1) = TableName then
        begin
          if IsNumeric(copy(aLink,pos('@',aLink)+1,length(aLink))) then
            begin
              Select(copy(aLink,pos('@',aLink)+1,length(aLink)));
              result := True;
            end;
        end
      else
        Result:=inherited SelectFromLink(aLink);
    end;
end;

function TOrder.Duplicate: Boolean;
var
  Copied: String;
begin
  Copied := ExportToXML;
  ImportFromXML(Copied,True,@ReplaceParentFields);
  with DataSet do
    begin
      Edit;
      FieldByName('NUMBER').Clear;
      FieldByName('DATE').Clear;
      FieldByName('ODATE').Clear;
      Post;
    end;
end;

function TOrderPos.GetAccountNo: string;
begin
  if Assigned(Order) and (Order.Address.Count>0) then
    Result:=Order.Address.FieldByName('ACCOUNTNO').AsString
  else inherited;
end;
procedure TOrderPos.PosPriceChanged(aPosDiff, aGrossDiff: Extended);
begin
  if not ((Order.DataSet.State = dsEdit) or (Order.DataSet.State = dsInsert)) then
    Order.DataSet.Edit;
  Order.FieldByName('NETPRICE').AsFloat := Round(Order.FieldByName('NETPRICE').AsFloat+aPosDiff);
  Data.PaymentTargets.Open;
  if Data.PaymentTargets.DataSet.Locate('ID',Order.FieldByName('PAYMENTTAR').AsString,[]) then
    Order.FieldByName('DISCPRICE').AsFloat := Round(Order.FieldByName('NETPRICE').AsFloat-((Order.FieldByName('NETPRICE').AsFloat/100)*Data.PaymentTargets.FieldByName('CASHDISC').AsFloat));
  Order.FieldByName('GROSSPRICE').AsFloat := Round(Order.FieldByName('GROSSPRICE').AsFloat+aGrossDiff);
end;
procedure TOrderPos.PosWeightChanged(aPosDiff : Extended);
begin
  if not ((Order.DataSet.State = dsEdit) or (Order.DataSet.State = dsInsert)) then
    Order.DataSet.Edit;
  Order.FieldByName('WEIGHT').AsFloat := Order.FieldByName('WEIGHT').AsFloat+aPosDiff;
end;

function TOrderPos.Round(aValue: Extended): Extended;
begin
  if Assigned(Order) then
    Result := Order.Round(aValue)
  else Result:=inherited Round(aValue);
end;
function TOrderPos.RoundPos(aValue: Extended): Extended;
begin
  if Order.SelectOrderType and (Order.OrderType.FieldByName('ROUNDPOS').AsString='Y') then
    Result := Round(aValue)
  else result := aValue;
end;

function TOrderPos.GetCurrency: string;
begin
  Result:=Order.FieldByName('CURRENCY').AsString;
end;
function TOrderPos.GetOrderTyp: Integer;
begin
  Result := 0;
  if Order.OrderType.DataSet.Locate('STATUS', Order.FieldByName('STATUS').AsString, [loCaseInsensitive]) then
    Result := StrToIntDef(trim(copy(Order.OrderType.FieldByName('TYPE').AsString, 0, 2)), 0);
end;
constructor TOrderPos.CreateEx(aOwner: TComponent; DM : TComponent;aConnection: TComponent;
  aMasterdata: TDataSet);
begin
  inherited CreateEx(aOwner, DM,aConnection, aMasterdata);
  FQMTest := TOrderQMTest.CreateEx(Owner,DM,aConnection,DataSet);
  FOrderRepair := TOrderRepair.CreateEx(Owner,DM,aConnection,DataSet);
end;
destructor TOrderPos.Destroy;
begin
  FOrderRepair.Free;
  FQMTest.Free;
  inherited Destroy;
end;
function TOrderPos.CreateTable : Boolean;
begin
  Result := inherited CreateTable;
  FOrderRepair.CreateTable;
  FQMTest.CreateTable;
end;

procedure TOrderPos.Open;
begin
  inherited Open;
end;

procedure TOrderPos.Assign(aSource: TPersistent);
var
  aMasterdata: TMasterdata;
  tmpPID: String;
begin
  inherited Assign(aSource);
  if aSource is TMasterdata then
    begin
      aMasterdata := aSource as TMasterdata;
      //Use Text that is setted in Ordertype
      if (not Order.OrderType.FieldByName('TEXTTYP').IsNull) then
        DataSet.FieldByName('TEXT').Clear;
      if (not Order.OrderType.FieldByName('TEXTTYP').IsNull) and (Order.OrderType.FieldByName('TEXTTYP').AsInteger > 0) then
        if aMasterdata.Texts.DataSet.Locate('TEXTTYPE',VarArrayOf([Order.OrderType.FieldByName('TEXTTYP').AsInteger]),[loCaseInsensitive]) then
          begin
            if CanHandleRTF then
              DataSet.FieldByName('TEXT').AsString := aMasterdata.Texts.FieldByName('TEXT').AsString
            else
              DataSet.FieldByName('TEXT').AsString := RTF2Plain(aMasterdata.Texts.FieldByName('TEXT').AsString);
          end;
      tmpPID := Order.FieldByName('PID').AsString;
      tmpPID := StringReplace(tmpPID,'...','',[rfReplaceAll]);
      if pos(aMasterdata.Number.AsString,tmpPID) = 0 then
        begin
          if length(tmpPID+','+aMasterdata.Number.AsString) > 49 then
            tmpPID := tmpPID+'...'
          else
            tmpPID := tmpPID+','+aMasterdata.Number.AsString;
          if copy(tmpPID,0,1) = ',' then
            tmpPID := copy(tmpPID,2,length(tmpPID));
          if not Order.CanEdit then
            Order.DataSet.Edit;
          Order.FieldByName('PID').AsString:=tmpPID;
        end;
    end;
end;
procedure TOrderPos.DefineFields(aDataSet: TDataSet);
begin
  inherited DefineFields(aDataSet);
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'ORDERPOS';
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('COSTCENTRE',ftString,10,False);//Kostenstelle
            Add('ACCOUNT',ftString,10,False); //Fibu Konto
            Add('PROJECTNR',ftString,20,False);
          end;
      if Data.ShouldCheckTable(TableName) then
        DefineUserFields(aDataSet);
    end;
end;
procedure TOrderPos.FillDefaults(aDataSet: TDataSet);
begin
  with aDataSet,BaseApplication as IBaseDbInterface do
    begin
      PosTyp.DataSet.Locate('TYPE', '0', []);
      if TOrder(Parent).OrderType.DataSet.Locate('STATUS',TOrder(Parent).FieldByName('STATUS').AsString, [loCaseInsensitive, loPartialKey]) then
        if PosTyp.DataSet.Locate('NAME',TOrder(Parent).OrderType.FieldByName('DEFPOSTYP').AsString,[loCaseInsensitive, loPartialKey]) then
          FieldByName('POSTYP').AsString := TOrder(Parent).OrderType.FieldByName('DEFPOSTYP').AsString;
      if DataSet.FieldDefs.IndexOf('ORDERNO') > -1 then
        FieldByName('ORDERNO').AsString  := TOrder(Parent).FieldByName('ORDERNO').AsString;
    end;
  inherited FillDefaults(aDataSet);
end;
function TOrderList.GetHistory: TBaseHistory;
begin
  Result := FHistory;
end;

function TOrderList.GetOrderTyp: TOrdertyp;
begin
  Result := FOrderTyp;
end;

function TOrderList.GetTextFieldName: string;
begin
  Result:='CUSTNAME';
end;
function TOrderList.GetNumberFieldName: string;
begin
  Result:='ORDERNO';
end;
function TOrderList.GetBookNumberFieldName: string;
begin
  Result:='NUMBER';
end;
function TOrderList.GetStatusFieldName: string;
begin
  Result:='STATUS';
end;
function TOrderList.GetCommissionFieldName: string;
begin
  Result:='COMMISSION';
end;
constructor TOrderList.CreateEx(aOwner: TComponent; DM: TComponent;
  aConnection: TComponent; aMasterdata: TDataSet);
begin
  inherited CreateEx(aOwner, DM, aConnection, aMasterdata);
  FHistory := TBaseHistory.CreateEx(Self,DM,aConnection,DataSet);
  FOrderTyp := TOrderTyp.CreateEx(Self,DM,aConnection);
  with BaseApplication as IBaseDbInterface do
    begin
      with DataSet as IBaseDBFilter do
        begin
          UsePermissions:=True;
        end;
    end;
end;

destructor TOrderList.Destroy;
begin
  FHistory.Free;
  FOrderTyp.Free;
  inherited Destroy;
end;

function TOrderList.CreateTable: Boolean;
begin
  Result:=inherited CreateTable;
  OrderType.CreateTable;
end;

function TOrderList.GetStatusIcon: Integer;
var
  aStat: String;
begin
  Result := -1;
  aStat := FStatusCache.Values[FieldByName(GetStatusFieldName).AsString];
  if aStat <> '' then Result := StrToIntDef(aStat,-1)
  else
    begin
      OrderType.Open;
      if OrderType.DataSet.Locate('STATUS',DataSet.FieldByName('STATUS').AsString,[]) then
        Result := StrToIntDef(OrderType.DataSet.FieldByName('ICON').AsString,-1);
      FStatusCache.Values[FieldByName(GetStatusFieldName).AsString] := IntToStr(Result);
    end;
end;

procedure TOrderList.Open;
begin
  with  DataSet as IBaseDBFilter, BaseApplication as IBaseDBInterface, DataSet as IBaseManageDB do
    begin
      if Filter='' then
        Filter := QuoteField('ACTIVE')+'='+QuoteValue('Y')+' or '+Data.ProcessTerm(QuoteField('ACTIVE')+'='+QuoteValue(''));;
    end;
  inherited Open;
end;

procedure TOrderList.OpenItem(AccHistory: Boolean);
var
  aHistory: TAccessHistory;
  aObj: TObjects;
  aID: String;
  aFilter: String;
begin
  if Self.Count=0 then exit;
  try
    try
      aHistory := TAccessHistory.Create(nil);
      aObj := TObjects.Create(nil);
      if AccHistory then
        begin
          if DataSet.State<>dsInsert then
            begin
              if not Data.TableExists(aHistory.TableName) then
                aHistory.CreateTable;
              aHistory.Free;
              aHistory := TAccessHistory.CreateEx(nil,Data,nil,DataSet);
              aHistory.AddItem(DataSet,Format(strItemOpened,[Data.GetLinkDesc(Data.BuildLink(DataSet))]),Data.BuildLink(DataSet));
            end;
        end;
      if (DataSet.State<>dsInsert) and (DataSet.FieldByName('NUMBER').IsNull) then
        begin
          if not Data.TableExists(aObj.TableName) then
            begin
              aObj.CreateTable;
              aObj.Free;
              aObj := TObjects.CreateEx(nil,Data,nil,DataSet);
            end;
          with aObj.DataSet as IBaseDBFilter do
            begin
              aID := FieldByName('ORDERNO').AsString;
              if length(aID) > 4 then
                begin
                  aFilter :=         '('+Data.QuoteField('NUMBER')+'>='+Data.QuoteValue(copy(aID,0,length(aID)-2)+'00')+') and ';
                  aFilter := aFilter+'('+Data.QuoteField('NUMBER')+'<='+Data.QuoteValue(copy(aID,0,length(aID)-2)+'99')+')';
                end
              else
                aFilter :=  Data.QuoteField('NUMBER')+'='+Data.QuoteValue(aID);
              Filter := aFilter;
              Limit := 0;
            end;
          aObj.Open;
          if aObj.Count=0 then
            begin
              aObj.Insert;
              aObj.Text.AsString := Data.GetLinkDesc(Data.BuildLink(Self.DataSet));
              aObj.FieldByName('SQL_ID').AsVariant:=Self.Id.AsVariant;
              if Assigned(Self.Matchcode) then
                aObj.Matchcode.AsString := Self.Matchcode.AsString;
              if Assigned(Self.Status) then
                aObj.Status.AsString := Self.Status.AsString;
              aObj.Number.AsVariant:=Self.Number.AsVariant;
              aObj.FieldByName('LINK').AsString:=Data.BuildLink(Self.DataSet);
              aObj.FieldByName('ICON').AsInteger:=Data.GetLinkIcon(Data.BuildLink(Self.DataSet),True);
              aObj.Post;
              Self.GenerateThumbnail;
            end
          else //Modify existing
            begin
              while aObj.Count>1 do
                aObj.Delete;
              if aObj.Text.AsString<>Data.GetLinkDesc(Data.BuildLink(Self.DataSet)) then
                begin
                  aObj.Edit;
                  aObj.Text.AsString := Data.GetLinkDesc(Data.BuildLink(Self.DataSet));
                end;
              if aObj.Number.AsString<>Self.Number.AsString then
                begin
                  aObj.Edit;
                  aObj.Number.AsString := Self.Number.AsString;
                end;
              if Assigned(Self.Status) and (aObj.Status.AsString<>Self.Status.AsString) then
                begin
                  aObj.Edit;
                  aObj.Status.AsString := Self.Status.AsString;
                end;
              if aObj.FieldByName('LINK').AsString<>Data.BuildLink(Self.DataSet) then
                begin
                  aObj.Edit;
                  aObj.FieldByName('LINK').AsString:=Data.BuildLink(Self.DataSet);
                end;
              if aObj.CanEdit then
                aObj.Post;
            end;
        end;
    finally
      aObj.Free;
      aHistory.Free;
    end;
  except
  end;
end;

procedure TOrderList.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'ORDERS';
      TableCaption := strOrders;
      UpdateFloatFields:=True;
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('ORDERNO',ftInteger,0,True);
            Add('ACTIVE',ftString,1,False);
            Add('STATUS',ftString,4,True);
            Add('LANGUAGE',ftString,3,False);
            Add('DATE',ftDate,0,False);
            Add('NUMBER',ftString,20,False);
            Add('CUSTNO',ftString,20,False);
            Add('CUSTNAME',ftString,200,False);
            Add('DOAFQ',ftDate,0,False);                    //Anfragedatum
            Add('DWISH',ftDate,0,False);                    //Wunschdatum
            Add('DAPPR',ftDate,0,False);                    //Bestätigt (Approved)
            Add('ODATE',ftDate,0,False);                    //Original Date
            Add('STORAGE',ftString,3,False);
            Add('CURRENCY',ftString,5,False);
            Add('PAYMENTTAR',ftString,2,False);
            Add('PID',ftString,50,False);                   //Produktid wird mit Artikeln befüllt die hinzugefügt werden beim Produktionsauftrag = zu Fertigender Artikel
            Add('PVERSION',ftString,8,False);               //Version des zu fertigen Artikels
            Add('PLANGUAGE',ftString,4,False);              //Sprache des zu fertigen Artikels
            Add('PQUATITY',ftFloat,0,False);                //Fertigungsmenge
            Add('SHIPPING',ftString,3,False);
            Add('SHIPPINGD',ftDate,0,False);
            Add('WEIGHT',ftFloat,0,False);
            Add('VATH',ftFloat,0,False);                   //Halbe MwSt
            Add('VATF',ftFloat,0,False);                   //Volle MwSt
            Add('NETPRICE',ftFloat,0,False);                //Nettopreis
            Add('DISCPRICE',ftFloat,0,False);              //Skontopreis
            Add('DISCOUNT',ftFloat,0,False);                //Rabatt
            Add('GROSSPRICE',ftFloat,0,False);              //Bruttoprice
            Add('DONE',ftString,1,False);
            Add('DELIVERED',ftString,1,False);
            Add('PAYEDON',ftDate,0,False);
            Add('DELIVEREDON',ftDate,0,False);
            Add('COMMISSION',ftString,30,False);
            Add('PROJECTID',ftLargeInt,0,False);
            Add('PROJECT',ftString,260,False);
            Add('PROJECTNR',ftString,20,False);
            Add('NOTE',ftMemo,0,False);
            Add('HEADERTEXT',ftMemo,0,False);
            Add('FOOTERTEXT',ftMemo,0,False);
            Add('CHANGEDBY',ftString,4,False);
            Add('CREATEDBY',ftString,4,False);
          end;
      if Assigned(ManagedIndexdefs) then
        with ManagedIndexDefs do
          begin
            Add('ORDERNO','ORDERNO',[ixUnique]);
            Add('NUMBER','NUMBER',[]);
            Add('DATE','DATE',[]);
            Add('ODATE','ODATE',[]);
            Add('STATUS','STATUS',[]);
            Add('CUSTNO','CUSTNO',[]);
            Add('CUSTNAME','CUSTNAME',[]);
          end;
      if Data.ShouldCheckTable(TableName) then
        DefineUserFields(aDataSet);
    end;
end;

function TOrderList.SelectOrderType: Boolean;
begin
  Result := FOrderTyp.Locate('STATUS',DataSet.FieldByName('STATUS').AsString,[]);
end;

initialization
end.

