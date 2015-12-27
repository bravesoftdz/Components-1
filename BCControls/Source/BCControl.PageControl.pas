unit BCControl.PageControl;

interface

uses
  Winapi.Messages, System.Classes,  Vcl.Controls, System.UITypes, sPageControl;

type
  TBCPageControl = class(TsPageControl)
  private
    FHoldShiftToDragDrop: Boolean;
    FRightClickSelect: Boolean;
    FTabClosed: Boolean;
    FTabDragDrop: Boolean;
    function PageIndexFromTabIndex(TabIndex: Integer): Integer;
    procedure WMRButtonDown(var Msg: TWMRButtonDown); message WM_RBUTTONDOWN;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
    { Set TabClosed to True, when a tab is closed otherwise drag will begin and the cursor will be prohibited }
    property TabClosed: Boolean read FTabClosed write FTabClosed;
  published
    property HoldShiftToDragDrop: Boolean read FHoldShiftToDragDrop write FHoldShiftToDragDrop;
    property RightClickSelect: Boolean read FRightClickSelect write FRightClickSelect default False;
    property TabDragDrop: Boolean read FTabDragDrop write FTabDragDrop;
  end;

implementation

uses
  Winapi.Windows, Winapi.CommCtrl, System.SysUtils, System.Types;

constructor TBCPageControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTabClosed := False;
  FTabDragDrop := False;
  FHoldShiftToDragDrop := False;
  ControlStyle := ControlStyle + [csClickEvents];
end;

procedure TBCPageControl.WMRButtonDown(var Msg: TWMRButtonDown);
var
  I: Integer;
  R: TRect;
  P: TPoint;
begin
  if RightClickSelect then
  begin
    with Msg do
      P := SmallPointToPoint(SmallPoint(XPos, YPos));
    for I := 0 to PageCount -1 do
    begin
      R := TabRect(I);
      if PtInRect(R, P) then
      begin
        if (ActivePageIndex <> I) and CanChange then
        begin
          ActivePageIndex := I;
          Change;
        end;
        Break;
      end;
    end;
  end;
  inherited;
end;

function TBCPageControl.PageIndexFromTabIndex(TabIndex: Integer): Integer;
var
  i, LVisibleTabs: Integer;
begin
  { Tabs doesn't contain hidden TabSheets so the index needs to be adjusted to account for any hidden pages. }

  // Result := TabIndex;   // to follow the original idea, uncomment this line and comment the next one
  Result := -1;
  LVisibleTabs := 0;
  for i := 0 to PageCount - 1 do
  begin
    if Pages[i].TabVisible then
    begin
      Inc(LVisibleTabs);
      { if we've found a (TabIndex+1)th visible page, then that's it }
      if LVisibleTabs > TabIndex then
      begin
        Result := i;
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
        if (j <> ActivePage.PageIndex) and (TsTabSheet(Pages[j]).TabType = ttTab) then
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
  else { must be else otherwise the cursor will be prohibited }
    inherited DragOver(Source, X, Y, State, Accept);
end;

procedure TBCPageControl.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if not FTabClosed and FTabDragDrop then
    if (Button = TMouseButton.mbLeft) and ((FHoldShiftToDragDrop and (ssShift in Shift)) or not FHoldShiftToDragDrop) then
      BeginDrag(False);
  FTabClosed := False;
  inherited MouseDown(Button, Shift, X, Y);
end;

end.

