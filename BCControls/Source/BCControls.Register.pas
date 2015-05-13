unit BCControls.Register;

interface

uses
  System.Classes, BCControls.GroupLabel, BCControls.ComboBox, BCControls.CheckBox,
  BCControls.RadioButton, BCControls.ToolBar, BCControls.Panel, BCControls.StatusBar, BCControls.Button,
  BCControls.SpeedButton, BCControls.Splitter, BCControls.Labels, BCControls.PageControl, BCControls.FileControl,
  BCControls.Edit, BCControls.ImageList, BCControls.ButtonedEdit, BCControls.ProgressBar, BCControls.ColorComboBox,
  BCControls.GroupBox, BCControls.ScrollBox, BCControls.DateEdit, BCControls.ProgressPanel, BCControls.StringGrid;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('BCControls', [TBCGroupLabel, TBCComboBox, TBCFontComboBox, TBCCheckBox, TBCRadioButton,
    TBCToolBar, TBCPanel, TBCStatusBar, TBCButton, TBCSpeedButton, TBCSplitter, TBCLabel, TBCLabelFX, TBCPageControl,
    TBCDriveComboBox, TBCFileTypeComboBox, TBCFileTreeView, TBCEdit, TBCImageList, TBCButtonedEdit, TBCProgressBar,
    TBCColorComboBox, TBCGroupBox, TBCScrollBox, TBCDateEdit, TBCProgressPanel, TBCStringGrid]);
end;

end.
