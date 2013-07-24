unit BCControls.PageControl;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.ComCtrls, Winapi.Messages, System.Types, Vcl.Graphics;

type
  TTabControlStyleHookBtnClose = class(TTabControlStyleHook)
  private
    FHotIndex: Integer;
    FWidthModified: Boolean;
    procedure WMMouseMove(var Message: TMessage); message WM_MOUSEMOVE;
    procedure WMLButtonDown(var Message: TWMMouse); message WM_LBUTTONDOWN;
    function GetButtonCloseRect(Index: Integer): TRect;
    function GetImageIndex(TabIndex: Integer): Integer;
    procedure AngleTextOut(Canvas: TCanvas; Angle, X, Y: Integer; const Text: string);
  strict protected
    procedure DrawTab(Canvas: TCanvas; Index: Integer); override;
    procedure MouseEnter; override;
    procedure MouseLeave; override;
  public
    constructor Create(AControl: TWinControl); override;
  end;

  TBCPageControl = class(TPageControl)
  private
    { Private declarations }
    FTabDragDrop: Boolean;
    FShowCloseButton: Boolean;
    FHoldShiftToDragDrop: Boolean;
    FOnCloseButtonClick: TNotifyEvent;
    function PageIndexFromTabIndex(TabIndex: Integer): Integer;
    function GetActivePageCaption: TCaption;
    procedure SetActivePageCaption(Value: TCaption);
    procedure SetShowCloseButton(Value: Boolean);
    procedure UpdateTabCaptions(OnlyActivePage: Boolean = False);
  protected
    { Protected declarations }
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); override;
  public
    { Public declarations }
    {$if CompilerVersion >= 23 }
    class constructor Create;
    {$endif}
    constructor Create(AOwner: TComponent); override;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
    procedure Invalidate; override;
    procedure UpdatePageCaption(Page: TTabSheet);
  published
    { Published declarations }
    property ActivePageCaption: TCaption read GetActivePageCaption write SetActivePageCaption;
    property TabDragDrop: Boolean read FTabDragDrop write FTabDragDrop;
    property HoldShiftToDragDrop: Boolean read FHoldShiftToDragDrop write FHoldShiftToDragDrop;
    property ShowCloseButton: Boolean read FShowCloseButton write SetShowCloseButton;
    property OnCloseButtonClick: TNotifyEvent read FOnCloseButtonClick write FOnCloseButtonClick;
    property OnDblClick;
  end;

procedure Register;

implementation

uses
  Winapi.Windows, Winapi.CommCtrl, Vcl.Themes;

const
  SPACE_FOR_TAB_CLOSE_BUTTON = '      ';
  SPACE_FOR_TAB_CLOSE_BUTTON_CARBON = '         ';

type
  THackCustomTabControl = class(TCustomTabControl);

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

procedure TTabControlStyleHookBtnClose.AngleTextOut(Canvas: TCanvas; Angle, X,
  Y: Integer; const Text: string);
var
  NewFontHandle, OldFontHandle: hFont;
  LogRec: TLogFont;
begin
  GetObject(Canvas.Font.Handle, SizeOf(LogRec), Addr(LogRec));
  LogRec.lfEscapement := Angle * 10;
  LogRec.lfOrientation := LogRec.lfEscapement;
  NewFontHandle := CreateFontIndirect(LogRec);
  OldFontHandle := SelectObject(Canvas.Handle, NewFontHandle);
  SetBkMode(Canvas.Handle, TRANSPARENT);
  Canvas.TextOut(X, Y, Text);
  NewFontHandle := SelectObject(Canvas.Handle, OldFontHandle);
  DeleteObject(NewFontHandle);
end;

function TTabControlStyleHookBtnClose.GetImageIndex(TabIndex: Integer): Integer;
begin
  Result:=-1;
  if (Control <> nil) and (Control is TCustomTabControl) then
   Result:=THackCustomTabControl(Control).GetImageIndex(TabIndex);
end;

procedure TTabControlStyleHookBtnClose.DrawTab(Canvas: TCanvas; Index: Integer);
var
  Details: TThemedElementDetails;
  ButtonR: TRect;
  FButtonState: TThemedWindow;

  R, LayoutR, GlyphR: TRect;
  ImageWidth, ImageHeight, ImageStep, TX, TY: Integer;
  DrawState: TThemedTab;
  ThemeTextColor: TColor;
  ImageIndex:Integer;
