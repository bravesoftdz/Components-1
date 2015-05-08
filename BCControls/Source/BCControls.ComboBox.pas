unit BCControls.ComboBox;

interface

uses
  Winapi.Windows, Winapi.Messages, sComboBox, sFontCtrls, System.Classes, System.Types, Vcl.StdCtrls, Vcl.Controls, Vcl.Graphics,
  Vcl.Dialogs;

type
  TBCComboBox = class(TsCombobox)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TBCFontComboBox = class(TsFontCombobox)
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  sConst;

{ TBCComboBox }

constructor TBCComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BoundLabel.Indent := 4;
  BoundLabel.Layout := sclTopLeft;
end;

{ TBCFontComboBox }

constructor TBCFontComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BoundLabel.Indent := 4;
  BoundLabel.Layout := sclTopLeft;
end;

end.
