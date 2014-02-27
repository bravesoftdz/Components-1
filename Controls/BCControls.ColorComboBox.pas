unit BCControls.ColorComboBox;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls, JvExStdCtrls,
  JvCombobox, JvColorCombo;

type
  TBCColorComboBox = class(TJvColorComboBox)
  protected
    { Protected declarations }
    procedure FontChanged; override;
    procedure CNDrawItem(var Message: TWMDrawItem); message CN_DRAWITEM;
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
  end;

procedure Register;

implementation

uses
  System.UITypes, Vcl.Graphics, Vcl.Themes;

procedure Register;
begin
  RegisterComponents('bonecode', [TBCColorComboBox]);
end;

function ItemStateToOwnerDrawState(State: Integer): TOwnerDrawState;
begin
  Result := [];
  if (State and ODS_CHECKED) <> 0 then
    Include(Result, odChecked);
  if (State and ODS_COMBOBOXEDIT) <> 0 then
    Include(Result, odComboBoxEdit);
  if (State and ODS_DEFAULT) <> 0 then
    Include(Result, odDefault);
  if (State and ODS_DISABLED) <> 0 then
    Include(Result, odDisabled);
  if (State and ODS_FOCUS) <> 0 then
    Include(Result, odFocused);
  if (State and ODS_GRAYED) <> 0 then
    Include(Result, odGrayed);
  if (State and ODS_SELECTED) <> 0 then
    Include(Result, odSelected);
end;

function GetItemHeight(Font: TFont): Integer;
var
  DC: HDC;
  SaveFont: HFont;
  Metrics: TTextMetric;
begin
  DC := GetDC(0);
  SaveFont := SelectObject(DC, Font.Handle);
  GetTextMetrics(DC, Metrics);
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);
  Result := Metrics.tmHeight + 3;
end;

procedure TBCColorComboBox.FontChanged;
begin
  ItemHeight := GetItemHeight(Font);
  RecreateWnd;
end;

procedure TBCColorComboBox.DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState);
const
  ColorStates: array[Boolean] of TStyleColor = (scComboBoxDisabled, scEdit); // scComboBox);
  FontColorStates: array[Boolean] of TStyleFont = (sfComboBoxItemDisabled, sfComboBoxItemNormal);
var
  LStyles: TCustomStyleServices;
  LRect: TRect;
  AColor: TColor;
  S: string;
