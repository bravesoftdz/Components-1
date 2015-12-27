unit BCComponent.WndProcHook;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, Vcl.Controls, Vcl.Forms, System.Classes;

type
  TBCControlHook = function(var Msg: TMessage): Boolean of object;
  TBCHookMessageEvent = procedure(Sender: TObject; var Msg: TMessage; var Handled: Boolean) of object;

  TBCHookOrder = (hoBeforeMsg, hoAfterMsg);

  TBCWindowHook = class(TComponent)
  private
    FActive: Boolean;
    FControl: TControl;
    FBeforeMessage: TBCHookMessageEvent;
    FAfterMessage: TBCHookMessageEvent;
    procedure SetActive(Value: Boolean);
    procedure SetControl(Value: TControl);
    function IsForm: Boolean;
    function NotIsForm: Boolean;
    procedure ReadForm(Reader: TReader);
    procedure WriteForm(Writer: TWriter);
    procedure SetAfterMessage(const Value: TBCHookMessageEvent);
    procedure SetBeforeMessage(const Value: TBCHookMessageEvent);
  protected
    procedure DefineProperties(Filer: TFiler); override;
    function DoAfterMessage(var Msg: TMessage): Boolean; dynamic;
    function DoBeforeMessage(var Msg: TMessage): Boolean; dynamic;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure HookControl;
    procedure UnHookControl;
  published
    property Active: Boolean read FActive write SetActive default True;
    property Control: TControl read FControl write SetControl stored NotIsForm;
    property BeforeMessage: TBCHookMessageEvent read FBeforeMessage write SetBeforeMessage;
    property AfterMessage: TBCHookMessageEvent read FAfterMessage write SetAfterMessage;
  end;

function RegisterWndProcHook(AControl: TControl; Hook: TBCControlHook; const Order: TBCHookOrder): Boolean; overload;
function UnRegisterWndProcHook(AControl: TControl; Hook: TBCControlHook; const Order: TBCHookOrder): Boolean; overload;
procedure ReleaseObj(AObject: TObject);

implementation

type
  PBCHookInfo = ^TBCHookInfo;

  TBCHookInfo = record
    Hook: TBCControlHook;
    Next: PBCHookInfo;
  end;

  PHookInfoList = ^THookInfoList;
  THookInfoList = array [0 .. MaxInt div SizeOf(Pointer) - 1] of PBCHookInfo;

  TBCWndProcHook = class;

  TBCHookInfos = class(TObject)
  private
    FFirst: array [TBCHookOrder] of PBCHookInfo;
    FLast: array [TBCHookOrder] of PBCHookInfo;
    FStack: PHookInfoList;
    FStackCapacity: Integer;
    FStackCount: Integer;
    FHandle: THandle;
    FControl: TControl;
    FControlDestroyed: Boolean;
    FOldWndProc: TWndMethod;
    FOldWndProcHandle: TFarProc;
    FHooked: Boolean;
    FController: TBCWndProcHook;
    procedure SetController(const Value: TBCWndProcHook);
  protected
    procedure WindowProc(var Msg: TMessage);
    procedure HookControl;
    procedure UnHookControl;
    procedure IncDepth;
    procedure DecDepth;
  public
    constructor Create(AControl: TControl); overload;
    constructor Create(AHandle: THandle); overload;
    destructor Destroy; override;
    procedure Add(const Order: TBCHookOrder; Hook: TBCControlHook);
    procedure Delete(const Order: TBCHookOrder; Hook: TBCControlHook);
    procedure ControlDestroyed;
    property Control: TControl read FControl;
    property Controller: TBCWndProcHook read FController write SetController;
    property Handle: THandle read FHandle;
  end;

  TBCWndProcHook = class(TComponent)
  private
    FHookInfos: TList;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function IndexOf(AControl: TControl): Integer; overload;
    function IndexOf(AHandle: THandle): Integer; overload;
    function Find(AControl: TControl): TBCHookInfos; overload;
    function Find(AHandle: THandle): TBCHookInfos; overload;

    procedure Remove(AHookInfos: TBCHookInfos);
    procedure Add(AHookInfos: TBCHookInfos);
  public
    destructor Destroy; override;
    function RegisterWndProc(AControl: TControl; Hook: TBCControlHook; const Order: TBCHookOrder): Boolean; overload;
    function RegisterWndProc(AHandle: THandle; Hook: TBCControlHook; const Order: TBCHookOrder): Boolean; overload;
    function UnRegisterWndProc(AControl: TControl; Hook: TBCControlHook; const Order: TBCHookOrder): Boolean; overload;
    function UnRegisterWndProc(AHandle: THandle; Hook: TBCControlHook; const Order: TBCHookOrder): Boolean; overload;
  end;

  TBCReleaser = class(TObject)
  private
    FHandle: THandle;
    FReleasing: TList;
    function GetHandle: THandle;
    procedure CMRelease(var Msg: TMessage); message CM_RELEASE;
    procedure WndProc(var Msg: TMessage);
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure DefaultHandler(var Msg); override;
    class function Instance: TBCReleaser;
    procedure Release(AObject: TObject);
    property Handle: THandle read GetHandle;
  end;

