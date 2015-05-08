unit BCControls.ColorComboBox;

interface

uses
  sComboBoxes, System.Classes, Vcl.Graphics;

type
  TBCColorComboBox = class(TsColorBox)
  private
    function GetText: string;
    procedure SetText(const Value: string);
    procedure GetColorName(Sender: TsCustomColorBox; Value: TColor; var ColorName: string);
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Text: string read GetText write SetText;
  end;

implementation

uses
  Vcl.Consts;

constructor TBCColorComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
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
  Result := ColorToString(Color);
end;

procedure TBCColorComboBox.SetText(const Value: string);
begin
  try
    Color := StringToColor(Value);
  except
    Color := clBlack;
  end;
end;

end.