begin
  ImageIndex := GetImageIndex(Index); //get the real image index

  if (Images <> nil) and (ImageIndex < Images.Count) then
  begin
    ImageWidth := Images.Width;
    ImageHeight := Images.Height;
    ImageStep := 3;
  end
  else
  begin
    ImageWidth := 0;
    ImageHeight := 0;
    ImageStep := 0;
  end;

  R := TabRect[Index];
  if R.Left < 0 then Exit;

  if TabPosition in [tpTop, tpBottom] then
  begin
    if Index = TabIndex then
      InflateRect(R, 0, 2);
  end
  else if Index = TabIndex then
    Dec(R.Left, 2) else Dec(R.Right, 2);

  Canvas.Font.Assign(THackCustomTabControl(Control).Font);//access the original protected font property using a helper hack class
  LayoutR := R;
  DrawState := ttTabDontCare;
  case TabPosition of
    tpTop:
      begin
        if Index = TabIndex then
          DrawState := ttTabItemSelected
        else if (Index = HotTabIndex) and MouseInControl then
          DrawState := ttTabItemHot
        else
          DrawState := ttTabItemNormal;
      end;
    tpLeft:
      begin
        if Index = TabIndex then
          DrawState := ttTabItemLeftEdgeSelected
        else if (Index = HotTabIndex) and MouseInControl then
          DrawState := ttTabItemLeftEdgeHot
        else
          DrawState := ttTabItemLeftEdgeNormal;
      end;
    tpBottom:
      begin
        if Index = TabIndex then
          DrawState := ttTabItemBothEdgeSelected
        else if (Index = HotTabIndex) and MouseInControl then
          DrawState := ttTabItemBothEdgeHot
        else
          DrawState := ttTabItemBothEdgeNormal;
      end;
    tpRight:
      begin
        if Index = TabIndex then
          DrawState := ttTabItemRightEdgeSelected
        else if (Index = HotTabIndex) and MouseInControl then
          DrawState := ttTabItemRightEdgeHot
        else
          DrawState := ttTabItemRightEdgeNormal;
      end;
  end;

  if StyleServices.Available then
  begin
    Details := StyleServices.GetElementDetails(DrawState);
    StyleServices.DrawElement(Canvas.Handle, Details, R);
  end;

  if (Images <> nil) and (ImageIndex < Images.Count) then//check the bounds of the image index to draw
  begin
    GlyphR := LayoutR;
    case TabPosition of
      tpTop, tpBottom:
        begin
          GlyphR.Left := GlyphR.Left + ImageStep;
          GlyphR.Right := GlyphR.Left + ImageWidth;
          LayoutR.Left := GlyphR.Right;
          GlyphR.Top := GlyphR.Top + (GlyphR.Bottom - GlyphR.Top) div 2 - ImageHeight div 2;
          if (TabPosition = tpTop) and (Index = TabIndex) then
            OffsetRect(GlyphR, 0, -1)
          else if (TabPosition = tpBottom) and (Index = TabIndex) then
            OffsetRect(GlyphR, 0, 1);
        end;
      tpLeft:
        begin
          GlyphR.Bottom := GlyphR.Bottom - ImageStep;
          GlyphR.Top := GlyphR.Bottom - ImageHeight;
          LayoutR.Bottom := GlyphR.Top;
          GlyphR.Left := GlyphR.Left + (GlyphR.Right - GlyphR.Left) div 2 - ImageWidth div 2;
        end;
      tpRight:
        begin
          GlyphR.Top := GlyphR.Top + ImageStep;
          GlyphR.Bottom := GlyphR.Top + ImageHeight;
          LayoutR.Top := GlyphR.Bottom;
          GlyphR.Left := GlyphR.Left + (GlyphR.Right - GlyphR.Left) div 2 - ImageWidth div 2;
        end;
    end;
    if StyleServices.Available then
      StyleServices.DrawIcon(Canvas.Handle, Details, GlyphR, Images.Handle, ImageIndex);//Here the Magic is made using the "real" imageindex of the tab
  end;

  if StyleServices.Available then
  begin
    if (TabPosition = tpTop) and (Index = TabIndex) then
      OffsetRect(LayoutR, 0, -1)
    else if (TabPosition = tpBottom) and (Index = TabIndex) then
      OffsetRect(LayoutR, 0, 1);

    if TabPosition = tpLeft then
    begin
      TX := LayoutR.Left + (LayoutR.Right - LayoutR.Left) div 2 -
        Canvas.TextHeight(Tabs[Index]) div 2;
      TY := LayoutR.Top + (LayoutR.Bottom - LayoutR.Top) div 2 +
        Canvas.TextWidth(Tabs[Index]) div 2;
     if StyleServices.GetElementColor(Details, ecTextColor, ThemeTextColor) then
       Canvas.Font.Color := ThemeTextColor;
      AngleTextOut(Canvas, 90, TX, TY, Tabs[Index]);
    end
    else if TabPosition = tpRight then
    begin
      TX := LayoutR.Left + (LayoutR.Right - LayoutR.Left) div 2 +
        Canvas.TextHeight(Tabs[Index]) div 2;
      TY := LayoutR.Top + (LayoutR.Bottom - LayoutR.Top) div 2 -
        Canvas.TextWidth(Tabs[Index]) div 2;
      if StyleServices.GetElementColor(Details, ecTextColor, ThemeTextColor)
      then
        Canvas.Font.Color := ThemeTextColor;
      AngleTextOut(Canvas, -90, TX, TY, Tabs[Index]);
    end
    else
      DrawControlText(Canvas, Details, Tabs[Index], LayoutR, DT_VCENTER or DT_CENTER or DT_SINGLELINE  or DT_NOCLIP);
  end;
  { Close button }
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

