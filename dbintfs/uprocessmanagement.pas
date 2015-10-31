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
*******************************************************************************}
unit uProcessManagement;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils,uBaseDbClasses,db,Process,uBaseDatasetInterfaces,syncobjs;
type

  { TProcProcess }

  TProcProcess = class(TThread)
  private
    FActive: Boolean;
    FCommandline: string;
    FId: Variant;
    FInformed: Boolean;
    FName: string;
    FOutput: TStringList;
    FStarted: TDateTime;
    FStopped: TDateTime;
    FTimeout: TDateTime;
    FStatus : string;
    p: TProcess;
    FCS : TCriticalSection;
    OutputLine: String;
    function GetActive: Boolean;
    function GetOutput: string;
    function GetStatus: string;
    procedure SetActive(AValue: Boolean);
    procedure SetTimeout(AValue: TDateTime);
    procedure DoOutputLine;
  public
    aOutput,aBuffer,aLogOutput : string;
    constructor Create;
    destructor Destroy; override;
    property Informed : Boolean read FInformed write FInformed;
    property Name : string read FName write FName;
    property Id : Variant read FId write FId;
    property Started : TDateTime read FStarted;
    property Stopped : TDateTime read FStopped;
    procedure Start;
    procedure Stop;
    property Active : Boolean read GetActive write SetActive;
    procedure Lock;
    procedure Unlock;
    procedure Execute; override;
    property Commandline : string read FCommandline write FCommandline;
    property Output : string read GetOutput;
    property Status : string read GetStatus;
  end;
  TProcessParameters = class(TBaseDBDataset)
  public
    procedure DefineFields(aDataSet: TDataSet); override;
  end;

  { TProcesses }

  TProcesses = class(TBaseDBDataset)
  private
    FProcessParameters: TProcessParameters;
    FScripts: TBaseDBDataset;
    function GetScripts: TBaseDBDataset;
  public
    constructor CreateEx(aOwner: TComponent; DM: TComponent;
      aConnection: TComponent=nil; aMasterdata: TDataSet=nil); override;
    procedure Open; override;
    destructor Destroy; override;
    function CreateTable : Boolean;override;
    procedure DefineFields(aDataSet: TDataSet); override;
    procedure FillDefaults(aDataSet: TDataSet); override;
    property Parameters : TProcessParameters read FProcessParameters;
    property Scripts : TBaseDBDataset read GetScripts;
  end;

  { TProcessClient }

  TProcessClient = class(TBaseDBDataset)
  private
    FLastRefresh: TDateTime;
    FProcesses: TProcesses;
    ProcessData : array of TProcProcess;
  public
    constructor CreateEx(aOwner: TComponent; DM: TComponent;
       aConnection: TComponent=nil; aMasterdata: TDataSet=nil); override;
    destructor Destroy; override;
    function CreateTable : Boolean;override;
    procedure DefineFields(aDataSet: TDataSet); override;
    property Processes : TProcesses read FProcesses;
    property LastRefresh : TDateTime read FLastRefresh;
    procedure RefreshList;
    procedure Startup;
    procedure ShutDown;
    function ProcessAll(aSystem : string = '') : Boolean;
    procedure RefreshStatus(aProc: TProcProcess; aLog: TStringList);
    function Process(OnlyActiveRow : Boolean = False;DoAlwasyRun : Boolean = False) : Boolean;
  end;

implementation
uses uBaseDBInterface,uData,Utils,uBaseApplication,uIntfStrConsts,math,
  uprometscripts;

procedure TProcProcess.SetActive(AValue: Boolean);
begin
  if FActive=AValue then Exit;
  FActive:=AValue;
  if FActive then Resume;
end;

function TProcProcess.GetActive: Boolean;
begin
  Lock;
  Result := FActive;
  UnLock;
end;

function TProcProcess.GetOutput: string;
begin
  Lock;
  Result := FOutput.Text;
  UnLock;
end;

function TProcProcess.GetStatus: string;
begin
  Lock;
  Result := FStatus;
  Unlock;
end;