var
  GWndProcHook: TBCWndProcHook = nil;
  GReleaser: TBCReleaser = nil;

function WndProcHook: TBCWndProcHook;
begin
  if GWndProcHook = nil then
    GWndProcHook := TBCWndProcHook.Create(nil);
  Result := GWndProcHook;
end;

function RegisterWndProcHook(AControl: TControl; Hook: TBCControlHook; const Order: TBCHookOrder): Boolean;
begin
  Result := WndProcHook.RegisterWndProc(AControl, Hook, Order);
end;

function UnRegisterWndProcHook(AControl: TControl; Hook: TBCControlHook; const Order: TBCHookOrder): Boolean;
begin
  Result := WndProcHook.UnRegisterWndProc(AControl, Hook, Order);
end;

procedure ReleaseObj(AObject: TObject);
begin
  TBCReleaser.Instance.Release(AObject);
end;

{ TBCWndProcHook }

procedure TBCWndProcHook.Add(AHookInfos: TBCHookInfos);
var
  I: Integer;
begin
  I := FHookInfos.IndexOf(AHookInfos);
  if I < 0 then
    FHookInfos.Add(AHookInfos);
end;

destructor TBCWndProcHook.Destroy;
begin
  if FHookInfos <> nil then
  begin
    while FHookInfos.Count > 0 do
      TBCHookInfos(FHookInfos[0]).Free;

    FHookInfos.Free;
  end;
  inherited Destroy;
end;

function TBCWndProcHook.Find(AHandle: THandle): TBCHookInfos;
var
  I: Integer;
begin
  I := IndexOf(AHandle);
  if I < 0 then
    Result := nil
  else
    Result := TBCHookInfos(FHookInfos[I]);
end;

function TBCWndProcHook.Find(AControl: TControl): TBCHookInfos;
var
  I: Integer;
begin
  I := IndexOf(AControl);
  if I < 0 then
    Result := nil
  else
    Result := TBCHookInfos(FHookInfos[I]);
end;

function TBCWndProcHook.IndexOf(AHandle: THandle): Integer;
begin
  Result := 0;
  while (Result < FHookInfos.Count) and (TBCHookInfos(FHookInfos[Result]).Handle <> AHandle) do
    Inc(Result);
  if Result = FHookInfos.Count then
    Result := -1;
end;

function TBCWndProcHook.IndexOf(AControl: TControl): Integer;
begin
  Result := 0;
  while (Result < FHookInfos.Count) and (TBCHookInfos(FHookInfos[Result]).Control <> AControl) do
    Inc(Result);
  if Result = FHookInfos.Count then
    Result := -1;
end;

procedure TBCWndProcHook.Notification(AComponent: TComponent; Operation: TOperation);
var
  I: Integer;
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FHookInfos <> nil) and (AComponent is TControl) then
  begin
    I := IndexOf(TControl(AComponent));
    if I >= 0 then
      TBCHookInfos(FHookInfos[I]).ControlDestroyed;
  end;
