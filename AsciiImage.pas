unit AsciiImage;

interface

uses
  Classes,
  Types,
  SysUtils,
  Graphics,
  Generics.Collections,
  AsciiImage.RenderContext.Types,
  AsciiImage.Shapes;

type
  TAsciiImagePaintContext = record
    FillColor: TColor;
    StrokeColor: TColor;
    PenSize: Integer;
  end;

  TAsciiImagePaintCallBack = reference to procedure(const Index: Integer; var Context: TAsciiImagePaintContext);

  TAsciiImage = class(TGraphic)
  private
    FRawData: TArray<string>;
    FDots: array of TList<TPointF>;
    FShapes: TObjectList<TAsciiShape>;
    FIndexLookup: TDictionary<Char, Integer>;
    FWidth: Integer;
    FHeight: Integer;
    FOnDraw: TAsciiImagePaintCallBack;
  protected
    procedure Clear();
    procedure ScanShapes(); virtual;
    procedure AddDot(APoint: TPointF); virtual;
    procedure AddEllipsis(const APoints: array of TPointF); virtual;
    procedure AddPath(const APoints: array of TPointF); virtual;
    procedure AddLine(const AFrom, ATo: TPointF); virtual;
    procedure Draw(ACanvas: TCanvas; const ARect: TRect); override;
    function GetEmpty: Boolean; override;
    function GetHeight: Integer; override;
    function GetWidth: Integer; override;
    procedure SetHeight(Value: Integer); override;
    procedure SetWidth(Value: Integer); override;
  public
    constructor Create(); override;
    destructor Destroy(); override;
    procedure LoadFromAscii(const AAsciiImage: array of string);
    procedure SaveToAscii(var AAsciiImage: TArray<string>);
    procedure DrawDebugGrid(const ACanvas: TCanvas);
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    property OnDraw: TAsciiImagePaintCallBack read FOnDraw write FOnDraw;
  end;

implementation

uses
  Math,
  AsciiImage.RenderContext.GDI,
  AsciiImage.RenderContext.Intf;

{ TAsciiImage }

const
  CCharSet = ['1'..'9', 'A'..'Z', 'a'..'z'];

procedure TAsciiImage.AddDot(APoint: TPointF);
var
  LDot: TAsciiDot;
begin
  LDot := TAsciiDot.Create();
  LDot.Points.Add(APoint);
  FShapes.Add(LDot);
end;

procedure TAsciiImage.AddEllipsis(const APoints: array of TPointF);
var
  LEllipsis: TAsciiEllipsis;
begin
  LEllipsis := TAsciiEllipsis.Create();
  LEllipsis.Points.AddRange(APoints);
  FShapes.Add(LEllipsis);
end;

procedure TAsciiImage.AddLine(const AFrom, ATo: TPointF);
var
  LLine: TAsciiLine;
begin
  LLine := TAsciiLine.Create();
  LLine.Points.Add(AFrom);
  LLine.Points.Add(ATo);
  FShapes.Add(LLine);
end;

procedure TAsciiImage.AddPath(const APoints: array of TPointF);
var
  LPath: TAsciiPath;
begin
  LPath := TAsciiPath.Create();
  LPath.Points.AddRange(APoints);
  FShapes.Add(LPath);
end;

procedure TAsciiImage.Clear;
begin
  FShapes.Clear;
end;

constructor TAsciiImage.Create;
var
  i: Integer;
  LChar: Char;
begin
  inherited;
  FShapes := TObjectList<TAsciiShape>.Create(True);
  FIndexLookup := TDictionary<Char, Integer>.Create();
  i := 0;
  for LChar in CCharSet do
  begin
    FIndexLookup.Add(LChar, i);
    Inc(i);
  end;
  SetLength(FDots, FIndexLookup.Count);
  for i := 0 to Length(FDots) - 1 do
  begin
    FDots[i] := TList<TPointF>.Create();
  end;
  FWidth := 0;
  FHeight := 0;
