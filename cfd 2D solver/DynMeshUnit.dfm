object DynMeshForm: TDynMeshForm
  Left = 431
  Top = 239
  Caption = 'Dynamic Mesh'
  ClientHeight = 411
  ClientWidth = 923
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnPaint = DMFormPaint
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 473
    Height = 409
    Color = clMoneyGreen
    TabOrder = 0
    object Label5: TLabel
      Left = 16
      Top = 16
      Width = 289
      Height = 16
      Caption = 'The Law of Vibration y=Asin(6.28 frequency time);'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object GroupBox1: TGroupBox
      Left = 8
      Top = 40
      Width = 209
      Height = 329
      Caption = 'defining indices'
      Color = clMoneyGreen
      ParentColor = False
      TabOrder = 0
      object GroupBox2: TGroupBox
        Left = 16
        Top = 24
        Width = 177
        Height = 89
        Caption = ' deformable mesh upper  layer'
        Color = clMoneyGreen
        ParentColor = False
        TabOrder = 0
        object Label3: TLabel
          Left = 8
          Top = 24
          Width = 18
          Height = 13
          Caption = 'end'
        end
        object Label4: TLabel
          Left = 8
          Top = 56
          Width = 20
          Height = 13
          Caption = 'start'
        end
        object Ljupend: TLabel
          Left = 112
          Top = 24
          Width = 3
          Height = 13
        end
        object Ljupst: TLabel
          Left = 112
          Top = 56
          Width = 3
          Height = 13
        end
        object Ejupend: TEdit
          Left = 32
          Top = 24
          Width = 65
          Height = 21
          Color = clBtnFace
          TabOrder = 0
        end
        object Ejupstart: TEdit
          Left = 32
          Top = 56
          Width = 65
          Height = 21
          Color = clBtnFace
          TabOrder = 1
        end
      end
      object GroupBox3: TGroupBox
        Left = 16
        Top = 120
        Width = 177
        Height = 81
        Caption = 'lower deformable mesh layer'
        Color = clMoneyGreen
        ParentColor = False
        TabOrder = 1
        object Label1: TLabel
          Left = 8
          Top = 24
          Width = 18
          Height = 13
          Caption = 'end'
        end
        object Label2: TLabel
          Left = 8
          Top = 48
          Width = 20
          Height = 13
          Caption = 'start'
        end
        object Ljdend: TLabel
          Left = 104
          Top = 24
          Width = 3
          Height = 13
        end
        object Ljdstart: TLabel
          Left = 104
          Top = 48
          Width = 3
          Height = 13
        end
        object Ejde: TEdit
          Left = 32
          Top = 16
          Width = 65
          Height = 21
          Color = clBtnFace
          TabOrder = 0
        end
        object Ejds: TEdit
          Left = 32
          Top = 48
          Width = 65
          Height = 21
          Color = clBtnFace
          TabOrder = 1
        end
      end
      object Binput: TButton
        Left = 32
        Top = 296
        Width = 137
        Height = 25
        Caption = 'Apply all parameters'
        TabOrder = 2
        OnClick = BinputClick
      end
      object Panel2: TPanel
        Left = 16
        Top = 208
        Width = 177
        Height = 81
        Color = clMoneyGreen
        TabOrder = 3
        object Label6: TLabel
          Left = 16
          Top = 24
          Width = 45
          Height = 13
          Caption = 'Amplityde'
        end
        object Label7: TLabel
          Left = 16
          Top = 48
          Width = 50
          Height = 13
          Caption = 'Frequency'
        end
        object EAmplityde: TEdit
          Left = 80
          Top = 8
          Width = 81
          Height = 21
          Color = clBtnFace
          TabOrder = 0
        end
        object EFreq: TEdit
          Left = 80
          Top = 40
          Width = 81
          Height = 21
          Color = clBtnFace
          TabOrder = 1
        end
      end
    end
    object BDrawMesh: TButton
      Left = 304
      Top = 344
      Width = 75
      Height = 25
      Caption = 'DrawMesh'
      TabOrder = 1
      OnClick = BDrawMeshClick
    end
    object GroupBox4: TGroupBox
      Left = 224
      Top = 184
      Width = 233
      Height = 153
      Caption = 'Animation deforming mesh'
      Color = clMoneyGreen
      ParentColor = False
      TabOrder = 2
      object Label9: TLabel
        Left = 8
        Top = 24
        Width = 93
        Height = 13
        Caption = 'the number of steps'
      end
      object Label10: TLabel
        Left = 40
        Top = 40
        Width = 71
        Height = 13
        Caption = 'for the period ='
      end
      object Label12: TLabel
        Left = 8
        Top = 80
        Width = 38
        Height = 13
        Caption = 'duration'
      end
      object Label11: TLabel
        Left = 16
        Top = 96
        Width = 102
        Height = 13
        Caption = 'the number of periods'
      end
      object ECount: TEdit
        Left = 128
        Top = 32
        Width = 57
        Height = 21
        TabOrder = 0
        Text = '200'
      end
      object EcountT: TEdit
        Left = 128
        Top = 80
        Width = 73
        Height = 21
        TabOrder = 1
        Text = '1'
      end
      object BAnimate: TButton
        Left = 136
        Top = 112
        Width = 75
        Height = 25
        Caption = 'Animation'
        TabOrder = 2
        OnClick = BAnimateClick
      end
    end
    object Button1: TButton
      Left = 224
      Top = 344
      Width = 75
      Height = 25
      Caption = 'Draw Geom'
      TabOrder = 3
      OnClick = Button1Click
    end
    object GroupBox5: TGroupBox
      Left = 224
      Top = 40
      Width = 233
      Height = 137
      Caption = 'Moving Boundary'
      Color = clMoneyGreen
      ParentColor = False
      TabOrder = 4
      object Label8: TLabel
        Left = 8
        Top = 16
        Width = 129
        Height = 13
        Caption = 'Select a vibrating boundary'
      end
      object ComboBox1: TComboBox
        Left = 16
        Top = 32
        Width = 185
        Height = 21
        ItemHeight = 13
        TabOrder = 0
      end
      object Bmemory: TButton
        Left = 16
        Top = 96
        Width = 193
        Height = 25
        Caption = 'remember the selected border'
        TabOrder = 1
        OnClick = BmemoryClick
      end
      object BDraw: TButton
        Left = 16
        Top = 64
        Width = 193
        Height = 25
        Caption = 'show a selection border'
        TabOrder = 2
        OnClick = BDrawClick
      end
    end
    object BClose: TButton
      Left = 384
      Top = 344
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 5
      OnClick = BCloseClick
    end
  end
  object GroupBox6: TGroupBox
    Left = 480
    Top = 0
    Width = 441
    Height = 409
    Caption = 'paint window'
    TabOrder = 1
    object PaintBox1: TPaintBox
      Left = 8
      Top = 16
      Width = 425
      Height = 377
    end
  end
end
