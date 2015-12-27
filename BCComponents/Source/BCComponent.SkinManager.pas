unit BCComponent.SkinManager;

interface

uses
  System.Classes, sSkinManager;

type
  TBCSkinManager = class(TsSkinManager)
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  Winapi.Windows, Vcl.Graphics;

constructor TBCSkinManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  AnimEffects.DialogHide.Active := False;
  AnimEffects.DialogShow.Active := False;
  AnimEffects.FormHide.Active := False;
  AnimEffects.FormShow.Active := False;
  AnimEffects.SkinChanging.Active := False;
  AnimEffects.Minimizing.Active := False;
  IsDefault := False;
  ButtonsOptions.ShowFocusRect := False;
  MenuSupport.IcoLineSkin := 'ICOLINE';
  MenuSupport.UseExtraLine := True;
  MenuSupport.ExtraLineFont.Charset := DEFAULT_CHARSET;
  MenuSupport.ExtraLineFont.Color := clWindowText;
  MenuSupport.ExtraLineFont.Height := -13;
  MenuSupport.ExtraLineFont.Name := 'Tahoma';
  MenuSupport.ExtraLineFont.Style := [fsBold];
  SkinDirectory := 'Skins';
  Saturation := 10;
  InternalSkins := nil;
  SkinName := 'Windows 10';
  SkinInfo := 'N/A';
  ThirdParty.ThirdEdits := ' '#13#10'TBCEditor'#13#10'TBCEditorPrintPreview'#13#10;
  ThirdParty.ThirdButtons := 'TButton'#13#10;
  ThirdParty.ThirdBitBtns := ' '#13#10;
  ThirdParty.ThirdCheckBoxes := ' '#13#10;
  ThirdParty.ThirdGroupBoxes := ' '#13#10;
  ThirdParty.ThirdListViews := ' '#13#10;
  ThirdParty.ThirdPanels := ' '#13#10;
  ThirdParty.ThirdGrids := ' '#13#10;
  ThirdParty.ThirdTreeViews := ' '#13#10;
  ThirdParty.ThirdComboBoxes := ' '#13#10;
  ThirdParty.ThirdWWEdits := ' '#13#10;
  ThirdParty.ThirdVirtualTrees := ' '#13#10;
  ThirdParty.ThirdGridEh := ' '#13#10;
  ThirdParty.ThirdPageControl := ' '#13#10;
  ThirdParty.ThirdTabControl := ' '#13#10;
  ThirdParty.ThirdToolBar := ' '#13#10;
  ThirdParty.ThirdStatusBar := ' '#13#10;
  ThirdParty.ThirdSpeedButton := ' '#13#10;
  ThirdParty.ThirdScrollControl := ' '#13#10;
  ThirdParty.ThirdUpDown := ' '#13#10;
  ThirdParty.ThirdScrollBar := ' '#13#10;
  ThirdParty.ThirdStaticText := ' '#13#10;
  ThirdParty.ThirdNativePaint := ' '#13#10;
end;

end.
