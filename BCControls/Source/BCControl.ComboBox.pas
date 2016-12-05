unit BCControl.ComboBox;

interface

uses
  Winapi.Windows, Winapi.Messages, sComboBox, sFontCtrls, System.Classes, System.Types, Vcl.StdCtrls, Vcl.Controls, Vcl.Graphics,
  Vcl.Dialogs, sComboBoxes;

type
  TBCComboBoxMouseWheelEvent = procedure(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint) of object;

  TBCComboBox = class(TsCombobox)
  private
    FUseMouseWheel: Boolean;
    FOnMouseWheel: TBCComboBoxMouseWheelEvent;
  protected
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property UseMouseWheel: Boolean read FUseMouseWheel write FUseMouseWheel;
    property OnMouseWheel: TBCComboBoxMouseWheelEvent read FOnMouseWheel write FOnMouseWheel;
  end;

  TBCFontComboBox = class(TsFontCombobox)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TBCColorComboBox = class(TsColorBox)
  private
    function GetText: string;
    procedure SetText(const Value: string);
    procedure GetColorName(Sender: TsCustomColorBox; Value: TColor; var ColorName: string);
  public
    constructor Create(AOwner: TComponent); override;
  published
    property ColorText: string read GetText write SetText;
  end;

implementation

uses
  sConst, Vcl.Consts;

{ TBCComboBox }

constructor TBCComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BoundLabel.Indent := 4;
  BoundLabel.Layout := sclTopLeft;
end;

function TBCComboBox.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
  if Assigned(FOnMouseWheel) then
    FOnMouseWheel(Self, Shift, WheelDelta, MousePos);

  if FUseMouseWheel then
    Result := inherited
  else
    Result := True;
end;

{ TBCFontComboBox }

constructor TBCFontComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BoundLabel.Indent := 4;
  BoundLabel.Layout := sclTopLeft;
end;

{ TBCColorComboBox }

constructor TBCColorComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  ColorRectWidth := 14;
  OnColorName := GetColorName;
end;

procedure TBCColorComboBox.GetColorName(Sender: TsCustomColorBox; Value: TColor; var ColorName: string);
begin
  case Value of
    clBlack: ColorName := SNameBlack;
    clMaroon: ColorName := SNameMaroon;
    clGreen: ColorName := SNameGreen;
    clOlive: ColorName := SNameOlive;
    clNavy: ColorName := SNameNavy;
    clPurple: ColorName := SNamePurple;
    clTeal: ColorName := SNameTeal;
    clGray: ColorName := SNameGray;
    clSilver: ColorName := SNameSilver;
    clRed: ColorName := SNameRed;
    clLime: ColorName := SNameLime;
    clYellow: ColorName := SNameYellow;
    clBlue: ColorName := SNameBlue;
    clFuchsia: ColorName := SNameFuchsia;
    clAqua: ColorName := SNameAqua;
    clWhite: ColorName := SNameWhite;
    clMoneyGreen: ColorName := SNameMoneyGreen;
    clSkyBlue: ColorName := SNameSkyBlue;
    clCream: ColorName := SNameCream;
    clMedGray: ColorName := SNameMedGray;
    clActiveBorder: ColorName := SNameActiveBorder;
    clActiveCaption: ColorName := SNameActiveCaption;
    clAppWorkSpace: ColorName := SNameAppWorkSpace;
    clBackground: ColorName := SNameBackground;
    clBtnFace: ColorName := SNameBtnFace;
    clBtnHighlight: ColorName := SNameBtnHighlight;
    clBtnShadow: ColorName := SNameBtnShadow;
    clBtnText: ColorName := SNameBtnText;
    clCaptionText: ColorName := SNameCaptionText;
    clDefault: ColorName := SNameDefault;
    clGradientActiveCaption: ColorName := SNameGradientActiveCaption;
    clGradientInactiveCaption: ColorName := SNameGradientInactiveCaption;
    clGrayText: ColorName := SNameGrayText;
    clHighlight: ColorName := SNameHighlight;
    clHighlightText: ColorName := SNameHighlightText;
    clHotLight: ColorName := SNameHotLight;
    clInactiveBorder: ColorName := SNameInactiveBorder;
    clInactiveCaption: ColorName := SNameInactiveCaption;
    clInactiveCaptionText: ColorName := SNameInactiveCaptionText;
    clInfoBk: ColorName := SNameInfoBk;
    clInfoText: ColorName := SNameInfoText;
    clMenu: ColorName := SNameMenu;
    clMenuBar: ColorName := SNameMenuBar;
    clMenuHighlight: ColorName := SNameMenuHighlight;
    clMenuText: ColorName := SNameMenuText;
    clNone: ColorName := SNameNone;
    clScrollBar: ColorName := SNameScrollBar;
    cl3DDkShadow: ColorName := SName3DDkShadow;
    cl3DLight: ColorName := SName3DLight;
    clWindow: ColorName := SNameWindow;
    clWindowFrame: ColorName := SNameWindowFrame;
    clWindowText: ColorName := SNameWindowText;
  else
    ColorName := SColorBoxCustomCaption;
  end;
end;

function TBCColorComboBox.GetText: string;
begin
  Result := ColorToString(Selected);
end;

procedure TBCColorComboBox.SetText(const Value: string);
begin
  if Value = '' then
    Exit;
  try
    Selected := StringToColor(Value);
  except
    Selected := clBlack;
  end;
end;

end.