end;

destructor TAsciiImage.Destroy;
var
  LDotList: TList<TPointF>;
begin
  for LDotList in FDots do
    LDotList.Free;

  SetLength(FDots, 0);
  FShapes.Free();
  FIndexLookup.Free();
  inherited;
end;

procedure TAsciiImage.Draw(ACanvas: TCanvas; const ARect: TRect);
var
  LTemp: TBitmap;
  LContext: IRenderContext;
  i: Integer;
  LScale: Integer;
  LPaintContext: TAsciiImagePaintContext;
begin
  LScale := (ARect.Right - ARect.Left) div FWidth;
  LTemp := TBitmap.Create();
  LTemp.SetSize(Width*LScale, Height*LScale);
  LContext := TGDIRenderContext.Create(LTemp.Canvas.Handle);
  LContext.Clear(ACanvas.Brush.Color);
  for i := 0 to FShapes.Count - 1 do
  begin
    LPaintContext.FillColor := clNone;
    LPaintContext.StrokeColor := clNone;
    LPaintContext.PenSize :=1;
    if Assigned(FOnDraw) then
    begin
      FOnDraw(i, LPaintContext);
    end
    else
    begin
      //some defaultvalues to see something
      LPaintContext.FillColor := clBlack;
      LPaintContext.StrokeColor := clBlack;
    end;

    LContext.Brush.Color := LPaintContext.FillColor;
    LContext.Pen.Color := LPaintContext.StrokeColor;
    LContext.Pen.Size := LPaintContext.PenSize*LScale;
    LContext.Brush.Visible := LContext.Brush.Color <> clNone;
    LContext.Pen.Visible := LContext.Pen.Color <> clNone;
    FShapes[i].Scale := LScale;
    FShapes[i].Draw(LContext);
  end;
  ACanvas.StretchDraw(ARect, LTemp);
end;

procedure TAsciiImage.DrawDebugGrid(const ACanvas: TCanvas);
var
  LScaleX, LScaleY, i: Integer;
  LMode: TPenMode;
  LColor: TColor;
begin
  LScaleX := (ACanvas.ClipRect.Right - ACanvas.ClipRect.Left) div FWidth;
  LScaleY := (ACanvas.ClipRect.Bottom - ACanvas.ClipRect.Top) div FHeight;
  LMode := ACanvas.Pen.Mode;
  ACanvas.Pen.Mode := pmXor;
  LColor := ACanvas.Pen.Color;
  ACanvas.Pen.Color := clRed;
  for i := 1 to FWidth do
  begin
    ACanvas.MoveTo(i*LScaleX, ACanvas.ClipRect.Top);
    ACanvas.LineTo(i*LScaleX, ACanvas.ClipRect.Bottom);
  end;

  for i := 1 to FHeight do
  begin
    ACanvas.MoveTo(ACanvas.ClipRect.Left, i*LScaleY);
    ACanvas.LineTo(ACanvas.ClipRect.Right, i*LScaleY);
  end;
  ACanvas.Pen.Mode := LMode;
  ACanvas.Pen.Color := LColor;
end;

function TAsciiImage.GetEmpty: Boolean;
begin
  Result := FShapes.Count = 0;
end;

function TAsciiImage.GetHeight: Integer;
begin
  Result := FHeight;
end;

function TAsciiImage.GetWidth: Integer;
begin
  Result := FWidth;
end;

procedure TAsciiImage.LoadFromAscii(const AAsciiImage: array of string);
var
  LLineIndex: Integer;
  LFirstLineLength, LCurrentLineLength: Integer;
  LCharIndex: Integer;
  LChar: Char;
  i: Integer;
