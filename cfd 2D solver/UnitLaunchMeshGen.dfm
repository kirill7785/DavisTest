object frmLaunchGenerator: TfrmLaunchGenerator
  Left = 406
  Top = 186
  AutoSize = True
  Caption = 'Launch  Mesh  Generator'
  ClientHeight = 97
  ClientWidth = 251
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object btnContinue: TButton
    Left = 176
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Continue'
    TabOrder = 0
    OnClick = btnContinueClick
  end
  object chkfreeUDS: TCheckBox
    Left = 0
    Top = 0
    Width = 177
    Height = 17
    Caption = 'free and restart setting UDS'
    Checked = True
    State = cbChecked
    TabOrder = 1
  end
  object chkrestartSettingUDM: TCheckBox
    Left = 0
    Top = 24
    Width = 185
    Height = 17
    Caption = 'free and restart setting  UDM'
    Checked = True
    State = cbChecked
    TabOrder = 2
  end
  object chkonlyadditionalunicalmeshline: TCheckBox
    Left = 0
    Top = 48
    Width = 177
    Height = 17
    Caption = 'only  additional  unical mesh line'
    TabOrder = 3
  end
end