end;

function TBCWndProcHook.RegisterWndProc(AControl: TControl; Hook: TBCControlHook; const Order: TBCHookOrder): Boolean;
var
  HookInfos: TBCHookInfos;
begin
  Result := False;
  if not Assigned(AControl) or (csDestroying in AControl.ComponentState) or not Assigned(Hook) then
    Exit;

  if FHookInfos = nil then
    FHookInfos := TList.Create;

  HookInfos := Find(AControl);
  if not Assigned(HookInfos) then
  begin
    HookInfos := TBCHookInfos.Create(AControl);
    HookInfos.Controller := Self;
    AControl.FreeNotification(Self);
  end;
  HookInfos.Add(Order, Hook);

  Result := True;
end;

function TBCWndProcHook.RegisterWndProc(AHandle: THandle; Hook: TBCControlHook; const Order: TBCHookOrder): Boolean;
var
  HookInfos: TBCHookInfos;
begin
  Result := False;
  if not Assigned(Hook) then
    Exit;
  if FHookInfos = nil then
    FHookInfos := TList.Create;

  HookInfos := Find(AHandle);
  if not Assigned(HookInfos) then
  begin
    HookInfos := TBCHookInfos.Create(AHandle);
    HookInfos.Controller := Self;
  end;
  HookInfos.Add(Order, Hook);

  Result := True;
end;

procedure TBCWndProcHook.Remove(AHookInfos: TBCHookInfos);
var
  I: Integer;
begin
  I := FHookInfos.IndexOf(AHookInfos);
  if I >= 0 then
    FHookInfos.Delete(I);
end;

function TBCWndProcHook.UnRegisterWndProc(AHandle: THandle; Hook: TBCControlHook; const Order: TBCHookOrder): Boolean;
var
  HookInfos: TBCHookInfos;
begin
  Result := False;
  if not Assigned(Hook) or not Assigned(FHookInfos) then
    Exit;
  HookInfos := Find(AHandle);
  Result := Assigned(HookInfos);
  if Result then
    HookInfos.Delete(Order, Hook);
end;

function TBCWndProcHook.UnRegisterWndProc(AControl: TControl; Hook: TBCControlHook; const Order: TBCHookOrder): Boolean;
var
  HookInfos: TBCHookInfos;
begin
  Result := False;
  if not Assigned(AControl) or not Assigned(Hook) or not Assigned(FHookInfos) then
    Exit;
  HookInfos := Find(AControl);
  Result := Assigned(HookInfos);
  if Result then
    HookInfos.Delete(Order, Hook);
end;

{ TBCHookInfos }

procedure TBCHookInfos.Add(const Order: TBCHookOrder; Hook: TBCControlHook);
var
  HookInfo: PBCHookInfo;
  I: Integer;
begin
  New(HookInfo);
  HookInfo.Hook := Hook;
  HookInfo.Next := nil;

  if FFirst[Order] = nil then
    FFirst[Order] := HookInfo;

  if FLast[Order] <> nil then
    FLast[Order].Next := HookInfo;

  FLast[Order] := HookInfo;

  if Order = hoBeforeMsg then
    I := 0
  else
    I := 1;
  while I < FStackCount * 2 do
  begin
    if FStack[I] = nil then
      FStack[I] := HookInfo;
    Inc(I, 2);
  end;

  HookControl;
end;

procedure TBCHookInfos.ControlDestroyed;
begin
  if FControlDestroyed then
    Exit;

  FControlDestroyed := True;
  FOldWndProc := nil;
  FOldWndProcHandle := nil;

  Controller := nil;
  ReleaseObj(Self);
end;

constructor TBCHookInfos.Create(AControl: TControl);
begin
  inherited Create;
  FControl := AControl;
  FillChar(FFirst, SizeOf(FFirst), 0);
  FillChar(FLast, SizeOf(FLast), 0);