begin
  SetLength(FRawData, Length(AAsciiImage));
  for i := 0 to Length(AAsciiImage) - 1 do
  begin
    FRawData[i] := AAsciiImage[i];
  end;

  LFirstLineLength := -1;
  for LLineIndex := 0 to Length(AAsciiImage) - 1 do
  begin
    LCurrentLineLength := 0;
    for LChar in AAsciiImage[LLineIndex] do
    begin
      if LChar <> ' ' then
      begin
        if FIndexLookup.TryGetValue(LChar, LCharIndex) then
        begin
          FDots[LCharIndex].Add(PointF(LCurrentLineLength, LLineIndex));
        end;
        Inc(LCurrentLineLength);
      end;
    end;
    if LFirstLineLength < 0 then
    begin
      LFirstLineLength := LCurrentLineLength;
    end
    else
    begin
      if LFirstLineLength <> LCurrentLineLength then
        raise Exception.Create('Length of line ' + IntToStr(LLineIndex) + '(' + IntToStr(LFirstLineLength)
          + ') does not match length of first line (' + IntToStr(LFirstLineLength) + ')');
    end;
  end;
  FWidth := LFirstLineLength;
  FHeight := Length(AAsciiImage);
  ScanShapes();
end;

procedure TAsciiImage.LoadFromStream(Stream: TStream);
var
  LAscii: TStringList;
begin
  LAscii := TStringList.Create();
  try
    LAscii.LoadFromStream(Stream);
    LoadFromAscii(LAscii.ToStringArray);
  finally
    LAscii.Free();
  end;
end;

procedure TAsciiImage.SaveToAscii(var AAsciiImage: TArray<string>);
var
  i: Integer;
begin
  SetLength(AAsciiImage, Length(FRawData));
  for i := 0 to Length(FRawData) - 1 do
  begin
    AAsciiImage[i] := FRawData[i];
  end;
end;

procedure TAsciiImage.SaveToStream(Stream: TStream);
var
  LAscii: TStringList;
begin
  LAscii := TStringList.Create();
  try
    LAscii.AddStrings(FRawData);
    LAscii.SaveToStream(Stream);
  finally
    LAscii.Free;
  end;
end;

procedure TAsciiImage.ScanShapes;
var
  LPathStart, LPathLength: Integer;
  i, k: Integer;
  LPoints: array of TPointF;
begin
  LPathStart := -1;
  for i := 0 to Length(FDots) - 1 do
  begin
    //we have one dot for this char and haven't started a path yet?
    //mark it as path-start
    if FDots[i].Count = 1 then
    begin
      if LPathStart = -1 then
        LPathStart := i;
    end
    else
    begin
      if FDots[i].Count = 2 then
        AddLine(FDots[i][0], FDots[i][1]);

      if FDots[i].Count > 2 then
        AddEllipsis(FDots[i].ToArray);
    end;

    //did we start a path? Is the current dot not part of a path?(Marks end) or is it the last dot?
    if (LPathStart > -1) and ((FDots[i].Count <> 1) or (i = Length(FDots) - 1)) then
    begin
      //in case the final point is simply a path of length 1, pathlength is 0, because
      //i = LPathStart
      //anything with more than 1 point is a path, anything below is just a dot
      LPathLength := i - LPathStart;
      if LPathLength < 2 then
      begin
        AddDot(FDots[LPathStart][0]);
      end
      else
      begin
        SetLength(LPoints, Max(LPathLength, 1));
        for k := 0 to Length(LPoints) - 1 do
        begin
          LPoints[k] := FDots[k + LPathStart][0];
        end;
        AddPath(LPoints);
      end;
      LPathStart := -1;
    end;
  end;
end;

procedure TAsciiImage.SetHeight(Value: Integer);
begin
  inherited;
  if FHeight <> Value then
  begin
    FHeight := Value;
    Clear();
  end;
end;

procedure TAsciiImage.SetWidth(Value: Integer);
begin
  inherited;
  if FWidth <> Value then
  begin
    FWidth := Value;
    Clear();
  end;
end;

initialization
  TPicture.RegisterFileFormat('AIG', 'Ascii Image Graphic', TAsciiImage);

finalization
  TPicture.UnregisterGraphicClass(TAsciiImage);

end.
