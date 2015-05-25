unit AsciiImage.RenderContext.Intf;

interface

uses
  Classes,
  Types,
  Graphics,
  AsciiImage.RenderContext.Types;

type
  IProperties = interface;

  TPropertyChangedEvent = reference to procedure;

  IProperties = interface
  ['{171649BE-47FC-4536-822A-CCDD20878573}']
    function GetOnChanged: TPropertyChangedEvent;
    procedure SetOnChanged(const Value: TPropertyChangedEvent);
    property OnChanged: TPropertyChangedEvent read GetOnChanged write SetOnChanged;
  end;

  IBrushProperties = interface(IProperties)
  ['{C716DFFA-B2CD-4210-981B-627B8F923D70}']
    function GetColor: TColorValue;
    procedure SetColor(const Value: TColorValue);
    function GetVisible: Boolean;
    procedure SetVisible(const Value: Boolean);
    property Color: TColorValue read GetColor write SetColor;
    property Visible: Boolean read GetVisible write SetVisible;
  end;

  IPenProperties = interface(IBrushProperties)
  ['{DE04B09C-7ED5-4189-82A6-2C90F5E1F4D6}']
    function GetSize: Integer;
    procedure SetSize(const Value: Integer);
    property Size: Integer read GetSize write SetSize;
  end;

  IRenderContext = interface
  ['{22DAA33A-F062-4F21-92EE-C38F09E2520B}']
    function GetBrush: IBrushProperties;
    function GetPen: IPenProperties;
    procedure Clear(AColor: TColorValue);
    procedure DrawPolygon(const APoints: array of TPointF);
    procedure DrawLine(const AFrom, ATo: TPointF);
    procedure DrawEllipsis(const ARect: TRectF);
    procedure FillRectangle(const ARect: TRectF);
    procedure BeginScene();
    procedure EndScene();
    property Brush: IBrushProperties read GetBrush;
    property Pen: IPenProperties read GetPen;
  end;

implementation

end.
