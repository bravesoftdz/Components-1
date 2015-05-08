unit BCComponents.Register;

interface

uses
  System.Classes, BCComponents.MultiStringHolder, BCComponents.SkinManager, BCComponents.TitleBar,
  BCComponents.SkinProvider, BCComponents.DragDrop;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('BCComponents', [TBCMultiStringHolder, TBCSkinManager, TBCTitleBar, TBCSkinProvider, TBCDragDrop]);
end;

end.
