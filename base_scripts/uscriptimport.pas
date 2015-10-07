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
Created 11.06.2012
*******************************************************************************}
unit uscriptimport;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ButtonPanel, ExtCtrls, Buttons, EditBtn, ActnList, db,uprometpascalscript,
  DBGrids,uprometscripts;

type
  TImporterCapability = (icImport,icExport);
  TImporterCapabilities = set of TImporterCapability;

  { TfScriptImport }

  TfScriptImport = class(TForm)
    acConfig: TAction;
    ActionList1: TActionList;
    bpButtons: TButtonPanel;
    cbFormat: TComboBox;
    eDataSource: TEditButton;
    Label1: TLabel;
    Label2: TLabel;
    lInfo: TLabel;
    OpenDialog: TOpenDialog;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    procedure acConfigExecute(Sender: TObject);
    procedure cbFormatSelect(Sender: TObject);
    procedure eDataSourceButtonClick(Sender: TObject);
    procedure lInfoResize(Sender: TObject);
  private
    FTyp : TImporterCapability;
    FFormat : string;
    aScripts: TBaseScript;
    procedure CheckAll;
    { private declarations }
  public
    { public declarations }
    function Execute(Typ : TImporterCapability;DefaultFormat : string = '';DataSet : TDataSet=nil;BookMarks : TBookmarkList = nil) : Boolean;
  end;

var
  fScriptImport: TfScriptImport;

resourcestring
  strPleaseenteranFormatName            = 'Bitte geben Sie einen Namen für das Format an !';
  strImporterclassnotFound              = 'Datenquellenklasse wurde nicht gefunden !';
  strPleasSelectanImportfilebeforeEdit  = 'Bitte wählen Sie eine Datenquellenklasse !';
  strSelectAnFormat                     = 'Bitte wählen Sie ein Datenformat, oder erstellen Sie ein neues. Geben Sie dazu einen Namen für das neue Format ein, und klicken Sie den Konfigurieren Knopf.';
  strSelectAnDataSource                 = 'Bitte wählen Sie eine Datenquelle';
  strCreateAnFormat                     = 'Bitte erstellen Sei ein Datenformat. Geben Sie dazu einen Namen für das neue Format ein, und klicken Sie den Konfigurieren Knopf.';
  strConfigureDataSource                = 'Setzen Sie die Quelle / Einstellungen der Datenquelle und klicken Sie OK';
  strDataImport                         = 'Datenimport';
  strDataExport                         = 'Datenexport';
  strDataSource                         = 'Datenquelle';
  strDataDestination                    = 'Datenausgabe';
  strErrorCompiling                     = 'Fehlerhafters Importscript';

implementation

uses uScriptEditor,uData,genpascalscript,variants,uError;

{$R *.lfm}

{ TfScriptImport }

procedure TfScriptImport.acConfigExecute(Sender: TObject);
begin
  if cbFormat.Text='' then
    Showmessage(strPleaseenteranFormatName)
  else
    begin
      if FTyp=icImport then
        fScriptEditor.Execute('Import.'+FFormat+'.'+cbFormat.Text,Null)
      else
        fScriptEditor.Execute('Export.'+FFormat+'.'+cbFormat.Text,Null);
    end;
end;

procedure TfScriptImport.cbFormatSelect(Sender: TObject);
var
  aRes: Boolean;
  aResults: string = '';
  i: Integer;
begin
  if FTyp = icImport then
    aRes := aScripts.Locate('NAME','Import.'+FFormat+'.'+cbFormat.Text,[loCaseInsensitive])
  else
    aRes := aScripts.Locate('NAME','Export.'+FFormat+'.'+cbFormat.Text,[loCaseInsensitive]);
  if aRes then
    begin
      lInfo.Caption:=strConfigureDataSource;
      if (TBaseScript(aScripts).Script is TPascalScript) then
        with TBaseScript(aScripts).Script as TPascalScript do
          begin
            if not Compile then
              begin
                for i:= 0 to Compiler.MsgCount - 1 do
                  if Length(aResults) = 0 then
                    aResults:= Compiler.Msg[i].MessageToString
                  else
                    aResults:= aResults + #13#10 + Compiler.Msg[i].MessageToString;
                lInfo.Caption:=strErrorCompiling+' ('+aResults+')';
              end;
            try
              lInfo.Caption:=Runtime.RunProcPN([],'SOURCEDESCRIPTION');
            except
            end;
            OpenDialog.Filter:='';
            try
              OpenDialog.Filter:=Runtime.RunProcPN([],'FILEEXTENSION');
            except
            end;
          end;
    end
  else lInfo.Caption:=strSelectAnFormat;
end;

procedure TfScriptImport.eDataSourceButtonClick(Sender: TObject);
begin
  if OpenDialog.Filter<>'' then
    if OpenDialog.Execute then
      eDataSource.Text:=OpenDialog.FileName;
end;

procedure TfScriptImport.lInfoResize(Sender: TObject);
begin
  Height := eDataSource.Top+eDataSource.Height+bpButtons.Height+30;
end;

procedure TfScriptImport.CheckAll;
begin

end;

function TfScriptImport.Execute(Typ: TImporterCapability;
  DefaultFormat: string; DataSet: TDataSet = nil; BookMarks: TBookmarkList=nil): Boolean;
var
  tmp: String;
  Records: String;
begin
  if not Assigned(Self) then
    begin
      Application.CreateForm(TfScriptImport,fScriptImport);
      Self := fScriptImport;
    end;
  Ftyp := Typ;
  fFormat := DefaultFormat;
  aScripts := TBaseScript.Create(nil);
  if FTyp=icImport then
    aScripts.Filter(Data.ProcessTerm(Data.QuoteField('NAME')+'='+Data.QuoteValue('Import.'+FFormat+'.*')))
  else
    aScripts.Filter(Data.ProcessTerm(Data.QuoteField('NAME')+'='+Data.QuoteValue('Export.'+FFormat+'.*')));
  aScripts.First;
  cbFormat.Items.Clear;
  cbFormat.Text:='';
  lInfo.Caption:=strSelectAnFormat;
  while not aScripts.EOF do
    begin
      tmp := copy(aScripts.Text.AsString,pos('.',aScripts.Text.AsString)+1,length(aScripts.Text.AsString));
      tmp := copy(tmp,pos('.',tmp)+1,length(tmp));
      cbFormat.Items.Add(tmp);
      aScripts.Next;
    end;
  Result := ShowModal = mrOK;
  if Result then
    begin
      if FTyp = icImport then
        Result := aScripts.Locate('NAME','Import.'+FFormat+'.'+cbFormat.Text,[loCaseInsensitive])
      else
        Result := aScripts.Locate('NAME','Export.'+FFormat+'.'+cbFormat.Text,[loCaseInsensitive]);
      if Result then
        begin
          uprometpascalscript.FContextDataSet := DataSet;
          Records := '';
          if Assigned(Bookmarks) then
            begin

            end;
          with TBaseScript(aScripts).Script as TPascalScript do
            begin
              Screen.Cursor:=crHourGlass;
              if FTyp = icImport then
                Result := Runtime.RunProcPN([eDataSource.Text],'DOIMPORT')
              else
                Result := Runtime.RunProcPN([eDataSource.Text,Records],'DOEXPORT');
              try
                if not Result then
                  begin
                    tmp := Runtime.RunProcPN([],'LASTERROR');
                  end;
              except
                tmp := 'unknown error';
              end;
              Screen.Cursor:=crDefault;
              if not Result then
                fError.ShowError(tmp);
            end;
          uprometpascalscript.FContextDataSet := nil;
        end
    end;
  aScripts.Free;
end;

end.

