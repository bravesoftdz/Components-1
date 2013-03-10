unit BCPageControl;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.ComCtrls, JvExComCtrls, JvComCtrls, Winapi.Messages,
  JvCtrls, System.Types, Vcl.Graphics;

type
  TTabControlStyleHookBtnClose = class(TTabControlStyleHook)
  private
    FHotIndex: Integer;
    FWidthModified: Boolean;
    procedure WMMouseMove(var Message: TMessage); message WM_MOUSEMOVE;
    procedure WMLButtonUp(var Message: TWMMouse); message WM_LBUTTONUP;
    function GetButtonCloseRect(Index: Integer): TRect;
  strict protected
    procedure DrawTab(Canvas: TCanvas; Index: Integer); override;
    procedure MouseEnter; override;
    procedure MouseLeave; override;
  public
    constructor Create(AControl: TWinControl); override;
  end;

  TBCPageControl = class(TJvPageControl)
  private
    { Private declarations }
    FTabDragDrop: Boolean;
    FShowCloseButton: Boolean;
    FHoldShiftToDragDrop: Boolean;
    function PageIndexFromTabIndex(TabIndex: Integer): Integer;
    procedure SetShowCloseButton(Value: Boolean);
  protected
    { Protected declarations }
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); override;
  public
    { Public declarations }
    {$if CompilerVersion >= 23 }
    class constructor Create;
    {$ifend}
    constructor Create(AOwner: TComponent); override;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
  published
    { Published declarations }
    property TabDragDrop: Boolean read FTabDragDrop write FTabDragDrop;
    property HoldShiftToDragDrop: Boolean read FHoldShiftToDragDrop write FHoldShiftToDragDrop;
    property ShowCloseButton: Boolean read FShowCloseButton write SetShowCloseButton;
  end;

procedure Register;

implementation

uses
  Winapi.Windows, Winapi.CommCtrl, Vcl.Themes;

const
  SPACE_FOR_TAB_CLOSE_BUTTON = '      ';

procedure Register;
begin
  RegisterComponents('bonecode', [TBCPageControl]);
end;

{ TTabControlStyleHookBtnClose }

constructor TTabControlStyleHookBtnClose.Create(AControl: TWinControl);
begin
  inherited;
  FHotIndex := -1;
  FWidthModified := False;
end;

procedure TTabControlStyleHookBtnClose.DrawTab(Canvas: TCanvas; Index: Integer);
var
  Details: TThemedElementDetails;
  ButtonR: TRect;
  FButtonState: TThemedWindow;
begin
  inherited;

  if Control is TBCPageControl then
    if not TBCPageControl(Control).ShowCloseButton then
      Exit;

  if (FHotIndex >= 0) and (Index = FHotIndex) then
    FButtonState := twSmallCloseButtonHot
  else
  if Index = TabIndex then
    FButtonState := twSmallCloseButtonNormal
  else
    FButtonState := twSmallCloseButtonDisabled;

  Details := StyleServices.GetElementDetails(FButtonState);

  ButtonR := GetButtonCloseRect(Index);
  if ButtonR.Bottom - ButtonR.Top > 0 then
    StyleServices.DrawElement(Canvas.Handle, Details, ButtonR);
end;

procedure TTabControlStyleHookBtnClose.WMLButtonUp(var Message: TWMMouse);
var
  LPoint: TPoint;
  LIndex: Integer;
begin
  if Control is TBCPageControl then
    if not TBCPageControl(Control).ShowCloseButton then
      Exit;

  LPoint := Message.Pos;
  for LIndex := 0 to TabCount-1 do
  if PtInRect(GetButtonCloseRect(LIndex), LPoint) then
  begin
    if Control is TBCPageControl then
    begin
      TBCPageControl(Control).Pages[LIndex].Parent := nil;
      TBCPageControl(Control).Pages[LIndex].Free;
      TBCPageControl(Control).Repaint;
    end;
    Break;
  end;
end;

procedure TTabControlStyleHookBtnClose.WMMouseMove(var Message: TMessage);
var
  LPoint: TPoint;
  LIndex: Integer;
  LHotIndex: Integer;
begin
  inherited;
  if Control is TBCPageControl then
    if not TBCPageControl(Control).ShowCloseButton then
      Exit;

  LHotIndex := -1;
  LPoint := TWMMouseMove(Message).Pos;
  for LIndex := 0 to TabCount-1 do
  if PtInRect(GetButtonCloseRect(LIndex), LPoint) then
  begin
    LHotIndex := LIndex;
    Break;
  end;

  if FHotIndex <> LHotIndex then
  begin
    FHotIndex := LHotIndex;
    Invalidate;
  end;
