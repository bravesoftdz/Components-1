unit BCPageControl;

interface

uses
  SysUtils, Classes, Controls, ComCtrls, JvExComCtrls, JvComCtrls, Messages,
  JvCtrls;

type
  TBCPageControl = class(TJvPageControl)
  private
    { Private declarations }
    FTabDragDrop: Boolean;
    FHoldShiftToDragDrop: Boolean;
    function PageIndexFromTabIndex(TabIndex: Integer): Integer;
  protected
    { Protected declarations }
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
  published
    { Published declarations }
    property TabDragDrop: Boolean read FTabDragDrop write FTabDragDrop;
    property HoldShiftToDragDrop: Boolean read FHoldShiftToDragDrop write FHoldShiftToDragDrop;
  end;

procedure Register;

implementation

uses
  Types, Windows, CommCtrl;

procedure Register;
begin
  RegisterComponents('bonecode', [TBCPageControl]);
end;

constructor TBCPageControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTabDragDrop := False;
  FHoldShiftToDragDrop := False;
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

