unit BCComponent.TitleBar;

interface

uses
  System.Classes, acTitleBar;

type
  TBCTitleBar = class(TsTitleBar)
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

constructor TBCTitleBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ShowCaption := False;
end;

end.
