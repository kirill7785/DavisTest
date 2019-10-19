object FormVolumeFractPar: TFormVolumeFractPar
  Left = 424
  Top = 131
  Caption = 'Volume Fraction Parameters'
  ClientHeight = 447
  ClientWidth = 188
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object rgscheme: TRadioGroup
    Left = 0
    Top = 0
    Width = 121
    Height = 105
    Caption = #1057#1093#1077#1084#1072
    Color = clMoneyGreen
    ItemIndex = 0
    Items.Strings = (
      #1071#1074#1085#1072#1103
      #1053#1077#1103#1074#1085#1072#1103)
    ParentColor = False
    TabOrder = 0
    OnClick = rgschemeClick
  end
  object grpantD: TGroupBox
    Left = 0
    Top = 168
    Width = 185
    Height = 105
    Caption = #1072#1085#1090#1080#1076#1080#1092#1092#1091#1079#1080#1086#1085#1085#1072#1103' '#1082#1086#1088#1077#1082#1094#1080#1103
    Color = clMoneyGreen
    ParentColor = False
    TabOrder = 1
    object lbl1: TLabel
      Left = 8
      Top = 24
      Width = 56
      Height = 13
      Caption = #1053'.'#1043'.'#1041#1091#1088#1072#1075#1086
    end
    object lbl2: TLabel
      Left = 8
      Top = 48
      Width = 44
      Height = 13
      Caption = #1082#1072#1078#1076#1099#1081' '
    end
    object lbl3: TLabel
      Left = 136
      Top = 48
      Width = 19
      Height = 13
      Caption = #1096#1072#1075
    end
    object lbl4: TLabel
      Left = 8
      Top = 72
      Width = 57
      Height = 13
      Caption = #1087#1086' '#1074#1088#1077#1084#1077#1085#1080
    end
    object cbbeveryts: TComboBox
      Left = 56
      Top = 40
      Width = 65
      Height = 21
      ItemHeight = 13
      ItemIndex = 12
      TabOrder = 0
      Text = 'OFF'
      OnChange = cbbeverytsChange
      Items.Strings = (
        '1'
        '2'
        '3'
        '4'
        '5'
        '10'
        '15'
        '20'
        '25'
        '50'
        '100'
        '200'
        'OFF')
    end
  end
  object GroupBoxCourant: TGroupBox
    Left = 0
    Top = 104
    Width = 185
    Height = 57
    Caption = 'Courant Number'
    TabOrder = 2
    object EditCourant: TEdit
      Left = 8
      Top = 24
      Width = 121
      Height = 21
      TabOrder = 0
    end
  end
  object ButtonApply: TButton
    Left = 8
    Top = 416
    Width = 75
    Height = 25
    Caption = 'Apply'
    TabOrder = 3
    OnClick = ButtonApplyClick
  end
  object ButtonClose: TButton
    Left = 104
    Top = 416
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 4
    OnClick = ButtonCloseClick
  end
  object CBCSF: TCheckBox
    Left = 16
    Top = 288
    Width = 153
    Height = 17
    Caption = 'Continuum Surface Force'
    TabOrder = 5
    OnClick = CBCSFClick
  end
  object Panel1: TPanel
    Left = 8
    Top = 312
    Width = 177
    Height = 97
    Color = clMoneyGreen
    TabOrder = 6
    Visible = False
    object Label1: TLabel
      Left = 16
      Top = 16
      Width = 127
      Height = 13
      Caption = 'surface tension coefficient'
    end
    object CBWallAdhesion: TCheckBox
      Left = 16
      Top = 64
      Width = 97
      Height = 17
      Caption = 'Wall Adhesion'
      TabOrder = 0
    end
    object Esigma: TEdit
      Left = 16
      Top = 40
      Width = 121
      Height = 21
      TabOrder = 1
    end
  end
end