begin
  LStyles  := StyleServices;
  if LStyles.Enabled then
  begin
    Canvas.Brush.Color := LStyles.GetStyleColor(ColorStates[Enabled]);
    Canvas.Font.Color  := LStyles.GetStyleFontColor(FontColorStates[Enabled]);

    if odSelected in State then
    begin
      Canvas.Brush.Color := LStyles.GetSystemColor(clHighlight);
      Canvas.Font.Color  := LStyles.GetSystemColor(clHighlightText);
    end;

    with Canvas do
    begin
      AColor := Brush.Color;

      FillRect(Rect);

      Brush.Color := TColor(Items.Objects[Index]);

      LRect := Rect;
      Inc(LRect.Top, 2);
      Inc(LRect.Left, 2);
      Dec(LRect.Bottom, 2);
      if (coText in Options) or (coHex in Options) or (coRGB in Options) or
        ((coCustomColors in Options) and (Index = Items.Count - 1)) then
        LRect.Right := LRect.Left + ColorWidth
      else
        Dec(LRect.Right, 3);

      try
        Rectangle(LRect);
      finally
        Brush.Style := bsSolid;
        Brush.Color := AColor;
      end;
      if (coCustomColors in Options) and (Index = Items.Count - 1) then
      begin
        S := ColorDialogText;
        DoGetDisplayName(Index, TColor(Items.Objects[Index]), S);
        Brush.Color := Self.Color;
        if LStyles.Enabled then
        begin
          Canvas.Brush.Color := LStyles.GetStyleColor(ColorStates[Enabled]);
          Canvas.Font.Color  := LStyles.GetStyleFontColor(FontColorStates[Enabled]);

          if odSelected in State then
          begin
            Canvas.Brush.Color := LStyles.GetSystemColor(clHighlight);
            Canvas.Font.Color  := LStyles.GetStyleFontColor(sfMenuItemTextSelected); //clHighlightText);
          end;
        end;
        FillRect(Rect);
        Rect.Left := Rect.Left + 2;
        Rect.Right := Rect.Left + TextWidth(S) + 2;
        Brush.Color := AColor;
        if AColor = clNone then
          Brush.Style := bsFDiagonal
        else
        if AColor = clDefault then
          Brush.Style := bsBDiagonal;

        FillRect(Rect);
        SetBkMode(Canvas.Handle, TRANSPARENT);
        DrawText(Canvas.Handle, PChar(S), Length(S), Rect, DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX);
      end
      else
      if (coText in Options) or (coHex in Options) or (coRGB in Options) then
      begin
        S := Items[Index];
        DoGetDisplayName(Index, TColor(Items.Objects[Index]), S);
        if S <> ColorDialogText then
        begin
          if coHex in Options then
            S := Format('0x%.6x', [ColorToRGB(TColor(Items.Objects[Index]))])
          else
          if coRGB in Options then
            S := Format('(%d,%d,%d)', [GetRValue(TColor(Items.Objects[Index])),
              GetGValue(TColor(Items.Objects[Index])), GetBValue(TColor(Items.Objects[Index]))]);
        end;
        Rect.Left := Rect.Left + ColorWidth + 6;
        Rect.Right := Rect.Left + TextWidth(S) + 6;
        if AColor = clNone then
          Brush.Style := bsFDiagonal
        else
        if AColor = clDefault then
          Brush.Style := bsBDiagonal;
        FillRect(Rect);
        OffsetRect(Rect, 2, 0);
        //SetBkMode(Canvas.Handle, TRANSPARENT);
        Canvas.FillRect(Rect) ;
        Canvas.TextOut(Rect.Left+2, Rect.Top, Items[Index]);
        //DrawText(Canvas.Handle, PChar(S), Length(S), R, DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX);
        OffsetRect(Rect, -2, 0);
      end
      else
        FrameRect(Rect);

      Canvas.FillRect(Rect) ;
      Canvas.TextOut(Rect.Left+2, Rect.Top, Items[Index]);
    end;
  end;
end;

procedure TBCColorComboBox.CNDrawItem(var Message: TWMDrawItem);
const
  ColorStates: array[Boolean] of TStyleColor = (scComboBoxDisabled, scComboBox);
  FontStates: array[Boolean] of TStyleFont = (sfComboBoxItemDisabled, sfComboBoxItemNormal);
var
  State: TOwnerDrawState;
  LStyles: TCustomStyleServices;
begin
  LStyles := StyleServices;
  with Message.DrawItemStruct{$IFNDEF CLR}^{$ENDIF} do
  begin
    State := TOwnerDrawState(LoWord(itemState));
    if itemState and ODS_COMBOBOXEDIT <> 0 then
      Include(State, odComboBoxEdit);
    if itemState and ODS_DEFAULT <> 0 then
      Include(State, odDefault);
    Canvas.Handle := hDC;
    Canvas.Font := Font;
    if LStyles.Enabled then
    begin
      if seClient in StyleElements then
        Canvas.Brush.Color := StyleServices.GetStyleColor(ColorStates[Enabled])
      else
        Canvas.Brush := Brush;
      if seFont in StyleElements then
        Canvas.Font.Color := StyleServices.GetStyleFontColor(FontStates[Enabled]);
    end
    else
      Canvas.Brush := Brush;
    if (Integer(itemID) >= 0) and (odSelected in State) then
    begin
      if LStyles.Enabled then
      begin
         Canvas.Brush.Color := LStyles.GetSystemColor(clHighlight);
         Canvas.Font.Color := LStyles.GetStyleFontColor(sfMenuItemTextSelected);// GetSystemColor(clHighlightText);
      end
      else
      begin
        Canvas.Brush.Color := clHighlight;
        Canvas.Font.Color := clHighlightText;
      end;
    end;
    if Integer(itemID) >= 0 then
      DrawItem(itemID, rcItem, State)
    else
      Canvas.FillRect(rcItem);
    //if odFocused in State then DrawFocusRect(hDC, rcItem);
    Canvas.Handle := 0;
  end;
end;

end.
