object ApproxConvectionForm: TApproxConvectionForm
  Left = 378
  Top = 202
  AutoSize = True
  Caption = #1052#1077#1090#1086#1076' '#1088#1077#1096#1077#1085#1080#1103' '#1079#1072#1076#1072#1095#1080
  ClientHeight = 353
  ClientWidth = 537
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Pmain: TPanel
    Left = 0
    Top = 0
    Width = 537
    Height = 353
    Color = clMoneyGreen
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 8
      Width = 212
      Height = 13
      Caption = 'Approximation of the convective term'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label3: TLabel
      Left = 8
      Top = 168
      Width = 200
      Height = 13
      Caption = 'Approximation of the unsteady term'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object RadioGroup2: TRadioGroup
      Left = 256
      Top = 32
      Width = 257
      Height = 105
      Caption = 'Pressure-Velocity Coupling'
      Color = clMoneyGreen
      ItemIndex = 0
      Items.Strings = (
        'SIMPLE ( Patankar and Spalding 1972)'
        'SIMPLEC (Van Doormaal and Raithby 1984)'
        'SIMPLER (Patankar S.V. 1979)')
      ParentColor = False
      TabOrder = 0
    end
    object Bapply: TButton
      Left = 424
      Top = 296
      Width = 75
      Height = 25
      Caption = 'Apply'
      TabOrder = 1
      OnClick = BapplyClick
    end
    object grpGarber: TGroupBox
      Left = 256
      Top = 232
      Width = 161
      Height = 41
      Caption = 'artificial diffusion'
      Color = clMoneyGreen
      ParentColor = False
      TabOrder = 2
      Visible = False
      object chkonGarber: TCheckBox
        Left = 16
        Top = 16
        Width = 145
        Height = 17
        Caption = 'include artificial diffusion'
        Checked = True
        State = cbChecked
        TabOrder = 0
      end
    end
    object GroupBox1: TGroupBox
      Left = 256
      Top = 144
      Width = 257
      Height = 81
      Caption = 'UDS Scheme'
      Color = clMoneyGreen
      ParentColor = False
      TabOrder = 3
      object Labeludsindex: TLabel
        Left = 8
        Top = 24
        Width = 52
        Height = 13
        Caption = 'UDS Index'
      end
      object LabelScheme: TLabel
        Left = 8
        Top = 56
        Width = 39
        Height = 13
        Caption = 'Scheme'
      end
      object ComboBoxudsindex: TComboBox
        Left = 72
        Top = 16
        Width = 41
        Height = 21
        ItemIndex = 0
        TabOrder = 0
        Text = '1'
        OnChange = ComboBoxudsindexChange
        Items.Strings = (
          '1'
          '2'
          '3'
          '4')
      end
      object ComboBoxSchemeuds: TComboBox
        Left = 56
        Top = 48
        Width = 185
        Height = 21
        ItemIndex = 5
        TabOrder = 1
        Text = #1089#1093#1077#1084#1072' '#1042'.'#1050'.'#1041#1091#1083#1075#1072#1082#1086#1074#1072' (23)'
        Items.Strings = (
          #1062#1077#1085#1090#1088#1072#1083#1100#1085#1086'-'#1088#1072#1079#1085#1086#1089#1090#1085#1072#1103' '#1089#1093#1077#1084#1072
          'First Order Upwind'
          #1050#1086#1084#1073#1080#1085#1080#1088#1086#1074#1072#1085#1085#1072#1103' '#1089#1093#1077#1084#1072
          #1057#1093#1077#1084#1072' '#1089#1086' '#1089#1090#1077#1087#1077#1085#1085#1099#1084' '#1079#1072#1082#1086#1085#1086#1084
          #1069#1082#1089#1087#1086#1085#1077#1085#1094#1080#1072#1083#1100#1085#1072#1103' '#1089#1093#1077#1084#1072
          #1089#1093#1077#1084#1072' '#1042'.'#1050'.'#1041#1091#1083#1075#1072#1082#1086#1074#1072' (23)'
          #1055#1086#1082#1072#1079#1072#1090#1077#1083#1100#1085#1072#1103' '#1089#1093#1077#1084#1072
          'QUICK'
          'LUS'
          'CUS'
          'SMART'
          'H_QUICK'
          'UMIST'
          'CHARM'
          'MUSCL'
          'VAN_LEER_HARMONIC'
          'OSPRE'
          'VAN_ALBADA'
          'SUPERBEE'
          'MINMOD'
          'H_CUS'
          'KOREN'
          'FROMM')
      end
    end
    object GBVOFtransientformulation: TGroupBox
      Left = 8
      Top = 184
      Width = 217
      Height = 41
      Caption = 'VOF Transient Formulation'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 4
      object CBVOFtransientFormulation: TComboBox
        Left = 8
        Top = 16
        Width = 185
        Height = 21
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ItemIndex = 0
        ParentFont = False
        TabOrder = 0
        Text = ' First Order Implicit (Euler)'
        Items.Strings = (
          ' First Order Implicit (Euler)'
          'Second Order Implicit (Peire)')
      end
    end
    object GBFlowTransForm: TGroupBox
      Left = 8
      Top = 232
      Width = 217
      Height = 41
      Caption = 'Flow Transient Formulation'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 5
      object CBFlowTransientFormulation: TComboBox
        Left = 16
        Top = 16
        Width = 177
        Height = 21
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ItemIndex = 0
        ParentFont = False
        TabOrder = 0
        Text = 'First Order Implicit (Euler)'
        Items.Strings = (
          'First Order Implicit (Euler)'
          'Second Order Implicit (Peire)')
      end
    end
    object GBTemperature: TGroupBox
      Left = 8
      Top = 72
      Width = 241
      Height = 41
      Caption = 'Temperature'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 6
      object CBTemperature: TComboBox
        Left = 8
        Top = 16
        Width = 225
        Height = 21
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ItemIndex = 0
        ParentFont = False
        TabOrder = 0
        Text = #1094#1077#1085#1090#1088#1072#1083#1100#1085#1086'-'#1088#1072#1079#1085#1086#1089#1090#1085#1072#1103' '#1089#1093#1077#1084#1072' (Central difference scheme)'
        Items.Strings = (
          #1094#1077#1085#1090#1088#1072#1083#1100#1085#1086'-'#1088#1072#1079#1085#1086#1089#1090#1085#1072#1103' '#1089#1093#1077#1084#1072' (Central difference scheme)'
          #1087#1088#1086#1090#1080#1074' '#1087#1086#1090#1086#1082#1072' First Order UPWIND'
          #1082#1086#1084#1073#1080#1085#1080#1088#1086#1074#1072#1085#1085#1072#1103' '#1089#1093#1077#1084#1072' (hybrid discretization scheme)'
          #1089#1093#1077#1084#1072' '#1089#1086' '#1089#1090#1077#1087#1077#1085#1085#1099#1084' '#1079#1072#1082#1086#1085#1086#1084' (S.Patankar)'
          #1101#1082#1089#1087#1086#1085#1077#1085#1094#1080#1072#1083#1100#1085#1072#1103' '#1089#1093#1077#1084#1072' (exponential scheme)'
          #1042'.'#1050'.'#1041#1091#1083#1075#1072#1082#1086#1074#1072' [23] '
          #1087#1086#1082#1072#1079#1072#1090#1077#1083#1100#1085#1072#1103
          #1086#1090#1083#1086#1078#1077#1085#1085#1072#1103' '#1082#1086#1088#1088#1077#1082#1094#1080#1103' '#1094#1077#1085#1090#1088#1072#1083#1100#1085#1086'-'#1088#1072#1079#1085#1086#1089#1090#1085#1072#1103' '#1089#1093#1077#1084#1072' '#1085#1072' '#1073#1072#1079#1077' UPWIND'
          'QUICK'
          'LUS'
          'CUS'
          'SMART'
          'H_QUICK'
          'UMIST'
          'CHARM'
          'MUSCL'
          'VAN_LEER_HARMONIC'
          'OSPRE'
          'VAN_ALBADA'
          'SUPERBEE'
          'MINMOD'
          'H_CUS'
          'KOREN'
          'FROMM')
      end
    end
    object GBFlow: TGroupBox
      Left = 8
      Top = 24
      Width = 233
      Height = 41
      Caption = 'Flow'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 7
      object CBFlow: TComboBox
        Left = 8
        Top = 16
        Width = 217
        Height = 21
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ItemIndex = 0
        ParentFont = False
        TabOrder = 0
        Text = #1094#1077#1085#1090#1088#1072#1083#1100#1085#1086'-'#1088#1072#1079#1085#1086#1089#1090#1085#1072#1103' '#1089#1093#1077#1084#1072' (Central difference scheme)'
        Items.Strings = (
          #1094#1077#1085#1090#1088#1072#1083#1100#1085#1086'-'#1088#1072#1079#1085#1086#1089#1090#1085#1072#1103' '#1089#1093#1077#1084#1072' (Central difference scheme)'
          #1087#1088#1086#1090#1080#1074' '#1087#1086#1090#1086#1082#1072' First Order UPWIND'
          #1082#1086#1084#1073#1080#1085#1080#1088#1086#1074#1072#1085#1085#1072#1103' '#1089#1093#1077#1084#1072' (hybrid discretization scheme)'
          #1089#1093#1077#1084#1072' '#1089#1086' '#1089#1090#1077#1087#1077#1085#1085#1099#1084' '#1079#1072#1082#1086#1085#1086#1084' (S.Patankar)'
          #1101#1082#1089#1087#1086#1085#1077#1085#1094#1080#1072#1083#1100#1085#1072#1103' '#1089#1093#1077#1084#1072' (exponential scheme)'
          #1042'.'#1050'.'#1041#1091#1083#1075#1072#1082#1086#1074#1072' [23] '
          #1087#1086#1082#1072#1079#1072#1090#1077#1083#1100#1085#1072#1103
          #1086#1090#1083#1086#1078#1077#1085#1085#1072#1103' '#1082#1086#1088#1088#1077#1082#1094#1080#1103' '#1094#1077#1085#1090#1088#1072#1083#1100#1085#1086'-'#1088#1072#1079#1085#1086#1089#1090#1085#1072#1103' '#1089#1093#1077#1084#1072' '#1085#1072' '#1073#1072#1079#1077' UPWIND'
          'QUICK'
          'LUS'
          'CUS'
          'SMART'
          'H_QUICK'
          'UMIST'
          'CHARM'
          'MUSCL'
          'VAN_LEER_HARMONIC'
          'OSPRE'
          'VAN_ALBADA'
          'SUPERBEE'
          'MINMOD'
          'H_CUS'
          'KOREN'
          'FROMM')
      end
    end
    object GroupBox2: TGroupBox
      Left = 8
      Top = 120
      Width = 89
      Height = 41
      Caption = 'VOF'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 8
      object Label4: TLabel
        Left = 8
        Top = 16
        Width = 58
        Height = 13
        Caption = 'SUPERBEE'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
    end
    object CBISezai: TCheckBox
      Left = 8
      Top = 328
      Width = 209
      Height = 17
      Caption = 'I. Sezai gain of diagonal dominance'
      TabOrder = 9
    end
    object GBTemperatureTransientFormulation: TGroupBox
      Left = 8
      Top = 280
      Width = 217
      Height = 41
      Caption = 'Temperature Transient Formulation'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 10
      object CBTemperatureunsteadyformulation: TComboBox
        Left = 16
        Top = 16
        Width = 177
        Height = 21
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ItemIndex = 0
        ParentFont = False
        TabOrder = 0
        Text = 'First Order Implicit (Euler)'
        Items.Strings = (
          'First Order Implicit (Euler)'
          'Second Order Implicit (Peire)')
      end
    end
    object CheckBoxISezainofabs: TCheckBox
      Left = 200
      Top = 328
      Width = 97
      Height = 17
      Caption = 'I Sezai no fabs'
      TabOrder = 11
    end
    object CheckBoxKIvanovApprox: TCheckBox
      Left = 104
      Top = 136
      Width = 137
      Height = 17
      Caption = 'K Ivanov Approximation'
      TabOrder = 12
    end
  end
end
