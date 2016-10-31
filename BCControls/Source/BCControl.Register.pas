unit BCControl.Register;

interface

uses
  System.Classes, BCControl.GroupLabel, BCControl.ComboBox,
  BCControl.RadioButton, BCControl.ToolBar, BCControl.Panel, BCControl.StatusBar, BCControl.Button,
  BCControl.SpeedButton, BCControl.Splitter, BCControl.Labels, BCControl.PageControl, BCControl.FileControl,
  BCControl.Edit, BCControl.ImageList, BCControl.ButtonedEdit, BCControl.ProgressBar, BCControl.ObjectInspector,
  BCControl.GroupBox, BCControl.ScrollBox, BCControl.DateEdit, BCControl.ProgressPanel, BCControl.StringGrid;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('BCControl', [TBCGroupLabel, TBCComboBox, TBCFontComboBox, TBCRadioButton,
    TBCToolBar, TBCPanel, TBCStatusBar, TBCButton, TBCSpeedButton, TBCSplitter, TBCLabel, TBCLabelFX, TBCPageControl,
    TBCDriveComboBox, TBCFileTypeComboBox, TBCFileTreeView, TBCEdit, TBCImageList, TBCButtonedEdit, TBCProgressBar,
    TBCColorComboBox, TBCGroupBox, TBCScrollBox, TBCDateEdit, TBCProgressPanel, TBCStringGrid, TBCObjectInspector]);
end;

end.
