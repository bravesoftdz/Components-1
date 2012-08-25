unit BCStringGrid;

interface

uses
  SysUtils, Classes, Controls, Grids, Types, JvStringGrid;

type
  TBCStringGrid = class(TJvStringGrid)
  private
    FBooleanCols: TStrings;
    FInMouseClick: Boolean;
    procedure SetLines(Lines: TStrings);
    function InBooleanCols(ACol: Integer): Boolean;
  protected
    { Protected declarations }
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect;
      AState: TGridDrawState); override;
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
  Windows, Themes, UxTheme, Graphics, Math, Vcl.GraphUtil;

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
  ACol, ARow: integer;
  Rect, btnRect: TRect;
  s: TSize;
begin
  //Again, check to avoid recursion:
  if not FInMouseClick then
  begin
    FInMouseClick := True;
    try
      if InBooleanCols(ACol) then
      begin
        //Get clicked coordinates and cell:
        where := Mouse.CursorPos;
        where := ScreenToClient(where);
        MouseToCell(where.x, where.y, ACol, ARow);
        if ARow > 0 then
        begin
          //Get buttonrect for clicked cell:
          //btnRect := GetBtnRect(ACol, ARow, false);
          s.cx := GetSystemMetrics(SM_CXMENUCHECK);
          s.cy := GetSystemMetrics(SM_CYMENUCHECK);
          Rect := CellRect(ACol, ARow);
          btnRect.Top := Rect.Top + (Rect.Bottom - Rect.Top - s.cy) div 2;
          btnRect.Bottom := btnRect.Top + s.cy;
          btnRect.Left := Rect.Left + CELL_PADDING;
          btnRect.Right := btnRect.Left + s.cx;

          InflateRect(btnrect, 2, 2);  //Allow 2px 'error-range'...

          //Check if clicked inside buttonrect:
          if PtInRect(btnRect, where) then
          begin
            if Cells[ACol, ARow] = 'True' then
              Cells[ACol, ARow] := 'False'
            else
              Cells[ACol, ARow] := 'True'
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
      LColor := LStyles.GetSystemColor(clWindowText);
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
      LColor := LStyles.GetSystemColor(clWindowText);
    //get and set the background color
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
      LColor := LStyles.GetSystemColor(clWindowText);

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
(*
var
  h: HTHEME;
  s: TSize;
  r, header, LRect: TRect;
  InCBCols: Boolean;

  function Checked: Boolean;
  begin
    if Cells[ACol, ARow] = 'True' then
      Result := True
    else
      Result := False
  end;
begin
  inherited;
  InCBCols := InBooleanCols(ACol);
  if InCBCols and (ARow = 0) then
  begin  // ACol is zero based
     Canvas.Brush.Color := FixedColor;
     Canvas.FillRect(ARect);
     Canvas.Brush.Style := bsClear;

    if UseThemes then
    begin
      header := ARect;
      header.Right := header.Right + 1;
      header.Bottom := header.Bottom + 2;

      StyleServices.DrawElement(Canvas.Handle, StyleServices.GetElementDetails(thHeaderItemNormal), header);
    end;

    DrawText(Canvas.Handle,
      Cells[ACol, ARow],
      Length(Cells[ACol, ARow]),
      ARect,
      DT_SINGLELINE or DT_VCENTER or DT_CENTER);
  end;

  if InCBCols and (ARow >= 1) then
  begin
    if not UseThemes and (gdSelected in AState) then
    begin
       Canvas.Brush.Color := clHighlight;
       Canvas.Font.Color := clHighlightText;
    end
    else
      Canvas.Brush.Color := Color;
    Canvas.FillRect(ARect);
    Canvas.Brush.Style := bsClear;
    if (gdSelected in AState) then
    begin
      if UseThemes then
      begin
        LRect := ARect;

        if (ACol >= FixedCols + 1) and (ACol < ColCount - 1) then
          InflateRect(LRect, 4, 0)
        else
        if ACol = FixedCols then
          Inc(LRect.Right, 4)
        else
        if ACol = (ColCount - 1) then
          Dec(LRect.Left, 5);

        h := StyleServices.Theme[teMenu];
        DrawThemeBackground(h, Canvas.Handle, MENU_POPUPITEM, MPI_HOT,
          LRect, {$IFNDEF CLR}@{$ENDIF}ARect);
      end;
    end;
    s.cx := GetSystemMetrics(SM_CXMENUCHECK);
    s.cy := GetSystemMetrics(SM_CYMENUCHECK);
    if UseThemes then
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

          DrawThemeBackground(h,
            Canvas.Handle,
            BP_CHECKBOX,
            IfThen(Checked, CBS_CHECKEDNORMAL, CBS_UNCHECKEDNORMAL),
            r,
            nil);
        finally
          CloseThemeData(h);
        end;
    end
    else
    begin
      r.Top := ARect.Top + (ARect.Bottom - ARect.Top - s.cy) div 2;
      r.Bottom := r.Top + s.cy;
      r.Left := ARect.Left + CELL_PADDING;
      r.Right := r.Left + s.cx;
      DrawFrameControl(Canvas.Handle,
        r,
        DFC_BUTTON,
        IfThen(Checked, DFCS_CHECKED, DFCS_BUTTONCHECK));
    end;

    r := Classes.Rect(r.Right + CELL_PADDING, ARect.Top, ARect.Right, ARect.Bottom);
    DrawText(Canvas.Handle,
      Cells[ACol, ARow],
      length(Cells[ACol, ARow]),
      r,
      DT_SINGLELINE or DT_VCENTER or DT_LEFT or DT_END_ELLIPSIS);
  end;
end;   *)

end.
