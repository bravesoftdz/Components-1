unit BCControls.BCStringGrid;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Grids, System.Types, JvStringGrid;

type
  TBCStringGrid = class(TJvStringGrid)
  private
    FBooleanCols: TStrings;
    FInMouseClick: Boolean;
    procedure SetLines(Lines: TStrings);
    function InBooleanCols(ACol: Integer): Boolean;
  protected
    { Protected declarations }
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
  public
    { Public declarations }
    procedure Click; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property BooleanCols: TStrings read FBooleanCols write SetLines;
  end;

procedure Register;

implementation

uses
  Winapi.Windows, Vcl.Themes, Winapi.UxTheme, Vcl.Graphics, System.Math, Vcl.GraphUtil;

const
  CELL_PADDING = 4;

type
  PIntArray = ^TIntArray;
  TIntArray = array[0..MaxCustomExtents] of Integer;

procedure Register;
begin
  RegisterComponents('bonecode', [TBCStringGrid]);
end;

constructor TBCStringGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBooleanCols := TStringList.Create;
  DefaultRowHeight := 18;
  FixedCols := 0;
  RowCount := 2;
end;

procedure TBCStringGrid.SetLines(Lines: TStrings);
begin
  FBooleanCols.Assign(Lines);
end;

destructor TBCStringGrid.Destroy;
begin
  FBooleanCols.Free;
  FBooleanCols := nil;
  inherited Destroy;
end;

function TBCStringGrid.InBooleanCols(ACol: Integer): Boolean;
begin
  Result := FBooleanCols.IndexOf(IntToStr(ACol)) <> -1;
end;

procedure TBCStringGrid.Click;
var
  where: TPoint;
  Rect, btnRect: TRect;
  s: TSize;
begin
  if not FInMouseClick then
  begin
    FInMouseClick := True;
    try
      if InBooleanCols(Col) then
      begin
        if Row > 0 then
        begin
          s.cx := GetSystemMetrics(SM_CXMENUCHECK);
          s.cy := GetSystemMetrics(SM_CYMENUCHECK);
          Rect := CellRect(Col, Row);
          btnRect.Top := Rect.Top + (Rect.Bottom - Rect.Top - s.cy) div 2;
          btnRect.Bottom := btnRect.Top + s.cy;
          btnRect.Left := Rect.Left + CELL_PADDING;
          btnRect.Right := btnRect.Left + s.cx;

          InflateRect(btnrect, 2, 2);  //Allow 2px 'error-range'...

          //Check if clicked inside buttonrect:
          //Get clicked coordinates and cell:
          where := Mouse.CursorPos;
          where := ScreenToClient(where);
          if PtInRect(btnRect, where) then
          begin
            if Cells[Col, Row] = 'True' then
              Cells[Col, Row] := 'False'
            else
              Cells[Col, Row] := 'True'
          end;
        end;
      end
      else
        inherited;
    finally
      FInMouseClick := False;
    end;
  end;
end;

procedure TBCStringGrid.DrawCell(ACol, ARow: Longint; ARect: TRect;
  AState: TGridDrawState);
var
  h: HTHEME;
  s: TSize;
  r, header, LRect: TRect;
  LStyles: TCustomStyleServices;
  LColor: TColor;
  LDetails: TThemedElementDetails;
  InCBCols: Boolean;

  function Checked(ACol, ARow: Integer): Boolean;
  begin
    if Cells[ACol, ARow] = 'True' then
      Result := True
    else
      Result := False
  end;