procedure TTabControlStyleHookBtnClose.WMLButtonDown(var Message: TWMMouse);
var
  LPoint: TPoint;
  LIndex: Integer;
begin
  if Control is TBCPageControl then
    if not TBCPageControl(Control).ShowCloseButton then
      Exit;
  LPoint := Message.Pos;
  for LIndex := 0 to TabCount - 1 do
  if PtInRect(GetButtonCloseRect(LIndex), LPoint) then
  begin
    TBCPageControl(Control).ActivePageIndex := LIndex;
    if Assigned(TBCPageControl(Control).FOnCloseButtonClick) then
      TBCPageControl(Control).OnCloseButtonClick(Self);
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
  inherited;
  if Assigned(TStyleManager.Engine) then
    TStyleManager.Engine.RegisterStyleHook(TCustomTabControl, TTabControlStyleHookBtnClose);
end;
{$endif}

constructor TBCPageControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTabDragDrop := False;
  FShowCloseButton := False;
  FHoldShiftToDragDrop := False;
  ControlStyle := ControlStyle + [csClickEvents];
end;

procedure TBCPageControl.Invalidate;
begin
  inherited Invalidate;

  UpdateTabCaptions;
end;

function TBCPageControl.GetActivePageCaption: TCaption;
begin
  Result := Trim(ActivePage.Caption);
end;

procedure TBCPageControl.SetActivePageCaption(Value: TCaption);
begin
  ActivePage.Caption := Value;
  UpdateTabCaptions(True);
end;

procedure TBCPageControl.UpdatePageCaption(Page: TTabSheet);
begin
  Page.Caption := Trim(Page.Caption);
  if ShowCloseButton and (TStyleManager.ActiveStyle.Name <> 'Windows') then
  begin
    if TStyleManager.ActiveStyle.Name <> 'Carbon' then
      Page.Caption := Page.Caption + SPACE_FOR_TAB_CLOSE_BUTTON
    else
      Page.Caption := Page.Caption + SPACE_FOR_TAB_CLOSE_BUTTON_CARBON
  end;
end;

procedure TBCPageControl.UpdateTabCaptions(OnlyActivePage: Boolean);
var
  i: Integer;
begin
  if OnlyActivePage then
    UpdatePageCaption(ActivePage)
  else
  for i := 0 to PageCount - 1 do
    UpdatePageCaption(Pages[i]);
end;

procedure TBCPageControl.SetShowCloseButton(Value: Boolean);
begin
  FShowCloseButton := Value;
  Invalidate;
  //UpdateTabCaptions;
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
  end;

  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TBCPageControl.MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
begin
  if FTabDragDrop then
    if Dragging then
      EndDrag(True);

  inherited MouseUp(Button, Shift, X, Y);
end;

end.

