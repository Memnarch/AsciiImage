unit AsciiImage.RenderContext;

interface

uses
  Classes,
  Types,
  Graphics,
  AsciiImage.RenderContext.Types,
  AsciiImage.RenderContext.Intf;

type
  TProperties = class(TInterfacedObject, IProperties)
  private
    FOnChanged: TPropertyChangedEvent;
    function GetOnChanged: TPropertyChangedEvent;
    procedure SetOnChanged(const Value: TPropertyChangedEvent);
  protected
    procedure Changed(); virtual;
  public
    property OnChanged: TPropertyChangedEvent read GetOnChanged write SetOnChanged;
  end;

  TBrushProperties = class(TProperties, IBrushProperties)
  private
    FColor: TColorValue;
    FVisible: Boolean;
    function GetColor: TColorValue;
    procedure SetColor(const Value: TColorValue);
    function GetVisible: Boolean;
    procedure SetVisible(const Value: Boolean);
  public
    property Color: TColorValue read GetColor write SetColor;
    property Visible: Boolean read GetVisible write SetVisible;
  end;

  TPenProperties = class(TBrushProperties, IPenProperties)
  private
    FSize: Integer;
    function GetSize: Integer;
    procedure SetSize(const Value: Integer);
  public
    property Size: Integer read GetSize write SetSize;
  end;

  TRenderContext = class(TInterfacedObject, IRenderContext)
  private
    FBrush: IBrushProperties;
    FPen: IPenProperties;
    function GetBrush: IBrushProperties;
    function GetPen: IPenProperties;
  protected
    procedure BrushChanged; virtual; abstract;
    procedure PenChanged; virtual; abstract;
  public
    procedure Clear(AColor: TColorValue); virtual; abstract;
    procedure DrawPolygon(const APoints: array of TPointF); virtual; abstract;
    procedure DrawLine(const AFrom, ATo: TPointF); virtual; abstract;
    procedure DrawEllipsis(const ARect: TRectF); virtual; abstract;
    procedure FillRectangle(const ARect: TRectF); virtual; abstract;
    procedure BeginScene(const ARect: TRect); virtual;
    procedure EndScene(); virtual;
    property Brush: IBrushProperties read GetBrush;
    property Pen: IPenProperties read GetPen;
  end;

implementation

{ TProperties }

procedure TProperties.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged();
end;

function TProperties.GetOnChanged: TPropertyChangedEvent;
begin
  Result := FOnChanged;
end;

procedure TProperties.SetOnChanged(const Value: TPropertyChangedEvent);
begin
  FOnChanged := Value;
end;

{ TBrushProperties }

function TBrushProperties.GetColor: TColorValue;
begin
  Result := FColor;
end;

function TBrushProperties.GetVisible: Boolean;
begin
  Result := FVisible;
end;

procedure TBrushProperties.SetColor(const Value: TColorValue);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    Changed();
  end;
end;

procedure TBrushProperties.SetVisible(const Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    Changed();
  end;
end;

{ TPenProperties }

function TPenProperties.GetSize: Integer;
begin
  Result := FSize;
end;

procedure TPenProperties.SetSize(const Value: Integer);
begin
  if FSize <> Value then
  begin
    FSize := Value;
    Changed();
  end;
end;

{ TRenderContext }

procedure TRenderContext.BeginScene;
begin

end;

procedure TRenderContext.EndScene;
begin

end;

function TRenderContext.GetBrush: IBrushProperties;
begin
  if not Assigned(FBrush) then
  begin
    FBrush := TBrushProperties.Create();
    FBrush.OnChanged := BrushChanged;
  end;
  Result := FBrush;
end;

function TRenderContext.GetPen: IPenProperties;
begin
  if not Assigned(FPen) then
  begin
    FPen := TPenProperties.Create();
    FPen.OnChanged := PenChanged;
  end;
  Result := FPen;
end;

end.
