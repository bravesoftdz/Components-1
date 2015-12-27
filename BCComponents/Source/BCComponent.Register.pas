unit BCComponent.Register;

interface

uses
  System.Classes, BCComponent.MultiStringHolder, BCComponent.SkinManager, BCComponent.TitleBar,
  BCComponent.SkinProvider, BCComponent.DragDrop;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('BCComponent', [TBCMultiStringHolder, TBCSkinManager, TBCTitleBar, TBCSkinProvider, TBCDragDrop]);
end;

end.