end;

constructor TBCHookInfos.Create(AHandle: THandle);
begin
  inherited Create;
  FHandle := AHandle;
  FillChar(FFirst, SizeOf(FFirst), 0);
  FillChar(FLast, SizeOf(FLast), 0);
end;

procedure TBCHookInfos.DecDepth;
begin
  if FStackCount > 0 then
    Dec(FStackCount);
end;

procedure TBCHookInfos.Delete(const Order: TBCHookOrder; Hook: TBCControlHook);
var
  HookInfo: PBCHookInfo;
  PrevHookInfo: PBCHookInfo;
  I: Integer;
begin
  HookInfo := FFirst[Order];
  PrevHookInfo := nil;
  while (HookInfo <> nil) and ((TMethod(HookInfo.Hook).Code <> TMethod(Hook).Code) or
    (TMethod(HookInfo.Hook).Data <> TMethod(Hook).Data)) do
  begin
    PrevHookInfo := HookInfo;
    HookInfo := HookInfo.Next;
  end;

  if not Assigned(HookInfo) then
    Exit;

  if PrevHookInfo <> nil then
    PrevHookInfo.Next := HookInfo.Next;

  if FLast[Order] = HookInfo then
    FLast[Order] := PrevHookInfo;
  if FFirst[Order] = HookInfo then
    FFirst[Order] := HookInfo.Next;

  if Order = hoBeforeMsg then
    I := 0
  else
    I := 1;
  while I < FStackCount * 2 do
  begin
    if FStack[I] = HookInfo then
      FStack[I] := HookInfo.Next;
    Inc(I, 2);
  end;

  Dispose(HookInfo);

  if (FFirst[hoBeforeMsg] = nil) and (FFirst[hoAfterMsg] = nil) then
    UnHookControl;
end;

destructor TBCHookInfos.Destroy;
var
  HookInfo: PBCHookInfo;
  Order: TBCHookOrder;
begin
  Controller := nil;

  UnHookControl;

  for Order := Low(TBCHookOrder) to High(TBCHookOrder) do
    while FFirst[Order] <> nil do
    begin
      HookInfo := FFirst[Order];
      FFirst[Order] := HookInfo.Next;
      Dispose(HookInfo);
    end;
  FreeMem(FStack);

  inherited Destroy;
end;

procedure TBCHookInfos.HookControl;
begin
  if FHooked or FControlDestroyed then
    Exit;
  if FControl <> nil then
  begin
    FOldWndProc := FControl.WindowProc;
    FOldWndProcHandle := nil;
    FControl.WindowProc := WindowProc;
    FHooked := True;
  end
  else
  begin
    FOldWndProc := nil;
    FOldWndProcHandle := TFarProc(SetWindowLongPtr(FHandle, GWL_WNDPROC, LONG_PTR(MakeObjectInstance(WindowProc))));
    FHooked := True;
  end;
end;

procedure TBCHookInfos.IncDepth;
begin
  if FStackCount >= FStackCapacity then
  begin
    Inc(FStackCapacity);
    FStackCapacity := FStackCapacity * 2;
    ReallocMem(FStack, 2 * FStackCapacity * SizeOf(Pointer));
  end;
  Inc(FStackCount);
end;

procedure TBCHookInfos.SetController(const Value: TBCWndProcHook);
begin
  if Value <> FController then
  begin
    if Assigned(FController) then
      FController.Remove(Self);

    FController := Value;

    if Assigned(FController) then
      FController.Add(Self);
  end;
end;

procedure TBCHookInfos.UnHookControl;
var
  Ptr: TFarProc;
begin
  if not FHooked or FControlDestroyed then
    Exit;
  if FControl <> nil then
  begin
    FControl.WindowProc := FOldWndProc;
    FHooked := False;
  end
  else
  begin
    Ptr := TFarProc(SetWindowLongPtr(FHandle, GWL_WNDPROC, LONG_PTR(FOldWndProcHandle)));
    FreeObjectInstance(Ptr);
    FHooked := False;
  end;