begin
  InCBCols := InBooleanCols(ACol);
  LStyles := StyleServices;
  if LStyles.Enabled then
    Color := LStyles.GetStyleColor(scEdit);
  if (ARow < FixedRows) then
  begin
    if not LStyles.GetElementColor(LStyles.GetElementDetails(thHeaderItemNormal), ecTextColor, LColor) or (LColor = clNone) then
      LColor := LStyles.GetSystemColor(clWindowText)
    else
      LColor := clWindowText;
    header := ARect;
    if Assigned(TStyleManager.ActiveStyle) then
      if TStyleManager.ActiveStyle.Name <> 'Windows' then
        Dec(header.Left, 1);
    Inc(header.Right, 1);
    Inc(header.Bottom, 1);
    Canvas.Brush.Color := LStyles.GetSystemColor(FixedColor);
    Canvas.Font.Color := LColor;
    Canvas.FillRect(header);
    Canvas.Brush.Style := bsClear;

    if UseThemes then
    begin
      LStyles.DrawElement(Canvas.Handle, StyleServices.GetElementDetails(thHeaderItemNormal), header);

      LDetails := LStyles.GetElementDetails(thHeaderItemNormal);

      Inc(header.Left, 4);
      Dec(header.Right, 1);
      Dec(header.Bottom, 1);
      if not InCBCols then
        LStyles.DrawText(Canvas.Handle,
          LDetails, Cells[ACol, ARow], header,
          [tfSingleLine, tfVerticalCenter])
      else
        LStyles.DrawText(Canvas.Handle,
          LDetails, Cells[ACol, ARow], header,
          [tfCenter, tfSingleLine, tfVerticalCenter]);
    end;
  end;

  if (ARow >= FixedRows) and not IsHidden(ACol, ARow) then
  begin
    if not LStyles.GetElementColor(LStyles.GetElementDetails(tgCellNormal), ecTextColor, LColor) or  (LColor = clNone) then
      LColor := LStyles.GetSystemColor(clWindowText)
    else
      LColor := clWindowText;
    //get and set the background color
    if LStyles.Enabled then
      Canvas.Brush.Color := LStyles.GetStyleColor(scListView);
    Canvas.Font.Color := LColor;

    if UseThemes and (gdSelected in AState) then
    begin
      Canvas.Brush.Color := LStyles.GetSystemColor(clHighlight);
      Canvas.Font.Color := LStyles.GetSystemColor(clHighlightText);
    end
    else
    if not UseThemes and (gdSelected in AState) then
    begin
      Canvas.Brush.Color := clHighlight;
      Canvas.Font.Color := clHighlightText;
    end;
    Canvas.FillRect(ARect);
    Canvas.Brush.Style := bsClear;
    // draw selected
    if UseThemes and (gdSelected in AState) then
    begin
      LRect := ARect;
      Dec(LRect.Left, 1);
      Inc(LRect.Right, 1);
      LDetails := LStyles.GetElementDetails(tgCellSelected);
      LStyles.DrawElement(Canvas.Handle, LDetails, LRect);
    end;
    s.cx := GetSystemMetrics(SM_CXMENUCHECK);
    s.cy := GetSystemMetrics(SM_CYMENUCHECK);
    if InCBCols and UseThemes then
    begin
      h := OpenThemeData(Handle, 'BUTTON');
      if h <> 0 then
        try
          GetThemePartSize(h,
            Canvas.Handle,
            BP_CHECKBOX,
            CBS_CHECKEDNORMAL,
            nil,
            TS_DRAW,
            s);
          r.Top := ARect.Top + (ARect.Bottom - ARect.Top - s.cy) div 2;
          r.Bottom := r.Top + s.cy;
          r.Left := ARect.Left + CELL_PADDING;
          r.Right := r.Left + s.cx;

          if Checked(ACol, ARow) then
            LDetails := LStyles.GetElementDetails(tbCheckBoxcheckedNormal)
          else
            LDetails := LStyles.GetElementDetails(tbCheckBoxUncheckedNormal);

          LStyles.DrawElement(Canvas.Handle, LDetails, r);
        finally
          CloseThemeData(h);
        end;
    end
    else
    if InCBCols then
    begin
      r.Top := ARect.Top + (ARect.Bottom - ARect.Top - s.cy) div 2;
      r.Bottom := r.Top + s.cy;
      r.Left := ARect.Left + CELL_PADDING;
      r.Right := r.Left + s.cx;
      DrawFrameControl(Canvas.Handle,
        r,
        DFC_BUTTON,
        IfThen(Checked(ACol, ARow), DFCS_CHECKED, DFCS_BUTTONCHECK));
    end;

    LRect := ARect;
    Inc(LRect.Left, 4);
    if (gdSelected in AState) then
      LDetails := LStyles.GetElementDetails(tgCellSelected)
    else
      LDetails := LStyles.GetElementDetails(tgCellNormal);

    if not LStyles.GetElementColor(LDetails, ecTextColor, LColor) or (LColor = clNone) then
      LColor := LStyles.GetSystemColor(clWindowText)
    else
      LColor := clWindowText;

    Canvas.Font.Color := LColor;

    if InCBCols then
    begin
      Inc(LRect.Left, 20);
      LStyles.DrawText(Canvas.Handle,
        LDetails,
        Cells[ACol, ARow],
        LRect,
        [tfSingleLine, tfVerticalCenter, tfEndEllipsis])
    end
    else
      LStyles.DrawText(Canvas.Handle,
        LDetails,
        Cells[ACol, ARow],
        LRect,
        [tfSingleLine, tfVerticalCenter]);
  end;

  if Assigned(OnDrawCell) then
    inherited DrawCell(ACol, ARow, ARect, AState)
end;

end.