procedure TProcProcess.SetTimeout(AValue: TDateTime);
begin
  if FTimeout=AValue then Exit;
  FTimeout:=AValue;
end;

procedure TProcProcess.DoOutputLine;
begin
  Lock;
  if OutputLine<>'' then
    begin
      FOutput.Add(OutputLine);
      with BaseApplication as IBaseApplication do
        Debug(FName+':'+OutputLine);
    end;
  Unlock;
end;

constructor TProcProcess.Create;
begin
  FOutput:=TStringList.Create;
  FCS := TCriticalSection.Create;
  inherited Create(True);
end;

destructor TProcProcess.Destroy;
begin
  Stop;
  FCS.Free;
  inherited Destroy;
  FOutput.Free;
end;

procedure TProcProcess.Start;
begin
  FStarted := Now();
  FActive:=True;
  FOutput.Clear;
  with BaseApplication as IBaseApplication do
    Debug(FName+':resuming Process');
  Resume;
end;

procedure TProcProcess.Stop;
begin
  try
    if Assigned(p) then
      p.Terminate(255);
    FActive:=False;
  except
  end;
end;

procedure TProcProcess.Lock;
begin
  FCS.Enter;
end;

procedure TProcProcess.Unlock;
begin
  FCS.Leave;
end;

procedure TProcProcess.Execute;
var
  Buf: string;
  Count,LineStart: LongInt;
  i: Integer;
const
  BufSize = 1024; //4096;
