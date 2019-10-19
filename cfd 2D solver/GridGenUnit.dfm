object GridGenForm: TGridGenForm
  Left = 257
  Top = 186
  AutoSize = True
  Caption = 'GridGen'
  ClientHeight = 401
  ClientWidth = 793
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnPaint = FormPaint
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 177
    Height = 385
    Color = clMoneyGreen
    TabOrder = 0
    object GroupBox1: TGroupBox
      Left = 8
      Top = 8
      Width = 145
      Height = 161
      Caption = 'Create Geometry'
      Color = clMoneyGreen
      ParentColor = False
      TabOrder = 0
      object CabinetButton: TButton
        Left = 16
        Top = 24
        Width = 89
        Height = 25
        Caption = 'Cabinet'
        TabOrder = 0
        OnClick = CabinetButtonClick
      end
      object AddBlockButton: TButton
        Left = 16
        Top = 56
        Width = 89
        Height = 25
        Caption = 'Add block'
        TabOrder = 1
        OnClick = AddBlockButtonClick
      end
      object GenerateMeshButton: TButton
        Left = 16
        Top = 88
        Width = 105
        Height = 25
        Caption = 'GenerateMesh'
        TabOrder = 2
        OnClick = GenerateMeshButtonClick
      end
      object ButtonBoundaryCondition: TButton
        Left = 16
        Top = 120
        Width = 113
        Height = 25
        Caption = 'BoundaryCondition'
        TabOrder = 3
        OnClick = ButtonBoundaryConditionClick
      end
    end
    object GroupBox2: TGroupBox
      Left = 16
      Top = 288
      Width = 73
      Height = 81
      Caption = 'Display'
      Color = clMoneyGreen
      ParentColor = False
      TabOrder = 1
      object GeomButton: TButton
        Left = 8
        Top = 16
        Width = 57
        Height = 25
        Caption = 'Geom'
        TabOrder = 0
        OnClick = GeomButtonClick
      end
      object MeshButton: TButton
        Left = 8
        Top = 48
        Width = 57
        Height = 25
        Caption = 'Mesh'
        TabOrder = 1
        OnClick = MeshButtonClick
      end
    end
    object GroupBox3: TGroupBox
      Left = 16
      Top = 208
      Width = 105
      Height = 81
      Caption = 'Read/Write msh'
      Color = clMoneyGreen
      ParentColor = False
      TabOrder = 2
      object write: TButton
        Left = 8
        Top = 16
        Width = 89
        Height = 25
        Caption = 'Write msh'
        TabOrder = 0
        OnClick = writeClick
      end
      object Read: TButton
        Left = 8
        Top = 48
        Width = 89
        Height = 25
        Caption = 'Read msh'
        TabOrder = 1
        OnClick = ReadClick
      end
    end
    object btnShowMeshSize: TButton
      Left = 16
      Top = 176
      Width = 137
      Height = 25
      Caption = 'Show Mesh Size'
      TabOrder = 3
      OnClick = btnShowMeshSizeClick
    end
  end
  object Panel2: TPanel
    Left = 184
    Top = 0
    Width = 169
    Height = 393
    Color = clMoneyGreen
    TabOrder = 1
    object CheckListBox1: TCheckListBox
      Left = 8
      Top = 16
      Width = 153
      Height = 297
      ItemHeight = 13
      Items.Strings = (
        'cabinet')
      TabOrder = 0
    end
    object BResize: TButton
      Left = 16
      Top = 320
      Width = 57
      Height = 25
      Caption = 'BResize'
      TabOrder = 1
      OnClick = BResizeClick
    end
    object BDel: TButton
      Left = 96
      Top = 320
      Width = 57
      Height = 25
      Caption = 'Del'
      TabOrder = 2
      OnClick = BDelClick
    end
    object Brename: TButton
      Left = 16
      Top = 352
      Width = 75
      Height = 25
      Caption = 'BRename'
      TabOrder = 3
      OnClick = BrenameClick
    end
    object BClose: TButton
      Left = 96
      Top = 352
      Width = 57
      Height = 25
      Caption = 'Close'
      TabOrder = 4
      OnClick = BCloseClick
    end
  end
  object GroupBox4: TGroupBox
    Left = 352
    Top = 0
    Width = 441
    Height = 401
    Caption = 'paint window'
    TabOrder = 2
    object PaintBox1: TPaintBox
      Left = 8
      Top = 16
      Width = 433
      Height = 377
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 136
    Top = 256
  end
end
