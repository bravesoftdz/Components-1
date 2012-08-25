//////////////////////////////////////////////////////
//                                                  //
//   ThreadedTimer 1.24                             //
//                                                  //
//   Copyright (C) 1996, 2000 Carlos Barbosa        //
//   email: delphi@carlosb.com                      //
//   Home Page: http://www.carlosb.com              //
//                                                  //
//   Portions (C) 2000, Andrew N. Driazgov          //
//   email: andrey@asp.tstu.ru                      //
//                                                  //
//   Last updated: November 24, 2000                //
//   Modifications by Lasse Rautiainen (April 2004) //
//                                                  //
//////////////////////////////////////////////////////

unit ThdTimer;

{$WARNINGS OFF}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

const
  DEFAULT_INTERVAL = 1000;

type
  TThreadedTimer = class;

  TTimerThread = class(TThread)
  private
    FOwner: TThreadedTimer;
    FInterval: Cardinal;
    FStop: THandle;
  protected
    procedure Execute; override;
  end;

  TThreadedTimer = class(TComponent)
  private
    FOnTimer: TNotifyEvent;
    FTimerThread: TTimerThread;
    FEnabled,
    FAllowZero: Boolean;
    FStartTick: LongInt; { Added by LR }
    FPositionFromStart: LongInt; { Added by LR }
    function GetInterval: Cardinal;
    function GetThreadPriority: TThreadPriority;
    procedure DoTimer;
    procedure SetEnabled(Value: Boolean);
    procedure SetInterval(Value: Cardinal);
    procedure SetThreadPriority(Value: TThreadPriority);
    procedure SetPosFromStart(Value: LongInt);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property AllowZero: Boolean read FAllowZero write FAllowZero default False;
    property Enabled: Boolean read FEnabled write SetEnabled default False;
    property Interval: Cardinal read GetInterval write SetInterval default DEFAULT_INTERVAL;
    property OnTimer: TNotifyEvent read FOnTimer write FOnTimer;
    property ThreadPriority: TThreadPriority read GetThreadPriority  write SetThreadPriority default tpNormal;
    property GetStartTick: LongInt read FStartTick; { Added by LR }
    property PositionFromStart: LongInt read FPositionFromStart write SetPosFromStart; { Added by LR }
  end;

procedure Register;

implementation

{ TTimerThread }

procedure TTimerThread.Execute;
begin
  repeat
    if WaitForSingleObject(FStop, FInterval) = WAIT_TIMEOUT then
      Synchronize(FOwner.DoTimer);
  until Terminated;
end;

{ TThreadedTimer }

constructor TThreadedTimer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTimerThread := TTimerThread.Create(True);
  FPositionFromStart := 0;
  with FTimerThread do
  begin
    FOwner := Self;
    FInterval := DEFAULT_INTERVAL;
    Priority := tpNormal;

    // Event is completely manipulated by TThreadedTimer object
    FStop := CreateEvent(nil, False, False, nil);
  end;
end;

destructor TThreadedTimer.Destroy;
begin
  with FTimerThread do
  begin
    FEnabled := False;
    
    Terminate;

    // When this method is called we must be confident that the event handle was not closed
    SetEvent(FStop);
    if Suspended then
      Resume;
    WaitFor;
    CloseHandle(FStop);  // Close event handle in the primary thread
    Free;
  end;
  inherited Destroy;
end;

procedure TThreadedTimer.DoTimer;
begin
  // We have to check FEnabled in the primary thread
  // Otherwise we get AV when the program is closed
  if FEnabled and Assigned(FOnTimer) and not (csDestroying in ComponentState) then
    try
      FOnTimer(Self);
    except
    end;
end;

procedure TThreadedTimer.SetEnabled(Value: Boolean);
begin
  if Value <> FEnabled then
  begin
    FEnabled := Value;
    if FEnabled then
    begin
      if (FTimerThread.FInterval > 0) or
        ((FTimerThread.FInterval = 0) and FAllowZero) then
      begin
        SetEvent(FTimerThread.FStop);
        FStartTick := LongInt(GetTickCount) - FPositionFromStart; { Added by LR }
        FTimerThread.Resume;
      end;
    end
    else
      begin
      FPositionFromStart := LongInt(GetTickCount) - FStartTick; { Added by LR }
      FTimerThread.Suspend;
      end
  end;
end;

function TThreadedTimer.GetInterval: Cardinal;
begin
  Result := FTimerThread.FInterval;
end;

procedure TThreadedTimer.SetInterval(Value: Cardinal);
var
  PrevEnabled: Boolean;
begin
  if Value <> FTimerThread.FInterval then
  begin
    PrevEnabled := FEnabled;
    Enabled := False;
    FTimerThread.FInterval := Value;
    Enabled := PrevEnabled;
  end;
end;

function TThreadedTimer.GetThreadPriority: TThreadPriority;
begin
  Result := FTimerThread.Priority;
end;

procedure TThreadedTimer.SetThreadPriority(Value: TThreadPriority);
begin
  FTimerThread.Priority := Value;
end;

procedure TThreadedTimer.SetPosFromStart(Value: LongInt);
begin
  if Value <> FPositionFromStart then
    FPositionFromStart := Value
end;

procedure Register;
begin
   RegisterComponents('bonecode', [TThreadedTimer]);
end;

end.