end;

procedure TBCHookInfos.WindowProc(var Msg: TMessage);
var
  TmpHookInfo: PBCHookInfo;
  Index: Integer;
begin
  Msg.Result := 0;

  IncDepth;
  try
    Index := 2 * (FStackCount - 1);
    FStack[Index] := FFirst[hoBeforeMsg];
    while Assigned(FStack[Index]) do
    begin
      TmpHookInfo := FStack[Index];
      FStack[Index] := FStack[Index].Next;
      if TmpHookInfo.Hook(Msg) or FControlDestroyed then
        Exit;
    end;

    if Assigned(FOldWndProc) then
      FOldWndProc(Msg)
    else if FOldWndProcHandle <> nil then
      Msg.Result := CallWindowProc(FOldWndProcHandle, Handle, Msg.Msg, Msg.WParam, Msg.LParam);

    if FControlDestroyed then
      Exit;

    Index := 2 * FStackCount - 1;
    FStack[Index] := FFirst[hoAfterMsg];
    while Assigned(FStack[Index]) do
    begin
      TmpHookInfo := FStack[Index];
      FStack[Index] := FStack[Index].Next;
      if TmpHookInfo.Hook(Msg) or FControlDestroyed then
        Exit;
    end;
  finally
    DecDepth;
    if (Control = nil) and (Msg.Msg = WM_DESTROY) then
      ControlDestroyed;
  end;
end;

{ TBCWindowHook }

constructor TBCWindowHook.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FActive := True;
end;

procedure TBCWindowHook.DefineProperties(Filer: TFiler);

  function DoWrite: Boolean;
  begin
    if Assigned(Filer.Ancestor) then
      Result := IsForm <> TBCWindowHook(Filer.Ancestor).IsForm
    else
      Result := IsForm;
  end;

begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('IsForm', ReadForm, WriteForm, DoWrite);
end;

destructor TBCWindowHook.Destroy;
begin
  Active := False;
  Control := nil;
  inherited Destroy;
end;

function TBCWindowHook.DoAfterMessage(var Msg: TMessage): Boolean;
begin
  Result := False;
  if Assigned(FAfterMessage) then
    FAfterMessage(Self, Msg, Result);
end;

function TBCWindowHook.DoBeforeMessage(var Msg: TMessage): Boolean;
begin
  Result := False;
  if Assigned(FBeforeMessage) then
    FBeforeMessage(Self, Msg, Result);
end;

procedure TBCWindowHook.HookControl;
begin
  SetActive(True);
end;

function TBCWindowHook.IsForm: Boolean;
begin
  Result := (Control <> nil) and ((Control = Owner) and (Owner is TCustomForm));
end;

procedure TBCWindowHook.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
  begin
    if AComponent = Control then
      Control := nil
    else
    if (Owner = AComponent) or (Owner = nil) then
      Control := nil;
  end;
end;

function TBCWindowHook.NotIsForm: Boolean;
begin
  Result := (Control <> nil) and not(Control is TCustomForm);
end;

procedure TBCWindowHook.ReadForm(Reader: TReader);
begin
  if Reader.ReadBoolean then
    if Owner is TCustomForm then
      Control := TControl(Owner);
end;

procedure TBCWindowHook.SetActive(Value: Boolean);
begin
  if FActive = Value then
    Exit;

  if not(csDesigning in ComponentState) then
  begin
    if Value then
    begin
      if Assigned(FAfterMessage) then
        WndProcHook.RegisterWndProc(FControl, DoAfterMessage, hoAfterMsg);
      if Assigned(FBeforeMessage) then
        WndProcHook.RegisterWndProc(FControl, DoBeforeMessage, hoBeforeMsg);
    end
    else
    begin
      if Assigned(FAfterMessage) then
        WndProcHook.UnRegisterWndProc(FControl, DoAfterMessage, hoAfterMsg);
      if Assigned(FBeforeMessage) then
        WndProcHook.UnRegisterWndProc(FControl, DoBeforeMessage, hoBeforeMsg);
    end;
  end;
  FActive := Value;