end;

function TTabControlStyleHookBtnClose.GetButtonCloseRect(Index: Integer): TRect;
var
  FButtonState: TThemedWindow;
  Details: TThemedElementDetails;
  R, ButtonR: TRect;
begin
  R := TabRect[Index];
  if R.Left < 0 then
    Exit;

  if TabPosition in [tpTop, tpBottom] then
  begin
    if Index = TabIndex then
      InflateRect(R, 0, 2);
  end
  else
  if Index = TabIndex then
    Dec(R.Left, 2)
  else
    Dec(R.Right, 2);

  Result := R;
  FButtonState := twSmallCloseButtonNormal;

  Details := StyleServices.GetElementDetails(FButtonState);
  if not StyleServices.GetElementContentRect(0, Details, Result, ButtonR) then
    ButtonR := Rect(0, 0, 0, 0);

  Result.Left := Result.Right - (ButtonR.Width) - 5;
  Result.Width := ButtonR.Width;
end;

procedure TTabControlStyleHookBtnClose.MouseEnter;
begin
  inherited;
  FHotIndex := -1;
end;

procedure TTabControlStyleHookBtnClose.MouseLeave;
begin
  inherited;
  if FHotIndex >= 0 then
  begin
    FHotIndex := -1;
    Invalidate;
  end;
end;

{ TBCPageControl }

{$if CompilerVersion >= 23 }
class constructor TBCPageControl.Create;
begin
  //TStyleManager.Engine.RegisterStyleHook(TCustomTabControl, TTabControlStyleHookBtnClose);
end;
{$ifend}

constructor TBCPageControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTabDragDrop := False;
  FShowCloseButton := False;
  FHoldShiftToDragDrop := False;
end;

procedure TBCPageControl.SetShowCloseButton(Value: Boolean);
var
  i: Integer;
begin
  FShowCloseButton := Value;
  { update tab captions }
  for i := 0 to PageCount - 1 do
  begin
    Pages[i].Caption := Trim(Pages[i].Caption);
    if ShowCloseButton and (TStyleManager.ActiveStyle.Name <> 'Windows') then
      Pages[i].Caption := Pages[i].Caption + SPACE_FOR_TAB_CLOSE_BUTTON;
  end;
end;

function TBCPageControl.PageIndexFromTabIndex(TabIndex: Integer): Integer;
var
  I, iVisibleTabs: Integer;
begin
  // Tabs doesn't contain hidden TabSheets so the index
  // needs to be adjusted to account for any hidden pages.

  // Result := TabIndex;   // to follow the original idea, uncomment this line and comment the next one
  Result := -1;
  iVisibleTabs := 0;
  for I := 0 to PageCount-1 do
  begin
    if Pages[I].TabVisible then
    begin
      Inc(iVisibleTabs);
      // if we've found a (TabIndex+1)th visible page, then that's it
      if iVisibleTabs > TabIndex then
      begin
        Result := I;
        Break;
      end;
    end;
  end;
end;

procedure TBCPageControl.DragDrop(Source: TObject; X, Y: Integer);
var
  i, j: Integer;
  TabRect: TRect;
begin
  if FTabDragDrop then
  begin
    for i := 0 to PageCount - 1 do
    begin
      Perform(TCM_GETITEMRECT, i, LParam(@TabRect));
      if PtInRect(TabRect, Point(X, Y)) then
      begin
        j := PageIndexFromTabIndex(i);
        if j <> ActivePage.PageIndex then
          ActivePage.PageIndex := j;
        Exit;
      end;
    end;
  end
  else
    inherited DragDrop(Source, X, Y);
end;

procedure TBCPageControl.DragOver(Source: TObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
begin
  if FTabDragDrop then
  begin
    Accept := FTabDragDrop;
    if Accept then
      DragDrop(Source, X, Y);
  end
  else
    inherited DragOver(Source, X, Y, State, Accept);
end;

procedure TBCPageControl.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if FTabDragDrop then
  begin
    if (Button = mbLeft) and ((FHoldShiftToDragDrop and (ssShift in Shift)) or not FHoldShiftToDragDrop) then
      BeginDrag(False)
  end
  else
    inherited MouseDown(Button, Shift, X, Y);
end;

end.

