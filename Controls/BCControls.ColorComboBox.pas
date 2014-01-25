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
    procedure CNDrawItem(var Msg: TWMDrawItem); message CN_DRAWITEM;
    procedure DrawItem(Index: Integer; R: TRect; State: TOwnerDrawState); override;
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

procedure TBCColorComboBox.CNDrawItem(var Msg: TWMDrawItem);
const
  ColorStates: array[Boolean] of TStyleColor = (scComboBoxDisabled, scEdit); // scComboBox);
  FontColorStates: array[Boolean] of TStyleFont = (sfComboBoxItemDisabled, sfComboBoxItemNormal);
var
  LStyles: TCustomStyleServices;
  State: TOwnerDrawState;
begin
  LStyles  := StyleServices;
  with Msg.DrawItemStruct^ do
  begin
    State := ItemStateToOwnerDrawState(itemState);
    Canvas.Handle := hDC;
    Canvas.Font := Font;
    Canvas.Brush := Brush;
    if (Integer(itemID) >= 0) and (odSelected in State) then
    begin
      Canvas.Brush.Color := HiliteColor;
      Canvas.Font.Color := HiliteText;
      if LStyles.Enabled then
      begin
        Canvas.Brush.Color := LStyles.GetStyleColor(ColorStates[Enabled]);
        Canvas.Font.Color  := LStyles.GetStyleFontColor(FontColorStates[Enabled]);

        if odSelected in State then
        begin
          Canvas.Brush.Color := LStyles.GetSystemColor(clHighlight);
          Canvas.Font.Color  := LStyles.GetSystemColor(clHighlightText);
        end;
      end;
    end;
    if Integer(itemID) >= 0 then
      DrawItem(itemID, rcItem, State)
    else
      Canvas.FillRect(rcItem);
    Canvas.Handle := 0;
  end;
end;

procedure TBCColorComboBox.DrawItem(Index: Integer; R: TRect;
  State: TOwnerDrawState);
const
  ColorStates: array[Boolean] of TStyleColor = (scComboBoxDisabled, scEdit); // scComboBox);
  FontColorStates: array[Boolean] of TStyleFont = (sfComboBoxItemDisabled, sfComboBoxItemNormal);
var
  LStyles: TCustomStyleServices;
  LRect: TRect;
  AColor: TColor;
  S: string;
begin
  if Index >= Items.Count then
    Exit;
  LStyles  := StyleServices;
  LRect := R;
  Inc(LRect.Top, 2);
  Inc(LRect.Left, 2);
  Dec(LRect.Bottom, 2);
  if (coText in Options) or (coHex in Options) or (coRGB in Options) or
    ((coCustomColors in Options) and (Index = Items.Count - 1)) then
    LRect.Right := LRect.Left + ColorWidth
  else
    Dec(LRect.Right, 3);

  with Canvas do
  begin
    AColor := Brush.Color;
    Brush.Color := Color;

    if LStyles.Enabled then
    begin
      Canvas.Brush.Color := LStyles.GetStyleColor(ColorStates[Enabled]);
      Canvas.Font.Color  := LStyles.GetStyleFontColor(FontColorStates[Enabled]);

      if odSelected in State then
      begin
        Canvas.Brush.Color := LStyles.GetSystemColor(clHighlight);
        Canvas.Font.Color  := LStyles.GetSystemColor(clHighlightText);
      end;
    end;

    FillRect(R);
    //Brush.Color := clGray;
    //OffsetRect(LRect, 2, 2);
    //FillRect(LRect);
    //OffsetRect(LRect, -2, -2);
    Brush.Color := TColor(Items.Objects[Index]);
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

      FillRect(R);
      R.Left := R.Left + 2;
      R.Right := R.Left + TextWidth(S) + 2;
      Brush.Color := AColor;
      if AColor = clNone then
        Brush.Style := bsFDiagonal
      else
      if AColor = clDefault then
        Brush.Style := bsBDiagonal;

      FillRect(R);
      SetBkMode(Canvas.Handle, TRANSPARENT);
      DrawText(Canvas.Handle, PChar(S), Length(S), R, DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX);
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
      R.Left := R.Left + ColorWidth + 6;
      R.Right := R.Left + TextWidth(S) + 6;
      if AColor = clNone then
        Brush.Style := bsFDiagonal
      else
      if AColor = clDefault then
        Brush.Style := bsBDiagonal;
      FillRect(R);
      OffsetRect(R, 2, 0);
      SetBkMode(Canvas.Handle, TRANSPARENT);
      DrawText(Canvas.Handle, PChar(S), Length(S), R, DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX);
      OffsetRect(R, -2, 0);
    end
    else
      FrameRect(R);
    //if odSelected in State then
    //  DrawFocusRect(R);
  end;
end;

end.