begin
  while not Terminated do
    begin
      p := TProcess.Create(nil);
      p.Options := [poUsePipes, poStdErrToOutPut, poNoConsole];
      //p.ShowWindow := swoHIDE;
    //  AddMessage('Compile command: ' + c);
      p.CommandLine := FCommandline;
      p.CurrentDirectory:= copy(BaseApplication.Location,0,rpos(DirectorySeparator,BaseApplication.Location)-1);
      try
        try
          with BaseApplication as IBaseApplication do
            Debug(FName+':starting...');
          p.Active:=True;
          Lock;
          FStatus:='R';
          Unlock;
          OutputLine:='';
          with BaseApplication as IBaseApplication do
            Debug(FName+':running...');

          { Now process the output }
          OutputLine:='';
          SetLength(Buf,BufSize);
          repeat
            if (p.Output<>nil) then
            begin
              Count:=p.Output.Read(Buf[1],Length(Buf));
            end
            else
              Count:=0;
            LineStart:=1;
            i:=1;
            while i<=Count do
            begin
              if Buf[i] in [#10,#13] then
              begin
                OutputLine:=OutputLine+Copy(Buf,LineStart,i-LineStart);
                DoOutputLine;
                OutputLine:='';
                if (i<Count) and (Buf[i+1] in [#10,#13]) and (Buf[i]<>Buf[i+1]) then
                  inc(i);
                LineStart:=i+1;
              end;
              inc(i);
            end;
            OutputLine:=Copy(Buf,LineStart,Count-LineStart+1);
            sleep(100);
          until (Count=0) or Terminated;
          if OutputLine <> '' then
            DoOutputLine;
          if not  Terminated then p.WaitOnExit;
          Lock;
          FStatus:='N';
          Unlock;
        except
          on e : Exception do
            begin
              Lock;
              FStatus:='E';
              OutputLine:=e.Message;
              Unlock;
              with BaseApplication as IBaseApplication do
                Debug(FName+':Error '+e.Message);
            end;
        end;
      finally
        FStopped := Now();
        FreeAndNil(p);
        FActive:=False;
      end;
      Lock;
      if FStatus='R' then
        FStatus:='N';
      Unlock;
      DoOutputLine;
      with BaseApplication as IBaseApplication do
        Debug(FName+':Stopped '+DateTimeToStr(FStopped));
      Suspend;
    end;
end;

procedure TProcessParameters.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'PROCESSPARAMETERS';
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('NAME',ftString,60,True);
            Add('VALUE',ftString,60,False);
          end;
    end;
end;

function TProcesses.GetScripts: TBaseDBDataset;
begin
  if not FScripts.Active then
    FScripts.Open;
  Result := FScripts;
end;

constructor TProcesses.CreateEx(aOwner: TComponent; DM: TComponent;
  aConnection: TComponent; aMasterdata: TDataSet);
begin
  inherited;
  FProcessParameters := TProcessParameters.CreateEx(Self, DM,aConnection,DataSet);
  FScripts := TBaseScript.CreateEx(Self,DM,aConnection);
end;

procedure TProcesses.Open;
begin
  inherited Open;
end;

destructor TProcesses.Destroy;
begin
  FScripts.Free;
  FProcessParameters.Destroy;
  inherited Destroy;
end;

function TProcesses.CreateTable : Boolean;
begin
  Result := inherited CreateTable;
  FProcessParameters.CreateTable;
end;

procedure TProcesses.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'PROCESS';
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('NAME',ftString,250,True);
            Add('INTERVAL',ftInteger,0,False);
            Add('STATUS',ftString,4,False);
            Add('STARTED',ftDateTime,0,False);
            Add('STOPPED',ftDateTime,0,False);
            Add('CLIENT',ftString,100,False);
            Add('LOG',ftMemo,0,False);
          end;
    end;
end;

procedure TProcesses.FillDefaults(aDataSet: TDataSet);
begin
  inherited FillDefaults(aDataSet);
  aDataSet.FieldByName('STATUS').AsString := 'N';
end;

constructor TProcessClient.CreateEx(aOwner: TComponent; DM: TComponent;
  aConnection: TComponent; aMasterdata: TDataSet);
begin
  inherited;
  FProcesses := TProcesses.CreateEx(Self, DM,aConnection,DataSet);
end;

destructor TProcessClient.Destroy;
var
  i: Integer;
begin
  FProcesses.Destroy;
  inherited Destroy;
end;

function TProcessClient.CreateTable : Boolean;
begin
  Result := inherited CreateTable;
  FProcesses.CreateTable;
end;

procedure TProcessClient.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'PROCESSCLIENTS';
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('NAME',ftString,60,True);
            Add('STATUS',ftString,4,True);
            Add('NOTES',ftString,200,False);
          end;
    end;
end;

procedure TProcessClient.RefreshList;
var
  aNow: TDateTime;
begin
  aNow := Now();
  if aNow>0 then
    begin
      //Refresh all Minute
      if aNow>(LastRefresh+((1/SecsPerDay)*60)) then
        begin
          DataSet.Refresh;
          Processes.DataSet.Refresh;
          FLastRefresh:=Now();
        end;
    end;
end;

procedure TProcessClient.Startup;
begin
  CreateTable;
  Open;
  if not DataSet.Locate('NAME',GetSystemName,[]) then
    begin
      Insert;
      DataSet.FieldByName('NAME').AsString:=GetSystemName;
      DataSet.FieldByName('STATUS').AsString:='R';
      DataSet.Post;
    end
  else
    begin
      DataSet.Edit;
      DataSet.FieldByName('STATUS').AsString:='R';
      DataSet.Post;
    end;
end;

procedure TProcessClient.ShutDown;
var
  i: Integer;
begin
  try
    for i := 0 to length(ProcessData)-1 do
      ProcessData[i].Free;
    SetLength(ProcessData,0);
    if DataSet.Locate('NAME',GetSystemName,[]) then
      begin
        DataSet.Edit;
        DataSet.FieldByName('STATUS').AsString:='N';
        DataSet.Post;
      end;
  except
  end;
end;

function TProcessClient.ProcessAll(aSystem: string): Boolean;
begin
  Result := True;
  if aSystem='' then
    aSystem:=GetSystemName;
  Open;
  if not Active then exit;
  if Locate('NAME','*',[]) then
    Process
  else
    begin
      Insert;
      FieldByName('NAME').AsString:='*';
      FieldByName('STATUS').AsString:='N';
      FieldByName('NOTES').AsString:=strRunsOnEveryMashine;
      Post;
      Process
    end;
  if DataSet.Locate('NAME',aSystem,[]) then
    begin
      if FieldByName('STATUS').AsString = '' then
        begin
          Edit;
          FieldByName('STATUS').AsString := 'R';
          Post;
        end;
      if FieldByName('STATUS').AsString = 'N' then
        begin
          Result := False;
          exit;
        end;
      Process;
    end;
end;

procedure TProcessClient.RefreshStatus(aProc: TProcProcess;aLog : TStringList);
var
  aProcesses: TProcesses;
begin
  aProcesses := TProcesses.Create(nil);
  aProcesses.Select(aproc.Id);
  aProcesses.Open;
  if aProcesses.Count>0 then
    begin
      if aProcesses.FieldByName('STATUS').AsString<>aProc.Status then
        begin
          aProcesses.Edit;
          aProcesses.FieldByName('STATUS').AsString:=aProc.Status;
          aProcesses.FieldByName('STARTED').AsDateTime:=aProc.Started;
          if (not aProc.Active) then
            aProcesses.FieldByName('STOPPED').AsDateTime:=aProc.Stopped
          else
            aProcesses.FieldByName('STOPPED').Clear;
          if aProc.Status='R' then
            aProcesses.FieldByName('LOG').Clear;
          aProcesses.FieldByName('CLIENT').AsString:=GetSystemName;
        end;
      if aProc.Output<>'' then
        begin
          aLog.Text:=aProcesses.FieldByName('LOG').AsString;
          aLog.Text:=aLog.Text+aProc.Output;
          aProcesses.Edit;
          aProcesses.FieldByName('LOG').AsString:=aLog.Text;
        end;
      aProcesses.Post;
    end;
  aProcesses.Free;
end;

function ExpandFileName(aDir : string) : string;
begin
  Result := aDir;
end;

function TProcessClient.Process(OnlyActiveRow: Boolean; DoAlwasyRun: Boolean
  ): Boolean;
var
  aLog: TStringList;
  aProcess: String;
  Found: Boolean;
  cmd: String;
  bProcess: TProcProcess;
  sl: TStringList;
  aNow: TDateTime;
  NewProcess: TProcProcess;
  aCount: DWord;
  tmp: String;
  bId : Variant;
  procedure DoLog(aStr: string;bLog : TStringList;SysLog : Boolean);
  begin
    with BaseApplication as IBaseApplication do
      if Syslog then
        Log(TimeToStr(Now())+':'+aStr);
    if bLog.Count>100 then
      bLog.Clear;
    bLog.Add(TimeToStr(Now())+':'+SysToUni(aStr));
  end;
  function BuildCmdLine : string;
  begin
    with Processes.Parameters.DataSet do
      begin
        First;
        while not EOF do
          begin
            cmd := cmd+' "--'+FieldByName('NAME').AsString+'='+FieldByName('VALUE').AsString+'"';
            Next;
          end;
      end;
    if pos('--mandant',lowercase(cmd)) = 0 then
      cmd := cmd+' "--mandant='+BaseApplication.GetOptionValue('m','mandant')+'"';
    if Data.Users.DataSet.Active then
      cmd := cmd+' "--user='+Data.Users.FieldByName('NAME').AsString+'"';
    if BaseApplication.HasOption('c','config-path') then
      cmd := cmd+' "--config-path='+BaseApplication.GetOptionValue('c','config-path')+'"';
  end;
  function ExecCommand(aClient : string;aNewStatus : string;aLastStopped : TDateTime;aInterval : Integer) : TProcProcess;
  var
    i: Integer;
    a: Integer;
    aStartTime: TDateTime;
    arec: LargeInt;
    aStatus: String;
  begin
    Result := nil;
    if aNewStatus='' then exit;
    Found := False;
    for i := 0 to length(ProcessData)-1 do
      if ProcessData[i].CommandLine = cmd then
        begin
          bProcess := ProcessData[i];
          Result := bProcess;
          if bProcess.Active then
            begin
              Found := True;
              sl := TStringList.Create;
              sl.Text:=bProcess.Output;
              while sl.Count>0 do
                begin
                  DoLog(aprocess+':'+sl[0],aLog,BaseApplication.HasOption('log'));
                  sl.Delete(0);
                end;
              sl.Free;
              if aNewStatus='N' then
                begin
                  bProcess.Stop;
                end
            end
          else
            begin
              aLog.Clear;
              aStartTime := Now();
              if aStartTime=0 then
                aStartTime:=Now();
              sl := TStringList.Create;
              sl.Text:=bProcess.Output;
              while sl.Count>0 do
                begin
                  DoLog(aprocess+':'+sl[0],aLog,BaseApplication.HasOption('log'));
                  sl.Delete(0);
                end;
              sl.Free;
              if not bProcess.Informed then
              else if Assigned(Processes) then
                if ((aNewStatus<>'R')
                and (aNow > (aLastStopped+(aInterval/MinsPerDay))))
                 or DoAlwasyRun then
                  begin
                    DoLog(aprocess+':'+strStartingProcessTimeout+' '+DateTimeToStr((aLastStopped+(max(aInterval,2)/MinsPerDay)))+'>'+DateTimeToStr(aNow),aLog,BaseApplication.HasOption('debug'));
                    DoLog(aProcess+':'+strStartingProcess+' ('+bProcess.CommandLine+')',aLog,True);
                    bProcess.Informed:=False;
                    bProcess.Start;
                    bProcess.Informed := False;
                  end;
              Found := True;
            end;
        end;
    if not Found then
      begin
        //Process is stopped and Timeout is overdune
        if (((aNewStatus<>'R') or (Processes.TimeStamp.AsDateTime<(aNow-(1)))) and (aNow > (aLastStopped+(aInterval/MinsPerDay))))
         //Process should always run
         or DoAlwasyRun
         //Process should be running on our client but were dont run it
         or ((aNewStatus='R') and (aClient=GetSystemName))
         then
          begin
            aStartTime := Now();
            aLog.Clear;
            DoLog(aProcess+':'+strStartingProcess+' ('+cmd+')',aLog,True);
            NewProcess := TProcProcess.Create;
            {$if FPC_FULLVERSION<20400}
            NewProcess.InheritHandles := false;
            {$endif}
            NewProcess.Id := Processes.Id.AsVariant;
            NewProcess.Informed:=False;
            NewProcess.Name:=aProcess;
            for i := 0 to Length(ProcessData)-1 do
              if ProcessData[i]=nil then break;
            if (length(ProcessData)<=i) or (not (ProcessData[i]=nil)) then
              begin
                Setlength(ProcessData,length(ProcessData)+1);
                i := length(ProcessData)-1;
              end;
            ProcessData[i] := NewProcess;
            NewProcess.CommandLine:=cmd;
            NewProcess.Start;
            Result := NewProcess;
          end;
      end;
  end;

  procedure ProcessRow;
  var
    aProc: TProcProcess = nil;
    i: Integer;
  begin
    aLog.Clear;
    aProcess := Processes.FieldByName('NAME').AsString;
    if FileExists(ExpandFileName(AppendPathDelim(BaseApplication.Location)+aProcess+ExtractFileExt(BaseApplication.ExeName))) then
      begin
        Found := False;
        cmd := AppendPathDelim(BaseApplication.Location)+aProcess+ExtractFileExt(BaseApplication.ExeName);
        cmd := cmd+BuildCmdLine;
        aProc := ExecCommand(Processes.FieldByName('CLIENT').AsString,Processes.FieldByName('STATUS').AsString,Processes.FieldByName('STOPPED').AsDateTime,Processes.FieldByName('INTERVAL').AsInteger);
      end
    else if FileExists(aProcess+ExtractFileExt(BaseApplication.ExeName)) then
      begin
        Found := False;
        cmd := aProcess+ExtractFileExt(BaseApplication.ExeName);
        cmd := cmd+BuildCmdLine;
        aProc := ExecCommand(Processes.FieldByName('CLIENT').AsString,Processes.FieldByName('STATUS').AsString,Processes.FieldByName('STOPPED').AsDateTime,Processes.FieldByName('INTERVAL').AsInteger);
      end
    else if FileExists('/usr/bin/'+aProcess+ExtractFileExt(BaseApplication.ExeName)) then
      begin
        Found := False;
        cmd := '/usr/bin/'+aProcess+ExtractFileExt(BaseApplication.ExeName);
        cmd := cmd+BuildCmdLine;
        aProc := ExecCommand(Processes.FieldByName('CLIENT').AsString,Processes.FieldByName('STATUS').AsString,Processes.FieldByName('STOPPED').AsDateTime,Processes.FieldByName('INTERVAL').AsInteger);
      end
    else if FileExists('/usr/local/bin/'+aProcess+ExtractFileExt(BaseApplication.ExeName)) then
      begin
        Found := False;
        cmd := '/usr/local/bin/'+aProcess+ExtractFileExt(BaseApplication.ExeName);
        cmd := cmd+BuildCmdLine;
        aProc := ExecCommand(Processes.FieldByName('CLIENT').AsString,Processes.FieldByName('STATUS').AsString,Processes.FieldByName('STOPPED').AsDateTime,Processes.FieldByName('INTERVAL').AsInteger);
      end
    else if Processes.Scripts.Locate('NAME',aProcess,[loCaseInsensitive]) then
      begin
        cmd := AppendPathDelim(BaseApplication.Location)+'pscript'+ExtractFileExt(BaseApplication.ExeName);
        if not FileExists(UniToSys(cmd)) then
          cmd := AppendPathDelim(BaseApplication.Location)+'tools'+DirectorySeparator+'pscript'+ExtractFileExt(BaseApplication.ExeName);
        if FileExists(UniToSys(cmd)) then
          begin
            cmd := cmd+BuildCmdLine;
            cmd := cmd+' '+aProcess;
            aProc := ExecCommand(Processes.FieldByName('CLIENT').AsString,Processes.FieldByName('STATUS').AsString,Processes.FieldByName('STOPPED').AsDateTime,Processes.FieldByName('INTERVAL').AsInteger);
          end
        else
          begin
            DoLog(cmd+':'+'PScript dosend exists',aLog,True);
            Processes.DataSet.Edit;
            Processes.DataSet.FieldByName('STATUS').AsString := 'E';
            Processes.DataSet.FieldByName('STOPPED').AsDateTime:=Processes.DataSet.FieldByName('STARTED').AsDateTime;
            if Processes.DataSet.FieldByName('LOG').AsString<>aLog.Text then
              Processes.DataSet.FieldByName('LOG').AsString := aLog.Text;
            Processes.DataSet.Post;
          end;
      end
    else
      begin
        DoLog(ExpandFileName(aProcess+ExtractFileExt(BaseApplication.ExeName))+':'+'File dosend exists',aLog,True);
        Processes.DataSet.Edit;
        Processes.DataSet.FieldByName('STATUS').AsString := 'E';
        Processes.DataSet.FieldByName('STOPPED').AsDateTime:=Processes.DataSet.FieldByName('STARTED').AsDateTime;
        if Processes.DataSet.FieldByName('LOG').AsString<>aLog.Text then
          Processes.DataSet.FieldByName('LOG').AsString := aLog.Text;
        Processes.DataSet.Post;
      end;
    //RefreshStatus
    if not aProc.Informed then
      DoLog(aprocess+':'+strExitted,aLog,True);
    if Assigned(aProc) then
      RefreshStatus(aProc,aLog);
    if (not aProc.Active) and (aProc.Informed) then
      begin
        for i := 0 to length(ProcessData)-1 do
          if ProcessData[i]=aProc then
            begin
              ProcessData[i]:=nil;
              FreeAndNil(aProc);
            end;
      end;
    if Assigned(aProc) and (not aProc.Informed) then
      aProc.Informed := True;
  end;

begin
  try
    aLog := TStringList.Create;
    aNow := Now();
    if aNow>0 then
      begin
        Processes.Open;
        Processes.Parameters.Open;
        //Check processes
        if OnlyActiveRow then
          ProcessRow
        else
          begin
            RefreshList;
            Processes.DataSet.First;
            while not Processes.DataSet.EOF do
              begin
                ProcessRow;
                Processes.DataSet.Next;
              end;
          end;
      end;
    aLog.Free;
  except
  end;
end;

end.

