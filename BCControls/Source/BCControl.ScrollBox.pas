unit BCControl.ScrollBox;

interface

uses
  System.Classes, sScrollBox;

type
  TBCScrollBox = class(TsScrollBox)
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

constructor TBCScrollBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SkinData.SkinSection := 'CHECKBOX';
end;

end.
