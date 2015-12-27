unit BCControl.Panel;

interface

uses
  System.Classes, sPanel;

type
  TBCPanel = class(TsPanel)
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  Vcl.Controls;

constructor TBCPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SkinData.SkinSection := 'CHECKBOX';
  BevelOuter := bvNone;
end;

end.
