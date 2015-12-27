unit BCComponent.DragDrop;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI, Winapi.ActiveX, System.Classes, Vcl.Controls;

type
  TBCDropEvent = procedure(Sender: TObject; Pos: TPoint; Value: TStrings) of object;
  TBCDropEffect = (deNone, deCopy, deMove, deLink, deScroll);

  TBCDragDrop = class(TComponent)
  private
    FAcceptDrag: Boolean;
    FStreamedAcceptDrag: Boolean;
    FFiles: TStringList;
    FOnDrop: TBCDropEvent;
    FIsHooked: Boolean;
    FTargetStrings: TStrings;
    FDropTarget: TWinControl;
    procedure DropFiles(Handle: HDROP);
    function GetFiles: TStrings;
    procedure SetAcceptDrag(Value: Boolean);
    procedure SetDropTarget(const Value: TWinControl);
    function WndProc(var Msg: TMessage): Boolean;
  protected
    procedure HookControl;
    procedure UnHookControl;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Files: TStrings read GetFiles;
    property TargetStrings: TStrings read FTargetStrings write FTargetStrings;
  published
    property AcceptDrag: Boolean read FAcceptDrag write SetAcceptDrag default True;
    property DropTarget: TWinControl read FDropTarget write SetDropTarget;
    property OnDrop: TBCDropEvent read FOnDrop write FOnDrop;
  end;

function CF_FILEDESCRIPTOR: UINT;
function CF_FILECONTENTS: UINT;
function Malloc: IMalloc;

implementation

uses
  Winapi.ShlObj, System.SysUtils, Vcl.Forms, BCComponent.WndProcHook;

var
  GlobalCF_FILEDESCRIPTOR: UINT = $FFFFFFF;
  GlobalCF_FILECONTENTS: UINT = $FFFFFFF;
  GlobalMalloc: IMalloc = nil;

function CF_FILEDESCRIPTOR: UINT;
begin
  if GlobalCF_FILEDESCRIPTOR = $FFFFFFF then
    GlobalCF_FILEDESCRIPTOR := RegisterClipboardFormat(CFSTR_FILEDESCRIPTOR);
  Result := GlobalCF_FILEDESCRIPTOR;
end;

function CF_FILECONTENTS: UINT;
begin
  if GlobalCF_FILECONTENTS = $FFFFFFF then
    GlobalCF_FILECONTENTS := RegisterClipboardFormat(CFSTR_FILECONTENTS);
  Result := GlobalCF_FILECONTENTS;
end;

function Malloc: IMalloc;
begin
  if not Assigned(GlobalMalloc) then
    ShGetMalloc(GlobalMalloc);
  Result := GlobalMalloc;
end;

{ TBCDragDrop }

constructor TBCDragDrop.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FAcceptDrag := False;
  FStreamedAcceptDrag := True;
  FFiles := TStringList.Create;
  FIsHooked := False;
  if (Owner is TWinControl) and (csDesigning in ComponentState) then
    FDropTarget := TWinControl(Owner);
end;

destructor TBCDragDrop.Destroy;
begin
  UnHookControl;
  FFiles.Free;

  inherited Destroy;
end;

procedure TBCDragDrop.Loaded;
begin
  inherited Loaded;

  FAcceptDrag := False;
  SetAcceptDrag(FStreamedAcceptDrag);
end;

procedure TBCDragDrop.DropFiles(Handle: HDROP);
var
  Buffer: PChar;
  I, BufferLength, NeededLength: Integer;
  LMousePoint: TPoint;
  Count: Integer;
begin
  FFiles.Clear;

  BufferLength := MAX_PATH;

  GetMem(Buffer, BufferLength * SizeOf(Char));
  try
    Count := DragQueryFile(Handle, $FFFFFFFF, nil, 0);

    for I := 0 to Count-1 do
    begin
      NeededLength := DragQueryFile(Handle, I, nil, 0) + 1;
      if NeededLength > BufferLength then
      begin
        BufferLength := NeededLength;
        ReallocMem(Buffer, BufferLength * SizeOf(Char));
      end;
      DragQueryFile(Handle, I, Buffer, BufferLength);
      FFiles.Add(Buffer);
    end;
  finally
    FreeMem(Buffer);
  end;

  if Assigned(FTargetStrings) then
    FTargetStrings.Assign(FFiles);

  if Assigned(FOnDrop) then
  begin
    DragQueryPoint(Handle, LMousePoint);
    FOnDrop(Self, LMousePoint, FFiles);
  end;

  DragFinish(Handle);
end;

procedure TBCDragDrop.HookControl;
begin
  if not FIsHooked then
    if Assigned(FDropTarget) and not (csDesigning in ComponentState) then
      FIsHooked := RegisterWndProcHook(FDropTarget, WndProc, hoBeforeMsg);
end;

procedure TBCDragDrop.UnHookControl;
begin
  if FIsHooked then
  begin
    FIsHooked := False;
    if Assigned(FDropTarget) and not (csDesigning in ComponentState) then
      UnRegisterWndProcHook(FDropTarget, WndProc, hoBeforeMsg);
  end;
end;

procedure TBCDragDrop.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if (AComponent = FDropTarget) and (Operation = opRemove) then
    DropTarget := nil;
end;

procedure TBCDragDrop.SetAcceptDrag(Value: Boolean);
begin
  if csLoading in ComponentState then
    { When loading, delay changing to active until all properties are loaded }
    FStreamedAcceptDrag := Value
  else
  if Value <> FAcceptDrag then
  begin
    FAcceptDrag := Value;

    if Assigned(FDropTarget) and not (csDesigning in ComponentState) then
    begin
      { If the component is being destroyed, we don't want to call its Handle
        property, which will implicitly re-create its already destroyed handle }
      if not (csDestroying in FDropTarget.ComponentState) then
        DragAcceptFiles(FDropTarget.Handle, FAcceptDrag);

      if FAcceptDrag then
        HookControl
      else
        UnHookControl;
    end;
  end;
end;

function TBCDragDrop.GetFiles: TStrings;
begin
  Result := FFiles;
end;

function ReplaceComponentReference(This, NewReference: TComponent; var VarReference: TComponent): Boolean;
begin
  Result := (VarReference <> NewReference) and Assigned(This);
  if Result then
  begin
    if Assigned(VarReference) then
      VarReference.RemoveFreeNotification(This);
    VarReference := NewReference;
    if Assigned(VarReference) then
      VarReference.FreeNotification(This);
  end;
end;

procedure TBCDragDrop.SetDropTarget(const Value: TWinControl);
var
  WasActive: Boolean;
begin
  if csLoading in ComponentState then
    FDropTarget := Value
  else
  if Value <> FDropTarget then
  begin
    WasActive := AcceptDrag;

    AcceptDrag := False;

    ReplaceComponentReference(Self, Value, TComponent(FDropTarget));

    if WasActive then
      AcceptDrag := True;
  end;
end;

function TBCDragDrop.WndProc(var Msg: TMessage): Boolean;
begin
  Result := Msg.Msg = WM_DROPFILES;
  if Result then
    DropFiles(HDROP(Msg.WParam));
end;

initialization
  OleInitialize(nil);

finalization
  OleUninitialize;

end.

