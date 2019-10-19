object FormDefineTrials: TFormDefineTrials
  Left = 549
  Top = 178
  Caption = 'Define trials'
  ClientHeight = 536
  ClientWidth = 560
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object tbcdefinetrialsmain: TTabControl
    Left = 8
    Top = 8
    Width = 545
    Height = 489
    TabOrder = 0
    Tabs.Strings = (
      'Setup'
      'Design variables'
      'Functions'
      'Trials')
    TabIndex = 0
    OnChange = tbcdefinetrialsmainChange
    object lblvariable: TLabel
      Left = 8
      Top = 32
      Width = 38
      Height = 13
      Caption = 'Variable'
      Visible = False
    end
    object lbluserwarningmemo: TLabel
      Left = 16
      Top = 64
      Width = 223
      Height = 13
      Caption = #1085#1077' '#1073#1086#1083#1077#1077' '#1086#1076#1085#1086#1075#1086' '#1079#1085#1072#1095#1077#1085#1080#1103' '#1074' '#1082#1072#1078#1076#1086#1081' '#1089#1090#1088#1086#1082#1077
      Visible = False
    end
    object rgtrialtype: TRadioGroup
      Left = 8
      Top = 32
      Width = 185
      Height = 105
      Caption = 'Trial type'
      ItemIndex = 0
      Items.Strings = (
        'Single trial (current values)'
        'Parametric trials')
      TabOrder = 0
    end
    object cbbvariable: TComboBox
      Left = 80
      Top = 32
      Width = 145
      Height = 21
      ItemHeight = 13
      TabOrder = 1
      Visible = False
      OnChange = cbbvariableChange
    end
    object mmoserialvalues: TMemo
      Left = 8
      Top = 88
      Width = 217
      Height = 385
      TabOrder = 2
      Visible = False
    end
    object pnlFunctions: TPanel
      Left = 8
      Top = 32
      Width = 377
      Height = 225
      Color = clMoneyGreen
      TabOrder = 3
      Visible = False
      object lbl1: TLabel
        Left = 16
        Top = 8
        Width = 88
        Height = 13
        Caption = 'report parameters'
      end
      object lbl2: TLabel
        Left = 16
        Top = 32
        Width = 36
        Height = 13
        Caption = 'number'
      end
      object lbl3: TLabel
        Left = 88
        Top = 32
        Width = 26
        Height = 13
        Caption = 'name'
      end
      object lbl4: TLabel
        Left = 232
        Top = 32
        Width = 46
        Height = 13
        Caption = 'multiplyer'
      end
      object lblnum1: TLabel
        Left = 16
        Top = 56
        Width = 6
        Height = 13
        Caption = '1'
      end
      object lblnum2: TLabel
        Left = 16
        Top = 80
        Width = 6
        Height = 13
        Caption = '2'
      end
      object lblnum3: TLabel
        Left = 16
        Top = 104
        Width = 6
        Height = 13
        Caption = '3'
      end
      object lblnum4: TLabel
        Left = 16
        Top = 128
        Width = 6
        Height = 13
        Caption = '4'
      end
      object lblnum5: TLabel
        Left = 16
        Top = 152
        Width = 6
        Height = 13
        Caption = '5'
      end
      object lblname1: TLabel
        Left = 88
        Top = 56
        Width = 42
        Height = 13
        Caption = 'lblname1'
      end
      object lblname2: TLabel
        Left = 88
        Top = 80
        Width = 42
        Height = 13
        Caption = 'lblname2'
      end
      object lblname3: TLabel
        Left = 88
        Top = 104
        Width = 42
        Height = 13
        Caption = 'lblname3'
      end
      object lblname4: TLabel
        Left = 88
        Top = 128
        Width = 42
        Height = 13
        Caption = 'lblname4'
      end
      object lblname5: TLabel
        Left = 88
        Top = 152
        Width = 42
        Height = 13
        Caption = 'lblname5'
      end
      object lblm1: TLabel
        Left = 232
        Top = 56
        Width = 24
        Height = 13
        Caption = 'lblm1'
      end
      object lblm2: TLabel
        Left = 232
        Top = 80
        Width = 24
        Height = 13
        Caption = 'lblm2'
      end
      object lblm3: TLabel
        Left = 232
        Top = 104
        Width = 24
        Height = 13
        Caption = 'lblm3'
      end
      object lblm4: TLabel
        Left = 232
        Top = 128
        Width = 24
        Height = 13
        Caption = 'lblm4'
      end
      object lblm5: TLabel
        Left = 232
        Top = 152
        Width = 24
        Height = 13
        Caption = 'lblm5'
      end
      object btnaddreport: TButton
        Left = 248
        Top = 184
        Width = 75
        Height = 25
        Caption = 'Add Report'
        TabOrder = 0
        OnClick = btnaddreportClick
      end
      object btndeletereport: TButton
        Left = 120
        Top = 184
        Width = 99
        Height = 25
        Caption = 'Delete Report'
        TabOrder = 1
        OnClick = btndeletereportClick
      end
    end
  end
  object btnApply: TButton
    Left = 448
    Top = 504
    Width = 75
    Height = 25
    Caption = 'Apply'
    TabOrder = 1
    OnClick = btnApplyClick
  end
end