end;

procedure TBCWindowHook.SetAfterMessage(const Value: TBCHookMessageEvent);
begin
  if Active and not(csDesigning in ComponentState) then
  begin
    if Assigned(Value) and not Assigned(FAfterMessage) then
      WndProcHook.RegisterWndProc(FControl, DoAfterMessage, hoAfterMsg)
    else if not Assigned(Value) and Assigned(FAfterMessage) then
      WndProcHook.UnRegisterWndProc(FControl, DoAfterMessage, hoAfterMsg);
  end;
  FAfterMessage := Value;
end;

procedure TBCWindowHook.SetBeforeMessage(const Value: TBCHookMessageEvent);
begin
  if Active and not(csDesigning in ComponentState) then
  begin
    if Assigned(Value) and not Assigned(FBeforeMessage) then
      WndProcHook.RegisterWndProc(FControl, DoBeforeMessage, hoBeforeMsg)
    else if not Assigned(Value) and Assigned(FBeforeMessage) then
      WndProcHook.UnRegisterWndProc(FControl, DoBeforeMessage, hoBeforeMsg);
  end;
  FBeforeMessage := Value;
end;

procedure TBCWindowHook.SetControl(Value: TControl);
var
  SavedActive: Boolean;
begin
  if Value <> Control then
  begin
    SavedActive := Active;
    Active := False;
    if FControl <> nil then
      FControl.RemoveFreeNotification(Self);

    if Assigned(Value) and (csDestroying in Value.ComponentState) then
      FControl := nil
    else
    begin
      FControl := Value;

      if FControl <> nil then
        FControl.FreeNotification(Self);

      Active := SavedActive;
    end;
  end;
end;

procedure TBCWindowHook.UnHookControl;
begin
  SetActive(False);
end;

procedure TBCWindowHook.WriteForm(Writer: TWriter);
begin
  Writer.WriteBoolean(IsForm);
end;

{ TBCReleaser }

procedure TBCReleaser.CMRelease(var Msg: TMessage);
var
  Obj: TObject;
  Index: Integer;
begin
  Obj := TObject(Msg.WParam);
  Index := FReleasing.IndexOf(Obj);
  if Index >= 0 then
    FReleasing.Delete(Index);
  Obj.Free;
end;

constructor TBCReleaser.Create;
begin
  inherited Create;
  FReleasing := TList.Create;
end;

procedure TBCReleaser.DefaultHandler(var Msg);
begin
  with TMessage(Msg) do
    if FHandle <> 0 then
      Result := CallWindowProc(@DefWindowProc, FHandle, Msg, WParam, LParam);
end;

destructor TBCReleaser.Destroy;
begin
  while FReleasing.Count > 0 do
  begin
    TObject(FReleasing[0]).Free;
    FReleasing.Delete(0);
  end;

  FReleasing.Free;
  if FHandle <> 0 then
    DeallocateHWnd(FHandle);

  inherited Destroy;
end;

function TBCReleaser.GetHandle: THandle;
begin
  if FHandle = 0 then
    FHandle := AllocateHWnd(WndProc);
  Result := FHandle;
end;

class function TBCReleaser.Instance: TBCReleaser;
begin
  if GReleaser = nil then
    GReleaser := TBCReleaser.Create;
  Result := GReleaser;
end;

procedure TBCReleaser.Release(AObject: TObject);
begin
  if FReleasing.IndexOf(AObject) < 0 then
  begin
    FReleasing.Add(AObject);
    PostMessage(Handle, CM_RELEASE, WParam(AObject), 0);
  end;
end;

procedure TBCReleaser.WndProc(var Msg: TMessage);
begin
  try
    Dispatch(Msg);
  except
    if Assigned(ApplicationHandleException) then
      ApplicationHandleException(Self);
  end;
end;

initialization

finalization

  GReleaser.Free;
  if Assigned(GWndProcHook) then
    FreeAndNil(GWndProcHook);
  GReleaser := nil;

end.
