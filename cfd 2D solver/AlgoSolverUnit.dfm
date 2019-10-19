object AlgoSolver: TAlgoSolver
  Left = 351
  Top = 192
  Caption = 'Linear System Solver'
  ClientHeight = 329
  ClientWidth = 468
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 8
    Top = 8
    Width = 457
    Height = 321
    Color = clMoneyGreen
    TabOrder = 0
    object tbc1: TTabControl
      Left = 16
      Top = 16
      Width = 425
      Height = 265
      HotTrack = True
      MultiLine = True
      TabOrder = 0
      Tabs.Strings = (
        'temperature'
        'velocity component'
        #1087#1086#1087#1088#1072#1074#1082#1072' '#1076#1072#1074#1083#1077#1085#1080#1103
        'UDS')
      TabIndex = 0
      OnChange = tbc1Change
      object RadioGroup1: TRadioGroup
        Left = 24
        Top = 48
        Width = 369
        Height = 185
        Caption = #1040#1083#1075#1086#1088#1080#1090#1084' '#1089#1086#1083#1074#1077#1088#1072' '#1090#1077#1087#1083#1086#1087#1088#1086#1074#1086#1076#1085#1086#1089#1090#1080
        Color = clMoneyGreen
        ItemIndex = 3
        Items.Strings = (
          'point-to-point Gauss Seidel'
          #1087#1077#1088#1077#1084#1077#1085#1085#1099#1093' '#1085#1072#1087#1088#1072#1074#1083#1077#1085#1080#1081'  Peaceman D.W. '#1080' Rachford H.H.  [1955]'
          'direct method for the band matrix'
          #1089#1086#1087#1088#1103#1078#1105#1085#1085#1099#1093' '#1075#1088#1072#1076#1080#1077#1085#1090#1086#1074'  '#1061#1077#1089#1090#1077#1085#1089#1072' '#1080' '#1064#1090#1080#1092#1077#1083#1103' [1952]'
          'Algorithm Y.G. Soloveitchik (Novosibirsk) [1993]'
          'AMG (algebraic multigrid)')
        ParentBackground = False
        ParentColor = False
        TabOrder = 0
        OnClick = RadioGroup1Click
      end
      object RadioGroup2: TRadioGroup
        Left = 24
        Top = 49
        Width = 369
        Height = 121
        Caption = #1057#1086#1083#1074#1077#1088' '#1076#1083#1103' '#1082#1086#1084#1087#1086#1085#1077#1085#1090' '#1089#1082#1086#1088#1086#1089#1090#1080
        Color = clMoneyGreen
        ItemIndex = 1
        Items.Strings = (
          #1087#1086#1090#1086#1095#1077#1095#1085#1099#1081' '#1043#1072#1091#1089#1089#1072'  '#1080' '#1047#1077#1081#1076#1077#1083#1103
          #1087#1077#1088#1077#1084#1077#1085#1085#1099#1093' '#1085#1072#1087#1088#1072#1074#1083#1077#1085#1080#1081' Peaceman D.W. '#1080' Rachford H.H. [1955]'
          #1072#1083#1075#1086#1088#1080#1090#1084' '#1070'.'#1043'. '#1057#1086#1083#1086#1074#1077#1081#1095#1080#1082#1072' [1993]'
          #1087#1088#1103#1084#1086#1081' '#1084#1077#1090#1086#1076' '#1050'. '#1060'. '#1043#1072#1091#1089#1089#1072
          'AMG (algebraic multigrid)')
        ParentBackground = False
        ParentColor = False
        TabOrder = 1
        Visible = False
      end
      object RadioGroup3: TRadioGroup
        Left = 24
        Top = 49
        Width = 369
        Height = 161
        Caption = #1057#1086#1083#1074#1077#1088' '#1076#1083#1103' '#1087#1086#1087#1088#1072#1074#1082#1080' '#1076#1072#1074#1083#1077#1085#1080#1103
        Color = clMoneyGreen
        ItemIndex = 0
        Items.Strings = (
          'point-to-point Gauss Seidel'
          #1087#1077#1088#1077#1084#1077#1085#1085#1099#1093' '#1085#1072#1087#1088#1072#1074#1083#1077#1085#1080#1081'  Peaceman D.W. '#1080' Rachford H.H. [1955]'
          'direct method for the band matrix'
          #1089#1086#1087#1088#1103#1078#1105#1085#1085#1099#1093' '#1075#1088#1072#1076#1080#1077#1085#1090#1086#1074' '#1061#1077#1089#1090#1077#1085#1089#1072' '#1080' '#1064#1090#1080#1092#1077#1083#1103' [1952]'
          'BiCGStab H.A. van der Vorst [1990]')
        ParentBackground = False
        ParentColor = False
        TabOrder = 2
        Visible = False
      end
      object btncghelp: TButton
        Left = 328
        Top = 144
        Width = 57
        Height = 25
        Caption = 'help'
        TabOrder = 3
        OnClick = btncghelpClick
      end
      object grpuds: TGroupBox
        Left = 24
        Top = 48
        Width = 385
        Height = 209
        Caption = 'User Defined Scalar'
        TabOrder = 4
        Visible = False
        object lbluds: TLabel
          Left = 16
          Top = 32
          Width = 52
          Height = 13
          Caption = 'UDS Index'
        end
        object cbbuds: TComboBox
          Left = 80
          Top = 24
          Width = 41
          Height = 21
          Color = clMoneyGreen
          ItemIndex = 0
          TabOrder = 0
          Text = '1'
          OnChange = cbbudsChange
          Items.Strings = (
            '1'
            '2'
            '3'
            '4')
        end
        object rguds: TRadioGroup
          Left = 16
          Top = 56
          Width = 361
          Height = 137
          Caption = #1040#1083#1075#1086#1088#1080#1090#1084' '#1088#1077#1096#1072#1090#1077#1083#1103
          ItemIndex = 0
          Items.Strings = (
            'point-to-point Gauss Seidel'
            #1087#1077#1088#1077#1084#1077#1085#1085#1099#1093' '#1085#1072#1087#1088#1072#1074#1083#1077#1085#1080#1081' Peaceman D.W. '#1080' Rachford H.H. [1955]'
            'direct method for the band matrix'
            'AMG (algebraic multigrid)')
          TabOrder = 1
        end
      end
    end
    object Bapply: TButton
      Left = 280
      Top = 288
      Width = 75
      Height = 25
      Caption = 'Apply'
      TabOrder = 1
      OnClick = BapplyClick
    end
  end
end
